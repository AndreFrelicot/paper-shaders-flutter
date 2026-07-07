#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
example_dir="$repo_root/example"
app_path="$example_dir/build/macos/Build/Products/Debug/paper_shaders_example.app"
app_bin="$app_path/Contents/MacOS/paper_shaders_example"
output_dir="$repo_root/build/flutter-goldens"

cd "$example_dir"
flutter build macos --debug >/dev/null

mkdir -p "$output_dir"
rm -f "$output_dir"/*.png

targets=()
while IFS= read -r target; do
  targets+=("$target")
done < <(PAPER_SHADERS_GOLDEN_LIST=1 "$app_bin" 2>/dev/null | grep '^[a-z0-9-][a-z0-9-]*--[a-z0-9-][a-z0-9-]*$')

for target in "${targets[@]}"; do
  log_file="$(mktemp)"
  output_file="$output_dir/$target.png"

  if ! PAPER_SHADERS_GOLDEN_TARGET="$target" \
    PAPER_SHADERS_GOLDEN_OUTPUT="-" \
    "$app_bin" >"$log_file" 2>&1; then
    cat "$log_file" >&2
    rm -f "$log_file"
    echo "Failed to render $target" >&2
    exit 1
  fi

  awk '
    /^PAPER_SHADERS_GOLDEN_PNG_BEGIN$/ { capture = 1; next }
    /^PAPER_SHADERS_GOLDEN_PNG_END$/ { capture = 0; next }
    capture { print }
  ' "$log_file" | python3 -c 'import base64, pathlib, sys; pathlib.Path(sys.argv[1]).write_bytes(base64.b64decode(sys.stdin.read()))' "$output_file"

  if [[ ! -s "$output_file" ]]; then
    cat "$log_file" >&2
    rm -f "$log_file"
    echo "Missing PNG output for $target" >&2
    exit 1
  fi

  rm -f "$log_file"
done

echo "Rendered ${#targets[@]} PNG files to $output_dir"
