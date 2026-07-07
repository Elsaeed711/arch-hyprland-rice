# 🌌 Hyprland Dotfiles

My Arch + Hyprland rice — a wallpaper-driven (pywal) setup, integrated with the meowrch theme engine.

## 🚀 Installation (fresh Arch → full setup)

On a clean Arch install, one command restores the whole system — packages, configs, services, plugin, and shell:

```bash
git clone https://github.com/Elsaeed711/arch-hyprland-rice.git ~/arch-hyprland-rice
cd ~/arch-hyprland-rice
./setup.sh
```

`setup.sh` does the following (logging any failures to `setup.log` and continuing past them):

1. installs **paru** + every package — `packages/pacman.txt` (repo) and `packages/aur.txt` (AUR)
2. backs up your existing `~/.config`, then deploys this repo's `.config` + `bin`
3. enables **sddm · NetworkManager · bluetooth · pipewire · meowrch-pywal**
4. sets **zsh** as login shell, installs **oh-my-zsh** (+ autosuggestions & syntax-highlighting), deploys **.zshrc**
5. installs the **scrolloverview** Hyprland plugin via `hyprpm`

Then **reboot**, choose **Hyprland** in SDDM, and log in.

> The Hyprland plugin needs a running session — if step 5 is skipped, run it after first login:
> ```bash
> hyprpm update && hyprpm add https://github.com/yayuuu/hyprland-scroll-overview && hyprpm enable scrolloverview
> ```

<details>
<summary><b>📜 setup.sh — the full script</b></summary>

```bash
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

# ── done ─────────────────────────────────────────────────────────────────────
info "Done ✦"
cat <<EOF
  Next:
   • reboot, choose Hyprland in SDDM, log in
   • if the plugin step was skipped, run the hyprpm line printed above
   • wallpapers / lockscreen pic aren't in the repo — drop your own in
   • detailed failures (if any): $LOG
EOF
```

</details>

## Components
- **Hyprland** — window manager (`.config/hypr/`)
- **Waybar** — bar with custom adaptive modules (volume follows buds, scrolling now-playing, brightness, gpu, battery, network…)
- **wofi** — app launcher · **rofi** — image-grid wallpaper/theme picker
- **hyprlock** — lock · **wlogout** — power menu · **swaync** — notifications
- **kitty** · **cava** · **fastfetch** · **btop**

## Theming (pywal: wallpaper → colors)
Changing the wallpaper regenerates the palette with `wal`; `bin/pywal-reload.sh` (fired by a systemd path unit) pushes the new colors to waybar, cava, kitty, the rofi picker, and `lavat`, so the whole system recolors with the background.

## Fun scripts (`bin/`)
- `dvd-bounce.py` — DVD-logo bouncing-windows screensaver (toggle: Super+Shift+D)
- `lavat` — adaptive lava-lamp wrapper (vivid pywal colors, live re-skin)
- `wb-*.sh` — the waybar module scripts

## Dependencies
hyprland hyprlock hypridle waybar wofi rofi swaync kitty cava fastfetch btop wlogout
pywal16 swww brightnessctl playerctl wpctl nmcli blueman + **[meowrch](https://github.com/meowrch/meowrch)** (wallpaper/theme engine, cloned separately).

## Notes
- Paths are hardcoded for user `Void` — adjust if you clone.
- The lock screen profile pic and wallpapers aren't included (personal/large) — drop your own in.
