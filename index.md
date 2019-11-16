Gentoo overlay containing pro audio applications.

## How to use this overlay
- Add the following entry to [`/etc/portage/repos.conf`](https://wiki.gentoo.org/wiki//etc/portage/repos.conf) and sync using `emerge --sync`
```ini
[audio-overlay]
location = /<path>/<to>/<your>/<overlays>/audio-overlay
sync-type = git
sync-uri = https://github.com/gentoo-audio/audio-overlay.git
auto-sync = yes
```
- Or if you use [layman](https://wiki.gentoo.org/wiki/Layman) add the overlay using `layman -a audio-overlay` and sync using `layman -s audio-overlay`

## Contact
Join us at the `#proaudio-overlay` channel at `irc.freenode.org` or [create an issue](https://github.com/gentoo-audio/audio-overlay/issues/new).


## Packages
