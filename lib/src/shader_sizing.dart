/// Options for shader fit.
enum ShaderFit {
  none(0),
  contain(1),
  cover(2);

  /// Creates shader fit.
  const ShaderFit(this.uniformValue);

  /// Uniform value.
  final double uniformValue;
}

/// Shader sizing.
class ShaderSizing {
  /// Creates shader sizing.
  const ShaderSizing({
    this.fit = ShaderFit.none,
    this.scale = 1,
    this.rotation = 0,
    this.originX = 0.5,
    this.originY = 0.5,
    this.offsetX = 0,
    this.offsetY = 0,
    this.worldWidth = 0,
    this.worldHeight = 0,
    this.imageAspectRatio = 1,
  });

  /// Creates shader sizing.
  const ShaderSizing.object({
    this.fit = ShaderFit.none,
    this.scale = 1,
    this.rotation = 0,
    this.originX = 0.5,
    this.originY = 0.5,
    this.offsetX = 0,
    this.offsetY = 0,
    this.worldWidth = 0,
    this.worldHeight = 0,
    this.imageAspectRatio = 1,
  });

  /// Creates shader sizing.
  const ShaderSizing.pattern({
    this.fit = ShaderFit.none,
    this.scale = 1,
    this.rotation = 0,
    this.originX = 0.5,
    this.originY = 0.5,
    this.offsetX = 0,
    this.offsetY = 0,
    this.worldWidth = 0,
    this.worldHeight = 0,
    this.imageAspectRatio = 1,
  });

  /// Fit.
  final ShaderFit fit;

  /// Scale.
  final double scale;

  /// Rotation.
  final double rotation;

  /// Origin x.
  final double originX;

  /// Origin y.
  final double originY;

  /// Offset x.
  final double offsetX;

  /// Offset y.
  final double offsetY;

  /// World width.
  final double worldWidth;

  /// World height.
  final double worldHeight;

  /// Image aspect ratio.
  final double imageAspectRatio;
}
