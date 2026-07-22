#!/bin/bash
# Run GameOn on the iOS Simulator (debug mode)
set -e

cd "$(dirname "$0")/.."

echo "==> Building and running on iOS Simulator..."
flutter run \
  --dart-define=SUPABASE_URL=https://jfhingwkrywnxtfapxsm.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sb_publishable_WntLATB_xBUr8-s_0DoYvQ_fHfAPzso \
  "$@"
