#!/bin/sh
# Builds the Android APK (Godot 4.7 + Android export templates, Android SDK, JDK 17; SDK/JDK
# paths come from Godot's editor settings).
# Usage: tools/build_android.sh [output.apk]      (default: build/android/battlemage.apk)
#
#   ANDROID_BUILD   whole number that goes up with every published build. It becomes the APK's
#                   versionCode (Android refuses an update whose code is not higher) and is what
#                   the in-game updater compares against GitHub. 0/unset = local build, which
#                   never offers updates.
#   GODOT           path to the Godot binary (default: godot)
#   Signing: Godot reads GODOT_ANDROID_KEYSTORE_RELEASE_PATH / _USER / _PASSWORD.
set -e
cd "$(dirname "$0")/.."
OUT="${1:-build/android/battlemage.apk}"
case "$OUT" in /*|[A-Za-z]:*) ;; *) OUT="$PWD/$OUT" ;; esac
GODOT="${GODOT:-godot}"
BUILD="${ANDROID_BUILD:-0}"
CODE="$BUILD"; [ "$CODE" -ge 1 ] || CODE=1
STAMP="$(date -u +'%Y-%m-%d %H:%M UTC')"

cp scripts/build_info.gd scripts/build_info.gd.orig
cp export_presets.cfg export_presets.cfg.orig
trap 'mv -f scripts/build_info.gd.orig scripts/build_info.gd; mv -f export_presets.cfg.orig export_presets.cfg' EXIT
sed -i -e "s|^const BUILD := .*|const BUILD := $BUILD|" -e "s|^const STAMP := .*|const STAMP := \"$STAMP\"|" scripts/build_info.gd
# only the Android preset has version/ keys
sed -i -e "s|^version/code=.*|version/code=$CODE|" -e "s|^version/name=.*|version/name=\"build $BUILD\"|" export_presets.cfg

mkdir -p "$(dirname "$OUT")"
rm -f "$OUT"
[ -d .godot/imported ] || "$GODOT" --headless --path . --import >/dev/null 2>&1 || true
"$GODOT" --headless --path . --export-release Android "$OUT"
[ -s "$OUT" ] || { echo "build_android: no APK produced" >&2; exit 1; }
echo "built $OUT  (build $BUILD)"
du -h "$OUT"
