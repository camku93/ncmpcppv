#!/bin/sh
#   ./install.sh              install everything, or pick the extras
#   ./install.sh --yes        install everything without asking
#   ./install.sh --uninstall  remove ncmpcppv (installed packages are kept)

set -u

PREFIX=${PREFIX:-/usr/local}

say()  { printf '\n\033[1;35m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m!! %s\033[0m\n' "$*" >&2; }
die()  { printf '\033[1;31mxx %s\033[0m\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

cd "$(dirname "$0")" || die "Cannot enter the ncmpcppv folder."
[ "$(id -u)" -ne 0 ] || die "Run this as your normal user. It uses sudo when it needs to."
have sudo || die "sudo is not installed."

if [ "${1:-}" = --uninstall ]; then
	sudo rm -f "$PREFIX/bin/ncmpcppv"
	say "ncmpcppv removed. Packages it installed were kept."
	exit 0
fi

if have pacman; then
	pm=pacman
elif have apt-get; then
	pm=apt
else
	warn "This script supports Arch-based and Debian/Ubuntu-based systems."
	warn "See \"Manual install\" in README.md for the list of programs."
	exit 1
fi

# group number | description | Arch packages | Debian/Ubuntu packages
groups='1|Audio visualizer under the album art|cava|cava
2|Album art without X11 (Wayland, SSH)|chafa|chafa
3|Album art with older versions of MPD|ffmpeg|ffmpeg'

column=3
[ "$pm" = apt ] && column=4

all() { printf '%s\n' "$groups" | cut -d'|' -f"$column" | tr '\n' ' '; }

core="file"
for p in ncmpcpp tmux mpc ueberzug; do
	have "$p" || core="$core $p"
done

if [ "${1:-}" = --yes ]; then
	extra=$(all)
else
	printf 'ncmpcppv needs ncmpcpp, tmux, mpc and ueberzug. The other programs add extras.\n'
	printf 'Install everything (recommended)? [Y/n] '
	answer=
	read -r answer
	case $answer in
	[Nn]*)
		printf '\n'
		printf '%s\n' "$groups" | awk -F'|' '{ printf "  %s) %-40s (%s)\n", $1, $2, $'"$column"' }'
		printf '\nNumbers to install (for example: 1 3), or Enter for none: '
		picks=
		read -r picks
		extra=
		for n in $picks; do
			case $n in
			[1-3]) extra="$extra $(printf '%s\n' "$groups" | awk -F'|' -v n="$n" '$1 == n { print $'"$column"' }')" ;;
			*) warn "Ignoring \"$n\"." ;;
			esac
		done
		;;
	*) extra=$(all) ;;
	esac
fi

available() {
	case $pm in
	pacman) pacman -Si "$1" >/dev/null 2>&1 ;;
	apt) apt-cache show "$1" 2>/dev/null | grep -q '^Package:' ;;
	esac
}

install_pkgs() {
	case $pm in
	pacman) sudo pacman -S --needed --noconfirm "$@" ;;
	apt) sudo apt-get install -y "$@" ;;
	esac
}

if [ "$pm" = apt ]; then
	say "Updating the package lists"
	sudo apt-get update || warn "Could not update the package lists, continuing."
fi

say "Checking packages"
found=
missing=
for p in $core $extra; do
	if available "$p"; then
		found="$found $p"
	else
		missing="$missing $p"
	fi
done

if [ -n "$found" ]; then
	say "Installing packages"
	# shellcheck disable=SC2086
	if ! install_pkgs $found; then
		warn "Installing everything at once failed, trying one at a time."
		for p in $found; do
			install_pkgs "$p" || missing="$missing $p"
		done
	fi
fi

for p in ncmpcpp tmux mpc; do
	have "$p" || die "$p could not be installed, so ncmpcppv cannot work. Install $p, then run this again."
done

say "Installing ncmpcppv to $PREFIX"
sudo install -Dm755 ncmpcppv "$PREFIX/bin/ncmpcppv" || die "Could not install ncmpcppv."

say "Done. Run ncmpcppv to start ncmpcpp with album art."
if [ -n "$missing" ]; then
	warn "Could not be installed:"
	for p in $missing; do printf '   %s\n' "$p" >&2; done
fi
if ! have ueberzug; then
	warn "ueberzug is missing, so album art shows through chafa if it is installed, or as a music note."
elif [ -n "${WAYLAND_DISPLAY:-}" ]; then
	warn "You are on Wayland. ueberzug needs X11, so album art shows through chafa here."
fi
if ! mpc status >/dev/null 2>&1; then
	warn "Could not connect to MPD. ncmpcppv needs a running MPD, see README.md."
fi
