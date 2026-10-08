#!/usr/bin/env bash
# Install or remove the Simplified Chinese font fix for The Roottrees are Dead (macOS).
#
#   bash install.sh                        install (finds the game in your Steam libraries)
#   bash install.sh --uninstall            remove the fix
#   bash install.sh "/path/to/roottrees.app"   use a specific install
set -euo pipefail

STEAM_ROOT="$HOME/Library/Application Support/Steam"
GAME_SUBPATH="steamapps/common/The Roottrees are Dead/roottrees.app"
MARKER='theme/custom_font="res://fonts/SourceHanSansSC-Normal.otf"'
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mode=install
app=""
for arg in "$@"; do
  case "$arg" in
    -u|--uninstall) mode=uninstall ;;
    -h|--help) sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) app="$arg" ;;
  esac
done

find_app() {
  local libs=("$STEAM_ROOT")
  local vdf="$STEAM_ROOT/steamapps/libraryfolders.vdf"
  if [[ -f "$vdf" ]]; then
    while IFS= read -r path; do
      libs+=("$path")
    done < <(sed -n 's/^[[:space:]]*"path"[[:space:]]*"\(.*\)"[[:space:]]*$/\1/p' "$vdf")
  fi
  local lib
  for lib in "${libs[@]}"; do
    if [[ -d "$lib/$GAME_SUBPATH" ]]; then
      echo "$lib/$GAME_SUBPATH"
      return 0
    fi
  done
  return 1
}

if [[ -z "$app" ]]; then
  if ! app="$(find_app)"; then
    echo "Couldn't find The Roottrees are Dead in your Steam libraries." >&2
    echo "Pass the game's app bundle instead:  bash install.sh \"/path/to/roottrees.app\"" >&2
    exit 1
  fi
fi

target="$app/Contents/MacOS"
if [[ ! -d "$target" ]]; then
  echo "Not a macOS app bundle: $app" >&2
  exit 1
fi
cfg="$target/override.cfg"

case "$mode" in
  install)
    if [[ -f "$cfg" ]] && ! grep -qF "$MARKER" "$cfg"; then
      cp "$cfg" "$cfg.bak"
      echo "Backed up an existing override.cfg to $cfg.bak"
    fi
    cp "$HERE/override.cfg" "$cfg"
    echo "Installed: $cfg"
    echo "Restart the game if it's running."
    ;;
  uninstall)
    if [[ ! -f "$cfg" ]]; then
      echo "Nothing to remove: no override.cfg in $target"
    elif grep -qF "$MARKER" "$cfg"; then
      rm "$cfg"
      echo "Removed: $cfg"
      if [[ -f "$cfg.bak" ]]; then
        mv "$cfg.bak" "$cfg"
        echo "Restored your previous override.cfg"
      fi
    else
      echo "Left $cfg alone: it isn't the file this fix installs." >&2
      exit 1
    fi
    ;;
esac
