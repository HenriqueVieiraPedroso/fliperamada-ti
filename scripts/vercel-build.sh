#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
FLUTTER_ROOT="$(bash scripts/install_flutter.sh)"
export FLUTTER_ROOT
export PATH="$FLUTTER_ROOT/bin:$PATH"
git config --global --add safe.directory "$FLUTTER_ROOT"
flutter config --enable-web >/dev/null
flutter pub get
flutter build web --release \
  --dart-define="SUPABASE_URL=${SUPABASE_URL:-}" \
  --dart-define="SUPABASE_PUBLISHABLE_KEY=${SUPABASE_PUBLISHABLE_KEY:-}"

test -s build/web/index.html || { echo 'Flutter não gerou build/web/index.html.' >&2; exit 1; }
printf 'Build Flutter pronto em %s/build/web\n' "$ROOT_DIR"
