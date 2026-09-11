#!/bin/zsh
# YAZI release script — ALWAYS builds BOTH platforms so they can never drift apart.
# Usage: ./scripts/release.sh [version]   e.g. ./scripts/release.sh 1.2.0
set -e
cd "$(dirname "$0")/.."

CURRENT=$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d+ -f1)
BUILD=$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d+ -f2)
VERSION=${1:-$CURRENT}
NEWBUILD=$((BUILD + 1))

# 1) bump pubspec version
sed -i '' "s/^version: .*/version: ${VERSION}+${NEWBUILD}/" pubspec.yaml
# 2) sync the visible footer version in the app
sed -i '' -E "s/· v[0-9]+\.[0-9]+\.[0-9]+/· v${VERSION}/" lib/screens/home.dart lib/screens/profile.dart
echo "==> version ${VERSION}+${NEWBUILD}"

flutter analyze

# 3) Android
flutter build apk --release
rm -f ../YAZI-v*.apk
cp build/app/outputs/flutter-apk/app-release.apk "../YAZI-v${VERSION}.apk"

# 3b) verify the APK really contains THIS version's compiled code.
# (Guards against stale-cache builds: Gradle once stamped a new versionName
# onto an APK whose Dart code was still the previous release.)
if ! unzip -p "../YAZI-v${VERSION}.apk" lib/arm64-v8a/libapp.so | grep -q "v${VERSION}"; then
  echo "✗ STALE BUILD: APK does not contain the v${VERSION} footer."
  echo "  Running flutter clean and rebuilding…"
  flutter clean
  flutter pub get
  flutter build apk --release
  cp build/app/outputs/flutter-apk/app-release.apk "../YAZI-v${VERSION}.apk"
  unzip -p "../YAZI-v${VERSION}.apk" lib/arm64-v8a/libapp.so | grep -q "v${VERSION}" \
    || { echo "✗ Still stale after clean — aborting."; exit 1; }
fi
echo "==> ../YAZI-v${VERSION}.apk (verified: contains v${VERSION})"

# 4) iOS + install on the connected iPhone
flutter build ios --release
DEVICE="00008150-000265C90CD2401C"   # HH
xcrun devicectl device install app --device "$DEVICE" build/ios/iphoneos/Runner.app
xcrun devicectl device process launch --device "$DEVICE" com.yozi.yoziApp || \
  echo "!! iPhone locked — unlock it and open YAZI manually (already installed)"

echo "==> DONE: iPhone updated · APK: YAZI-v${VERSION}.apk · footer shows v${VERSION}"
