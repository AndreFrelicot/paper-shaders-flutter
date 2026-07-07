/// Shader image sampler.
class ShaderImageSampler {
  /// Creates shader image sampler.
  const ShaderImageSampler(this.assetKey);

  /// Static noise texture value.
  static const noiseTexture = ShaderImageSampler(
    'packages/paper_shaders/assets/noise.png',
  );

  /// Static test image value.
  static const testImage = ShaderImageSampler(
    'packages/paper_shaders/assets/test_image.webp',
  );

  /// Static flowers image value.
  static const flowersImage = ShaderImageSampler(
    'packages/paper_shaders/assets/flowers.webp',
  );

  /// Static gem smoke image value.
  static const gemSmokeImage = ShaderImageSampler(
    'packages/paper_shaders/assets/gem_smoke.png',
  );

  /// Static heatmap image value.
  static const heatmapImage = ShaderImageSampler(
    'packages/paper_shaders/assets/heatmap.png',
  );

  /// Static liquid metal image value.
  static const liquidMetalImage = ShaderImageSampler(
    'packages/paper_shaders/assets/liquid_metal.png',
  );

  /// Asset key.
  final String assetKey;
}
