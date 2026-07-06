#!/bin/bash
# Run GameOn on a physical iPhone (release mode to avoid JIT crash)
set -e

cd "$(dirname "$0")/.."

# Auto-detect the first connected physical iOS device
DEVICE_ID=$(flutter devices 2>/dev/null | grep -v simulator | grep '• ios ' | head -1 | sed 's/.*• \([^ ]*\) *• ios.*/\1/')

if [ -z "$DEVICE_ID" ]; then
  echo "ERROR: No physical iOS device found. Connect your iPhone and try again."
  exit 1
fi

DEVICE_NAME=$(flutter devices 2>/dev/null | grep -v simulator | grep '• ios ' | head -1 | sed 's/ *•.*//')
echo "==> Building and installing on ${DEVICE_NAME} (release mode)..."
flutter run --release \
  -d "$DEVICE_ID" \
  --dart-define=SUPABASE_URL=https://jfhingwkrywnxtfapxsm.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sb_publishable_WntLATB_xBUr8-s_0DoYvQ_fHfAPzso \
  --dart-define=GOOGLE_PLACES_KEY=AIzaSyAzVWQ2rdH2kh3tUWWyOo1-55ACMi1GTPw \
  "$@"
