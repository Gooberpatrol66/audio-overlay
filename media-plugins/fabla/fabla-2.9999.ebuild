# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake git-r3

DESCRIPTION="LV2 drum sampler plugin"
HOMEPAGE="http://openavproductions.com/fabla2"
EGIT_REPO_URI="https://github.com/openAVproductions/openAV-Fabla2.git"
KEYWORDS=""
LICENSE="GPL-2"
SLOT="2"

IUSE="+X"

RDEPEND="media-libs/lv2
	media-libs/libsndfile
	media-libs/libsamplerate
	X? ( x11-libs/cairo[X] )"
DEPEND="${RDEPEND}"

PATCHES="${FILESDIR}/${PN}-2-gcc-9-remove-leading-underscore.patch"

src_configure() {
	local mycmakeargs=(
	-DBUILD_GUI="$(usex X ON OFF)"
	)
	cmake_src_configure
}
