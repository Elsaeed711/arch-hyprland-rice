#!/usr/bin/env bash
# Install the "calm" GRUB theme.  RUN WITH SUDO:   sudo ./install.sh
# Safe: backs up /etc/default/grub, and a bad theme only falls back to the text
# menu (it won't stop you booting).
set -e
SRC="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
DEST="/boot/grub/themes/calm"
DEF="/etc/default/grub"

[ "$(id -u)" -eq 0 ] || { echo "Run with sudo:  sudo $0"; exit 1; }

echo ":: installing theme → $DEST"
mkdir -p "$DEST"
cp -f "$SRC"/theme.txt "$SRC"/background.png "$SRC"/font-*.pf2 "$SRC"/select_*.png "$DEST"/

echo ":: backing up $DEF → $DEF.bak.$(date +%Y%m%d-%H%M%S)"
cp -f "$DEF" "$DEF.bak.$(date +%Y%m%d-%H%M%S)"

echo ":: setting GRUB_THEME + GRUB_GFXMODE"
if grep -q '^GRUB_THEME=' "$DEF"; then
  sed -i 's#^GRUB_THEME=.*#GRUB_THEME="/boot/grub/themes/calm/theme.txt"#' "$DEF"
else
  echo 'GRUB_THEME="/boot/grub/themes/calm/theme.txt"' >> "$DEF"
fi
if grep -q '^GRUB_GFXMODE=' "$DEF"; then
  sed -i 's#^GRUB_GFXMODE=.*#GRUB_GFXMODE=1920x1080,auto#' "$DEF"
else
  echo 'GRUB_GFXMODE=1920x1080,auto' >> "$DEF"
fi

echo ":: regenerating /boot/grub/grub.cfg"
grub-mkconfig -o /boot/grub/grub.cfg

echo
echo ":: done ✦  reboot to see the calm theme."
echo "   revert: restore the newest $DEF.bak.* and rerun  grub-mkconfig -o /boot/grub/grub.cfg"
