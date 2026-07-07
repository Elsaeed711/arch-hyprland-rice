#!/usr/bin/env bash
# =============================================================================
#  arch-hyprland-rice  —  full-system bootstrap
#  Fresh Arch install → clone this repo → run ./setup.sh → reboot.
#  Idempotent-ish and non-fatal: it logs failures to setup.log and keeps going.
# =============================================================================
set -uo pipefail
REPO="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
LOG="$REPO/setup.log"; : > "$LOG"

c(){ printf '\033[%sm' "$1"; }
info(){ printf "\n$(c '1;36')::$(c 0) $(c 1)%s$(c 0)\n" "$*"; }
ok(){   printf "  $(c '1;32')✓$(c 0) %s\n" "$*"; }
warn(){ printf "  $(c '1;33')!$(c 0) %s\n" "$*"; }
die(){  printf "  $(c '1;31')✗ %s$(c 0)\n" "$*"; exit 1; }

# ── 0. sanity ────────────────────────────────────────────────────────────────
[ -f /etc/arch-release ]  || die "This is for Arch Linux."
[ "$(id -u)" -ne 0 ]      || die "Run as your normal user (it sudo's when needed), NOT root."
command -v sudo >/dev/null || die "sudo is required."
[ -f "$REPO/packages/pacman.txt" ] || die "Run this from inside the cloned repo."
ping -c1 -W3 archlinux.org >/dev/null 2>&1 || warn "No internet detected — package install may fail."

cat <<EOF

  arch-hyprland-rice bootstrap  (user: $USER)
  ─────────────────────────────────────────────
   1. install packages  ($(wc -l < "$REPO/packages/pacman.txt") repo + $(wc -l < "$REPO/packages/aur.txt") AUR)
   2. deploy .config + bin  (existing ~/.config is backed up first)
   3. enable services  (sddm · NetworkManager · bluetooth · pipewire · meowrch-pywal)
   4. set zsh + oh-my-zsh + plugins + .zshrc
   5. install the scrolloverview Hyprland plugin (hyprpm)
   6. install the calm GRUB theme
EOF
read -rp "  Continue? [y/N] " a; [[ "${a,,}" == y ]] || die "Aborted."

# ── 1. base tools + paru (AUR helper) ────────────────────────────────────────
info "Base tools + paru"
sudo pacman -Syu --needed --noconfirm git base-devel curl 2>>"$LOG" || die "pacman base failed (see setup.log)"
if ! command -v paru >/dev/null; then
  tmp="$(mktemp -d)"
  git clone --depth 1 https://aur.archlinux.org/paru-bin.git "$tmp/paru" >>"$LOG" 2>&1
  ( cd "$tmp/paru" && makepkg -si --noconfirm ) >>"$LOG" 2>&1 || die "paru install failed (see setup.log)"
  rm -rf "$tmp"
fi
ok "paru ready"

# ── 2. packages ──────────────────────────────────────────────────────────────
info "Repo packages (this takes a while)"
sudo pacman -S --needed --noconfirm - < "$REPO/packages/pacman.txt" 2>>"$LOG" \
  && ok "repo packages installed" \
  || warn "some repo packages failed — see setup.log (rerun-safe)"

info "AUR packages (building — grab a coffee)"
while read -r p; do
  [ -z "$p" ] && continue
  if paru -S --needed --noconfirm "$p" >>"$LOG" 2>&1; then ok "$p"; else warn "AUR failed: $p"; fi
done < "$REPO/packages/aur.txt"

# ── 3. deploy configs ────────────────────────────────────────────────────────
info "Deploying .config + bin"
if [ -d "$HOME/.config" ] && [ -n "$(ls -A "$HOME/.config" 2>/dev/null)" ]; then
  bk="$HOME/.config.backup.$(date +%Y%m%d-%H%M%S)"; cp -a "$HOME/.config" "$bk"; ok "backed up ~/.config → $bk"
fi
mkdir -p "$HOME/.config" "$HOME/bin"
cp -rf "$REPO/.config/." "$HOME/.config/"
cp -rf "$REPO/bin/."     "$HOME/bin/"
chmod +x "$HOME"/bin/*.sh "$HOME"/bin/* 2>/dev/null
ok "configs + bin deployed"

# ── 4. services ──────────────────────────────────────────────────────────────
info "Enabling services"
sudo systemctl enable sddm.service NetworkManager.service bluetooth.service 2>>"$LOG" && ok "system services"
systemctl --user daemon-reload 2>/dev/null
systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service 2>>"$LOG"
systemctl --user enable meowrch-pywal.path 2>>"$LOG"
ok "user services"

# ── 5. shell (zsh + oh-my-zsh + plugins + .zshrc) ────────────────────────────
info "Shell (zsh + oh-my-zsh + plugins)"
[ -d "$HOME/.oh-my-zsh" ] || RUNZSH=no CHSH=no \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended >>"$LOG" 2>&1
ZC="$HOME/.oh-my-zsh/custom/plugins"
[ -d "$ZC/zsh-autosuggestions" ]     || git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions     "$ZC/zsh-autosuggestions"     >>"$LOG" 2>&1
[ -d "$ZC/zsh-syntax-highlighting" ] || git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZC/zsh-syntax-highlighting" >>"$LOG" 2>&1
[ -f "$REPO/.zshrc" ] && cp -f "$REPO/.zshrc" "$HOME/.zshrc" && ok ".zshrc deployed"
[ "$(getent passwd "$USER" | cut -d: -f7)" = "/usr/bin/zsh" ] || chsh -s /usr/bin/zsh 2>>"$LOG"
ok "zsh + oh-my-zsh + plugins"

# ── 6. Hyprland plugin (scrolloverview) ──────────────────────────────────────
info "Hyprland plugin: scrolloverview"
if command -v hyprpm >/dev/null 2>&1 && [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
  hyprpm update >>"$LOG" 2>&1
  hyprpm add https://github.com/yayuuu/hyprland-scroll-overview >>"$LOG" 2>&1
  hyprpm enable scrolloverview >>"$LOG" 2>&1 && ok "scrolloverview enabled" || warn "plugin enable failed — see notes"
else
  warn "not in a Hyprland session — after first login run:"
  printf "        hyprpm update && hyprpm add https://github.com/yayuuu/hyprland-scroll-overview && hyprpm enable scrolloverview\n"
fi

# ── 7. GRUB theme (calm) ─────────────────────────────────────────────────────
info "GRUB theme: calm"
if command -v grub-mkconfig >/dev/null 2>&1 && [ -d /boot/grub ]; then
  GT="$REPO/grub-calm"
  sudo mkdir -p /boot/grub/themes/calm
  sudo cp -f "$GT"/theme.txt "$GT"/background.png "$GT"/font-*.pf2 "$GT"/select_*.png /boot/grub/themes/calm/
  sudo cp -f /etc/default/grub "/etc/default/grub.bak.$(date +%Y%m%d-%H%M%S)"
  if grep -q '^GRUB_THEME=' /etc/default/grub; then
    sudo sed -i 's#^GRUB_THEME=.*#GRUB_THEME="/boot/grub/themes/calm/theme.txt"#' /etc/default/grub
  else
    echo 'GRUB_THEME="/boot/grub/themes/calm/theme.txt"' | sudo tee -a /etc/default/grub >/dev/null
  fi
  if grep -q '^GRUB_GFXMODE=' /etc/default/grub; then
    sudo sed -i 's#^GRUB_GFXMODE=.*#GRUB_GFXMODE=1920x1080,auto#' /etc/default/grub
  else
    echo 'GRUB_GFXMODE=1920x1080,auto' | sudo tee -a /etc/default/grub >/dev/null
  fi
  sudo grub-mkconfig -o /boot/grub/grub.cfg >>"$LOG" 2>&1 && ok "calm grub theme installed" || warn "grub theme step failed — see setup.log"
else
  warn "grub not detected — skipping grub theme"
fi

# ── done ─────────────────────────────────────────────────────────────────────
info "Done ✦"
cat <<EOF
  Next:
   • reboot, choose Hyprland in SDDM, log in
   • if the plugin step was skipped, run the hyprpm line printed above
   • wallpapers / lockscreen pic aren't in the repo — drop your own in
   • detailed failures (if any): $LOG
EOF
