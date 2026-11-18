# ncmpcppv

This is a wraper for [ncmpcpp](https://github.com/ncmpcpp/ncmpcpp) that ships with [Navi](https://navi-desktop.org), which displays album artwork and an audio visualizer inside of the player.

## Install

```
git clone https://github.com/camku93/ncmpcppv
cd ncmpcppv
./install.sh
```

The installer works on [Arch Linux](https://archlinux.org), [Debian](https://www.debian.org), [Ubuntu](https://ubuntu.com) and their derivatives. It will install [ncmpcpp](https://github.com/ncmpcpp/ncmpcpp), [tmux](https://github.com/tmux/tmux), [mpc](https://www.musicpd.org/clients/mpc/), [ueberzug](https://github.com/seebye/ueberzug) and the extra dependencies, then ncmpcppv.

You also need a working [MPD](https://www.musicpd.org) setup. ncmpcppv doesn't install or configure MPD.

## Manual install

Install [ncmpcpp](https://github.com/ncmpcpp/ncmpcpp), [tmux](https://github.com/tmux/tmux), [mpc](https://www.musicpd.org/clients/mpc/), [file](https://darwinsys.com/file/) and [ueberzug](https://github.com/seebye/ueberzug), then any of these:

| Program | Arch package | Debian/Ubuntu package | Used for |
|---|---|---|---|
| [cava](https://github.com/karlstav/cava) | cava | cava | the visualizer |
| [chafa](https://hpjansson.org/chafa/) | chafa | chafa | album art without X11 |
| [ffmpeg](https://ffmpeg.org) | ffmpeg | ffmpeg | album art with MPD older than 0.22 |

Then install ncmpcppv:

```
sudo make install
```

This will put ncmpcppv in `/usr/local/bin`, to uninstall: `sudo make uninstall`.
