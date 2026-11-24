#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
FLUTTER_ROOT="$(bash scripts/install_flutter.sh)"
export FLUTTER_ROOT
export PATH="$FLUTTER_ROOT/bin:$PATH"
flutter config --enable-web >/dev/null
flutter pub get
exec flutter run -d web-server \
  --web-hostname 0.0.0.0 \
  --web-port "${PORT:-3000}" \
  --dart-define="SUPABASE_URL=${SUPABASE_URL:-}" \
  --dart-define="SUPABASE_PUBLISHABLE_KEY=${SUPABASE_PUBLISHABLE_KEY:-}" \
  --dart-define=MANUS_PREVIEW=true
