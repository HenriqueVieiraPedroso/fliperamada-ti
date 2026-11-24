#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="$ROOT_DIR/toolchain/flutter_version"
FLUTTER_VERSION="$(sed -n '1p' "$VERSION_FILE")"
FLUTTER_SHA256="$(sed -n '2p' "$VERSION_FILE")"
DART_VERSION="$(sed -n '3p' "$VERSION_FILE")"
DART_ARM64_SHA256="$(sed -n '4p' "$VERSION_FILE")"
HOST_ARCH="$(uname -m)"
CACHE_ROOT="${FLIPER_FLUTTER_CACHE:-${HOME}/.cache/fliperamada}"
INSTALL_DIR="$CACHE_ROOT/flutter-$FLUTTER_VERSION-$HOST_ARCH"

if [[ ! -x "$INSTALL_DIR/bin/flutter" ]]; then
  mkdir -p "$CACHE_ROOT"
  ARCHIVE="${TMPDIR:-/tmp}/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  curl --fail --location --retry 3 --retry-delay 2 "$URL" --output "$ARCHIVE"
  echo "$FLUTTER_SHA256  $ARCHIVE" | sha256sum --check --status || {
    echo "O SHA-256 do arquivo Flutter não corresponde ao valor registrado em $VERSION_FILE." >&2
    rm -f "$ARCHIVE"
    exit 1
  }
  EXTRACT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/fliper-flutter.XXXXXX")"
  trap 'rm -rf "$EXTRACT_DIR" "$ARCHIVE"' EXIT
  tar -xJf "$ARCHIVE" -C "$EXTRACT_DIR"
  mv "$EXTRACT_DIR/flutter" "$INSTALL_DIR"
  rm -rf "$EXTRACT_DIR" "$ARCHIVE"
  trap - EXIT
fi

if [[ "$HOST_ARCH" == "aarch64" || "$HOST_ARCH" == "arm64" ]]; then
  DART_BIN="$INSTALL_DIR/bin/cache/dart-sdk/bin/dart"
  if ! file "$DART_BIN" | grep -q 'ARM aarch64'; then
    DART_ARCHIVE="${TMPDIR:-/tmp}/dartsdk-linux-arm64-${DART_VERSION}.zip"
    DART_URL="https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_VERSION}/sdk/dartsdk-linux-arm64-release.zip"
    curl --fail --location --retry 3 --retry-delay 2 "$DART_URL" --output "$DART_ARCHIVE"
    echo "$DART_ARM64_SHA256  $DART_ARCHIVE" | sha256sum --check --status || {
      echo "O SHA-256 do Dart ARM64 não corresponde ao valor registrado em $VERSION_FILE." >&2
      rm -f "$DART_ARCHIVE"
      exit 1
    }
    TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/fliper-dart.XXXXXX")"
    trap 'rm -rf "$TEMP_DIR" "$DART_ARCHIVE"' EXIT
    unzip -q "$DART_ARCHIVE" -d "$TEMP_DIR"
    [[ "$(cat "$TEMP_DIR/dart-sdk/version")" == "$DART_VERSION" ]] || { echo 'Versão Dart ARM64 inesperada.' >&2; exit 1; }
    rm -rf "$INSTALL_DIR/bin/cache/dart-sdk"
    mv "$TEMP_DIR/dart-sdk" "$INSTALL_DIR/bin/cache/dart-sdk"
    rm -rf "$TEMP_DIR" "$DART_ARCHIVE"
    trap - EXIT
  fi
  if [[ ! -f "$INSTALL_DIR/bin/cache/fliper_flutter_tools_arm64.stamp" ]]; then
    rm -f "$INSTALL_DIR/bin/cache/flutter_tools.snapshot" "$INSTALL_DIR/bin/cache/flutter_tools.stamp"
    touch "$INSTALL_DIR/bin/cache/fliper_flutter_tools_arm64.stamp"
  fi
fi

printf '%s\n' "$INSTALL_DIR"
