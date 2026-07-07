# Flutter Port Status

Current status:

- Shaders ported: 29/29
- Catalogue entries: 29
- Public shader wrappers: 29
- Fragment shader assets declared in `pubspec.yaml`: 29
- Golden parity presets: 120/120 passing
- Package validation: `flutter pub publish --dry-run`

Validation commands:

```sh
flutter analyze
flutter test
cd example && flutter analyze
tool/check_flutter_parity.sh
flutter pub publish --dry-run
```

Shader catalogue:

- `simplex-noise`
- `dot-orbit`
- `mesh-gradient`
- `waves`
- `pulsing-border`
- `halftone-cmyk`
- `paper-texture`
- `grain-gradient`
- `gem-smoke`
- `halftone-dots`
- `heatmap`
- `image-dithering`
- `liquid-metal`
- `color-panels`
- `dithering`
- `dot-grid`
- `god-rays`
- `metaballs`
- `neuro-noise`
- `perlin-noise`
- `smoke-ring`
- `spiral`
- `static-mesh-gradient`
- `static-radial-gradient`
- `swirl`
- `voronoi`
- `warp`
- `water`
- `fluted-glass`

Known Flutter parity constraints:

- `flutter_tester` rejects `fwidth(float)` in generated SkSL, so ports use the
  deterministic `ps_pixelDerivative()` helper for local golden compatibility.
  `spiral` uses a deterministic local finite-difference approximation instead
  because its default preset needs local anti-aliasing in pattern space.
- Flutter runtime shaders do not expose explicit mipmapped image sampling. Some
  image and noise-texture presets therefore need local, preset-specific golden
  thresholds.
- Dynamic uniform-array indexing is avoided by constant-index helper functions
  for `vec4[10]` color arrays.

See `doc/FLUTTER-GOLDEN-PARITY.md` for the preset-level parity thresholds and
their rationale.
