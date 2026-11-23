#!/usr/bin/env bash
# Compiles the APK (start screen in Java + NativeActivity with libnier.so and libnnsdk.so) into build/mhriseport.apk.
# Needs: Android SDK with NDK 28.2.13676358, build-tools 35.0.0 and platform android-33; a JDK (11+); cmake; python3;
# zip. Run tools/setup.sh once first (third-party sources).
#
# Signing: by default the Android debug keystore (~/.android/debug.keystore, created if missing). For your own release
# key: KEYSTORE=<file> KS_PASS=<password> [KEY_ALIAS=<alias>] tools/build_apk.sh
# RELEASE=1: the build for players (the release workflow): -O3 without debug info, unused code and duplicate functions
# dropped, symbols stripped, and an APK that isn't debuggable (ART runs a debuggable app's Java slower). Without it,
# RelWithDebInfo and a debuggable APK, for testing.
# PACKAGE=<name>: the same app under another package name (with LABEL=<name on the home screen>). Some phones give a
# benchmark's package the most CPU and GPU clock (com.antutu.ABenchMark, com.ludashi.benchmark), so the release has
# those too. The Java classes keep their own package, only what Android sees changes; each one installs next to the
# others with its own settings and drivers.
# Compila la APK. Firma con la clave de depuración de Android salvo que se pase KEYSTORE.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
NDK="${NDK_DIR:-$SDK/ndk/28.2.13676358}"  # this exact NDK (ANDROID_NDK_HOME often points to another)
BT="$SDK/build-tools/35.0.0"
JAR="$SDK/platforms/android-33/android.jar"
RELEASE="${RELEASE:-0}"
if [ "$RELEASE" = 1 ]; then
  BUILD_TYPE=Release BUILD="$ROOT/build/android-release" DEBUG_FLAG=""
else
  BUILD_TYPE=RelWithDebInfo BUILD="$ROOT/build/android" DEBUG_FLAG="--debug-mode"
fi
STAGE="$ROOT/build/apk"
APK="${APK_OUT:-$ROOT/build/mhriseport.apk}"
PACKAGE="${PACKAGE:-}"
JOBS="${JOBS:-$(getconf _NPROCESSORS_ONLN 2> /dev/null || echo 4)}"

for need in "$NDK/build/cmake/android.toolchain.cmake" "$BT/aapt2" "$JAR"; do
  [ -e "$need" ] || { echo "missing: $need (see README: Building)" >&2; exit 1; }
done
[ -d "$ROOT/third_party/eden/src/shader_recompiler" ] || { echo "run tools/setup.sh first" >&2; exit 1; }

mkdir -p "$BUILD"
cmake -S "$ROOT/runtime" -B "$BUILD" -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
  -DCMAKE_TOOLCHAIN_FILE="$NDK/build/cmake/android.toolchain.cmake" -DANDROID_NDK="$NDK" \
  -DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM=android-30 -DANDROID_STL=c++_static > /dev/null
if ! cmake --build "$BUILD" -j"$JOBS" > "$BUILD/build.log" 2>&1; then
  grep -E "error" "$BUILD/build.log" >&2 || tail -40 "$BUILD/build.log" >&2
  echo "build failed (full log: $BUILD/build.log)" >&2
  exit 1
fi

rm -rf "$STAGE"
mkdir -p "$STAGE/lib/arm64-v8a" "$STAGE/classes"
# Start screen (SetupActivity: find the user's game files, then start): javac + d8 into classes.dex.
javac -Xlint:-options --release 11 -classpath "$JAR" -d "$STAGE/classes" $(find "$ROOT/android/java" -name '*.java')
"$BT/d8" --release --min-api 30 --lib "$JAR" --output "$STAGE" $(find "$STAGE/classes" -name '*.class')
cp "$BUILD/libnier.so" "$BUILD/libnnsdk.so" "$STAGE/lib/arm64-v8a/"
# libadrenotools' hooks (a driver of the user's own, runtime/src/nnsdk/nvn/driver.h): they must be in nativeLibraryDir.
cp $(find "$BUILD/adrenotools" -name 'lib*hook*.so') "$STAGE/lib/arm64-v8a/"
# The third-party notices and licenses that go with the binaries (BSD-2 libadrenotools, MIT volk).
mkdir -p "$STAGE/assets/licenses"
cp "$ROOT/THIRD_PARTY_NOTICES.md" "$STAGE/assets/licenses/"
cp "$ROOT/runtime/external/libadrenotools/LICENSE" "$STAGE/assets/licenses/libadrenotools.txt"
cp "$ROOT/runtime/external/libadrenotools/lib/linkernsbypass/LICENSE" "$STAGE/assets/licenses/linkernsbypass.txt"
cp "$ROOT/runtime/external/volk/LICENSE.md" "$STAGE/assets/licenses/volk.txt"
# The Citrus curves for Steam saves (SaveData.java)
cp "$ROOT/android/assets/citrus_curves.bin" "$STAGE/assets/"
"$BT/aapt2" compile --dir "$ROOT/android/res" -o "$STAGE/res.zip"
MANIFEST="$ROOT/android/AndroidManifest.xml" RENAME=()
if [ -n "$PACKAGE" ]; then
  MANIFEST="$STAGE/AndroidManifest.xml"
  sed "s|android:label=\"MH Rise Android Recomp\"|android:label=\"${LABEL:-MH Rise Android Recomp ($PACKAGE)}\"|" \
    "$ROOT/android/AndroidManifest.xml" > "$MANIFEST"
  RENAME=(--rename-manifest-package "$PACKAGE")
fi
"$BT/aapt2" link --manifest "$MANIFEST" -I "$JAR" -R "$STAGE/res.zip" --auto-add-overlay \
  "${RENAME[@]}" $DEBUG_FLAG -o "$STAGE/base.apk"
(cd "$STAGE" && zip -q -r base.apk lib classes.dex assets)
"$BT/zipalign" -f -p 4 "$STAGE/base.apk" "$STAGE/aligned.apk"

if [ -n "${KEYSTORE:-}" ]; then
  "$BT/apksigner" sign --ks "$KEYSTORE" --ks-pass env:KS_PASS ${KEY_ALIAS:+--ks-key-alias "$KEY_ALIAS"} \
    --out "$APK" "$STAGE/aligned.apk"
else
  DEBUG_KS="$HOME/.android/debug.keystore"
  if [ ! -f "$DEBUG_KS" ]; then
    mkdir -p "$(dirname "$DEBUG_KS")"
    keytool -genkeypair -keystore "$DEBUG_KS" -storepass android -keypass android -alias androiddebugkey \
      -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US" > /dev/null
  fi
  "$BT/apksigner" sign --ks "$DEBUG_KS" --ks-pass pass:android --key-pass pass:android --out "$APK" "$STAGE/aligned.apk"
fi
echo "$APK"
