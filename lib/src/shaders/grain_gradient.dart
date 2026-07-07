import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sampler.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Options for grain gradient shape.
enum GrainGradientShape {
  wave(1),
  dots(2),
  truchet(3),
  corners(4),
  ripple(5),
  blob(6),
  sphere(7);

  /// Creates grain gradient shape.
  const GrainGradientShape(this.uniformValue);

  /// Uniform value.
  final double uniformValue;
}

/// Parameters used to render the grain gradient shader.
class GrainGradientParams {
  /// Creates grain gradient params.
  const GrainGradientParams({
    this.colorBack = '#000000',
    this.colors = const <String>['#7300ff', '#eba8ff', '#00bfff', '#2a00ff'],
    this.softness = 0.5,
    this.intensity = 0.5,
    this.noise = 0.25,
    this.shape = GrainGradientShape.corners,
    this.sizing = const ShaderSizing.pattern(fit: ShaderFit.contain),
    this.speed = 1,
    this.frame = 0,
  });

  /// Color back.
  final String colorBack;

  /// Colors.
  final List<String> colors;

  /// Softness.
  final double softness;

  /// Intensity.
  final double intensity;

  /// Noise.
  final double noise;

  /// Shape.
  final GrainGradientShape shape;

  /// Sizing.
  final ShaderSizing sizing;

  /// Speed.
  final double speed;

  /// Frame.
  final double frame;

  /// Uniform values packed in the shader declaration order.
  List<ShaderUniform> get uniforms {
    return <ShaderUniform>[
      Float4Uniform.color(colorBack),
      Float4ArrayUniform.colors(colors, capacity: 7),
      FloatUniform(colors.isEmpty ? 1 : colors.length.toDouble()),
      FloatUniform(softness),
      FloatUniform(intensity),
      FloatUniform(noise),
      FloatUniform(shape.uniformValue),
    ];
  }
}

/// Named preset for the grain gradient shader.
class GrainGradientPreset {
  /// Creates grain gradient preset.
  const GrainGradientPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final GrainGradientParams params;
}

/// Catalog metadata for the grain gradient shader.
class GrainGradientShader {
  /// Creates grain gradient shader.
  const GrainGradientShader._();

  /// Static name value.
  static const name = 'grain-gradient';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/grain_gradient.frag';

  /// Static image samplers value.
  static const imageSamplers = <ShaderImageSampler>[
    ShaderImageSampler.noiseTexture,
  ];

  /// Static presets value.
  static const presets = <GrainGradientPreset>[
    GrainGradientPreset('Default', GrainGradientParams()),
    GrainGradientPreset(
      'Wave',
      GrainGradientParams(
        colorBack: '#000a0f',
        colors: <String>['#c4730b', '#bdad5f', '#d8ccc7'],
        softness: 0.7,
        intensity: 0.15,
        noise: 0.5,
        shape: GrainGradientShape.wave,
      ),
    ),
    GrainGradientPreset(
      'Dots',
      GrainGradientParams(
        colorBack: '#0a0000',
        colors: <String>['#6f0000', '#0080ff', '#f2ebc9', '#33cc33'],
        softness: 1,
        intensity: 1,
        noise: 0.7,
        shape: GrainGradientShape.dots,
        sizing: ShaderSizing.pattern(scale: 0.6),
      ),
    ),
    GrainGradientPreset(
      'Truchet',
      GrainGradientParams(
        colorBack: '#0a0000',
        colors: <String>['#6f2200', '#eabb7c', '#39b523'],
        softness: 0,
        intensity: 0.2,
        noise: 1,
        shape: GrainGradientShape.truchet,
      ),
    ),
    GrainGradientPreset(
      'Ripple',
      GrainGradientParams(
        colorBack: '#140a00',
        colors: <String>['#6f2d00', '#88ddae', '#2c0b1d'],
        softness: 0.5,
        intensity: 0.5,
        noise: 0.5,
        shape: GrainGradientShape.ripple,
        sizing: ShaderSizing.pattern(fit: ShaderFit.contain, scale: 0.5),
      ),
    ),
    GrainGradientPreset(
      'Blob',
      GrainGradientParams(
        colorBack: '#0f0e18',
        colors: <String>['#3e6172', '#a49b74', '#568c50'],
        softness: 0,
        intensity: 0.15,
        noise: 0.5,
        shape: GrainGradientShape.blob,
        sizing: ShaderSizing.pattern(fit: ShaderFit.contain, scale: 1.3),
      ),
    ),
  ];

  /// Static catalog entry value.
  static final catalogEntry = ShaderCatalogEntry(
    name: name,
    assetKey: assetKey,
    imageSamplers: imageSamplers,
    presets: presets
        .map((preset) {
          return ShaderPreset(
            name: preset.name,
            sizing: preset.params.sizing,
            uniforms: preset.params.uniforms,
            speed: preset.params.speed,
            frame: preset.params.frame,
          );
        })
        .toList(growable: false),
  );
}

/// Widget that renders the grain gradient shader.
class GrainGradientView extends StatelessWidget {
  /// Creates grain gradient view.
  const GrainGradientView({
    this.params = const GrainGradientParams(),
    super.key,
  });

  /// Params.
  final GrainGradientParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: GrainGradientShader.assetKey,
      uniforms: params.uniforms,
      imageSamplers: GrainGradientShader.imageSamplers,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}
