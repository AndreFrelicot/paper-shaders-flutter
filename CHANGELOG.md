## 0.0.2

- Optimized the `perlin-noise` shader by avoiding extra noise samples for
  Flutter antialiasing, improving heavy presets such as Moss.

## 0.0.1

- Initial Flutter runtime shader port of the 29 Paper Shaders effects.
- Added typed parameter objects, shader widgets, presets, catalogue entries,
  shader assets, and image/noise sampler assets.
- Added local shader compilation tests and deterministic golden parity tooling
  for 120 upstream preset renders.
