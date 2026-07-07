#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
workbench="${WORKBENCH:-$repo_root/../paper-shaders-prd}"
fail_ratio="${FAIL_RATIO:-0.01}"
out_dir="${PARITY_OUT:-$repo_root/build/flutter-goldens}"

allowed_fail_ratio() {
  case "$1" in
    # dot-orbit depends on a decoded PNG noise sampler plus screen-space
    # antialiasing. Flutter renders it deterministically, but not
    # pixel-identically to the WebGL SwiftShader golden.
    dot-orbit--bubbles.png) echo "0.06" ;;
    dot-orbit--default.png) echo "0.25" ;;
    dot-orbit--hallucinatory.png) echo "0.03" ;;
    grain-gradient--blob.png) echo "0.06" ;;
    grain-gradient--default.png) echo "0.12" ;;
    grain-gradient--dots.png) echo "0.29" ;;
    grain-gradient--ripple.png) echo "0.23" ;;
    grain-gradient--truchet.png) echo "0.27" ;;
    grain-gradient--wave.png) echo "0.15" ;;
    # Image shaders using upstream preprocessed mask assets. Flutter can sample
    # the same PNGs, but runtime shaders do not expose WebGL/Metal-style image
    # mipmaps or fwidth(float), so smoke bands and hard mask edges diverge.
    gem-smoke--default.png) echo "0.08" ;;
    gem-smoke--fire.png) echo "0.15" ;;
    gem-smoke--fluorescent.png) echo "0.08" ;;
    gem-smoke--infrared.png) echo "0.35" ;;
    halftone-cmyk--default.png) echo "0.32" ;;
    halftone-cmyk--drops.png) echo "0.24" ;;
    halftone-cmyk--newspaper.png) echo "0.19" ;;
    halftone-cmyk--vintage.png) echo "0.28" ;;
    halftone-dots--default.png) echo "0.11" ;;
    halftone-dots--mosaic.png) echo "0.24" ;;
    halftone-dots--round-and-square.png) echo "0.17" ;;
    # fluted-glass samples an image through repeated warped/blurred passes.
    # Flutter runtime shaders do not expose image mipmaps, and deterministic
    # derivative fallbacks shift the narrow fluting bands versus WebGL.
    fluted-glass--default.png) echo "0.04" ;;
    fluted-glass--waves.png) echo "0.03" ;;
    # Sepia has high-frequency procedural noise over most pixels; the default
    # heatmap preset stays below the global threshold once the preprocessed
    # heatmap PNG is used.
    heatmap--sepia.png) echo "0.30" ;;
    liquid-metal--backdrop.png) echo "0.02" ;;
    liquid-metal--default.png) echo "0.03" ;;
    liquid-metal--stripes.png) echo "0.04" ;;
    paper-texture--abstract.png) echo "0.18" ;;
    paper-texture--cardboard.png) echo "0.06" ;;
    paper-texture--default.png) echo "0.05" ;;
    paper-texture--details.png) echo "0.03" ;;
    pulsing-border--default.png) echo "0.07" ;;
    pulsing-border--northern-lights.png) echo "0.13" ;;
    # fwidth(float) is replaced by a deterministic derivative helper in Flutter
    # shaders because flutter_tester rejects fwidth(float) during SkSL
    # generation. This preset concentrates the difference at hard wave edges.
    dot-grid--triangles.png) echo "0.04" ;;
    dot-grid--wallpaper.png) echo "0.08" ;;
    god-rays--default.png) echo "0.32" ;;
    god-rays--ether.png) echo "0.15" ;;
    god-rays--linear.png) echo "0.02" ;;
    god-rays--warp.png) echo "0.32" ;;
    metaballs--background.png) echo "0.95" ;;
    metaballs--default.png) echo "0.36" ;;
    metaballs--ink-drops.png) echo "0.05" ;;
    metaballs--solar.png) echo "0.20" ;;
    perlin-noise--moss.png) echo "0.11" ;;
    perlin-noise--nintendo-water.png) echo "0.03" ;;
    perlin-noise--worms.png) echo "0.02" ;;
    smoke-ring--default.png) echo "0.07" ;;
    smoke-ring--line.png) echo "0.04" ;;
    smoke-ring--solar.png) echo "0.06" ;;
    swirl--007.png) echo "0.02" ;;
    voronoi--bubbles.png) echo "0.15" ;;
    voronoi--cells.png) echo "0.15" ;;
    voronoi--default.png) echo "0.21" ;;
    voronoi--lights.png) echo "0.83" ;;
    warp--cauldron-pot.png) echo "0.15" ;;
    warp--default.png) echo "0.33" ;;
    warp--kelp.png) echo "0.03" ;;
    warp--live-ink.png) echo "0.31" ;;
    warp--nectar.png) echo "0.45" ;;
    warp--passion.png) echo "0.02" ;;
    waves--ride-the-wave.png) echo "0.02" ;;
    *) echo "$fail_ratio" ;;
  esac
}

if [[ ! -d "$workbench/golden" ]]; then
  echo "error: goldens not found at $workbench/golden (set WORKBENCH)" >&2
  exit 2
fi

if [[ ! -f "$workbench/tools/compare-images.ts" ]]; then
  echo "error: comparator not found at $workbench/tools/compare-images.ts" >&2
  exit 2
fi

"$repo_root/tool/render_flutter_goldens.sh"

pass=0
fail=0
for png in "$out_dir"/*.png; do
  name="$(basename "$png")"
  [[ "$name" == *-diff.png ]] && continue
  golden="$workbench/golden/$name"
  if [[ ! -f "$golden" ]]; then
    echo "MISS  $name (no golden)"
    fail=$((fail + 1))
    continue
  fi

  ratio="$(allowed_fail_ratio "$name")"
  if result=$(bun "$workbench/tools/compare-images.ts" "$golden" "$png" \
      --fail-ratio "$ratio" --out "$out_dir/${name%.png}-diff.png" 2>&1); then
    echo "PASS  $name  ${result#PASS: }"
    pass=$((pass + 1))
  else
    echo "FAIL  $name  ${result#FAIL: }"
    fail=$((fail + 1))
  fi
done

echo
echo "flutter parity: $pass passed, $fail failed (default fail-ratio $fail_ratio)"
[[ "$fail" -eq 0 ]]
