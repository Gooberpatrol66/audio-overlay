# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

USE_RUBY="ruby25 ruby26 ruby27"
PYTHON_COMPAT=( python{2_7,3_6,3_7,3_8,3_9} )

inherit git-r3 bash-completion-r1 ruby-single python-any-r1

DESCRIPTION="Zyn-Fusion User Interface"
HOMEPAGE="https://github.com/mruby-zest/mruby-zest-build"
EGIT_REPO_URI="https://github.com/mruby-zest/mruby-zest-build"
EGIT_COMMIT="${PV}"

SUBMODULES=(
	"2033837203c8a141b1f9d23bb781fe0cbaefbd24 mruby/build/mrbgems/mgem-list https://github.com/mruby/mgem-list"
	"89dceefa1250fb1ae868d4cb52498e9e24293cd1 mruby/build/mrbgems/mruby-dir https://github.com/iij/mruby-dir"
	"383a9c79e191d524a9a2b4107cc5043ecbf6190b mruby/build/mrbgems/mruby-pack https://github.com/iij/mruby-pack"
	"b4415207ff6ea62360619c89a1cff83259dc4db0 mruby/build/mrbgems/mruby-errno https://github.com/iij/mruby-errno"
	"d196a1e529d227511cf19d516a46f62866619008 mruby/build/mrbgems/mruby-file-stat https://github.com/ksss/mruby-file-stat"
	"95da206a5764f4e80146979b8e35bd7a9afd6850 mruby/build/mrbgems/mruby-process https://github.com/iij/mruby-process"
)
for i in "${SUBMODULES[@]}"; do
	set -- $i
	SRC_URI+=" $3/archive/$1.tar.gz -> ${3/*\//}-$1.tar.gz"
done

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-libs/libuv
	x11-libs/libX11
	x11-libs/libxcb
	virtual/opengl"
RDEPEND="${DEPEND}"
BDEPEND="${PYTHON_DEPS}"

PATCHES=(
"${FILESDIR}/zyn-fusion-gcc10.patch"
"${FILESDIR}/zyn-fusion-qml-path.patch"
)

src_unpack() {
  git-r3_src_unpack
  default
}

src_prepare() {
	# Unbundle libuv: makefile and rake file
	sed -i -e "s%./deps/\$(UV_DIR)/.libs/libuv.a%`pkg-config --libs libuv`%" \
		-e 's%-I ../../deps/\$(UV_DIR)/include%-I /usr/include/uv/%' Makefile
	sed -i -e "/deps\/libuv.a/s/<< .*/<< \"`pkg-config --libs libuv`\"/" \
		-e 's%../deps/libuv-v1.9.1/include/%usr/include/uv/%' build_config.rb

	for i in "${SUBMODULES[@]}"; do
		set -- $i
		mkdir -p "$2"
		rmdir "$2"
		mv "../${3/*\//}-$1" "$2"
	done

	# fix jobserver, make rake use MAKEOPTS too, give it a soname,
	# say no to python2, use LDFLAGS/CFLAGS
	sed -i -e 's/\bmake\b/$(MAKE)/' \
		-e "s/\brake\b/rake ${MAKEOPTS}/" \
		-e 's/-shared/$(LDFLAGS) -shared -Wl,-soname,libzest.so/' \
		-e "s/python2/${EPYTHON}/" \
		-e "s/--debug//" \
		-e 's/CFLAGS="/CFLAGS="$(CFLAGS) /' \
		-e 's/$(CC)/$(CC) $(CFLAGS)/' Makefile

	default_src_prepare

	# bundled waf is broken in Python3.7, and this is a version with
	# autowaf, so it isn't trivial to just replace with upstream.
	# Hack around it instead.
	${EPYTHON} deps/pugl/waf --version # This will unpack waf
	# Now fix it
	sed -i -e '/StopIteration/d' deps/pugl/.waf*/waflib/Node.py
}

src_install() {
	insinto /usr/share/zyn-fusion/qml
	doins src/mruby-zest/qml/*
	doins src/mruby-zest/example/*

	insinto /usr/share/zyn-fusion/schema
	doins src/osc-bridge/schema/test.json

	insinto /usr/share/zyn-fusion/font
	doins deps/nanovg/example/*.ttf

	dolib.so libzest.so
	dobin zest
	dosym zest /usr/bin/zyn-fusion
	dobashcomp completions/zyn-fusion
	bashcomp_alias zyn-fusion zest
}
