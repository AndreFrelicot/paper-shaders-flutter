import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sampler.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Parameters used to render the smoke ring shader.
class SmokeRingParams {
  /// Creates smoke ring params.
  const SmokeRingParams({
    this.colorBack = '#000000',
    this.colors = const <String>['#ffffff'],
    this.thickness = 0.65,
    this.radius = 0.25,
    this.innerShape = 0.7,
    this.noiseScale = 3,
    this.noiseIterations = 8,
    this.sizing = const ShaderSizing(fit: ShaderFit.contain, scale: 0.8),
    this.speed = 0.5,
    this.frame = 0,
  });

  /// Color back.
  final String colorBack;

  /// Colors.
  final List<String> colors;

  /// Thickness.
  final double thickness;

  /// Radius.
  final double radius;

  /// Inner shape.
  final double innerShape;

  /// Noise scale.
  final double noiseScale;

  /// Noise iterations.
  final double noiseIterations;

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
      Float4ArrayUniform.colors(colors, capacity: 10),
      FloatUniform(colors.isEmpty ? 1 : colors.length.toDouble()),
      FloatUniform(thickness),
      FloatUniform(radius),
      FloatUniform(innerShape),
      FloatUniform(noiseScale),
      FloatUniform(noiseIterations),
    ];
  }
}

/// Named preset for the smoke ring shader.
class SmokeRingPreset {
  /// Creates smoke ring preset.
  const SmokeRingPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final SmokeRingParams params;
}

/// Catalog metadata for the smoke ring shader.
class SmokeRingShader {
  /// Creates smoke ring shader.
  const SmokeRingShader._();

  /// Static name value.
  static const name = 'smoke-ring';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/smoke_ring.frag';

  /// Static image samplers value.
  static const imageSamplers = <ShaderImageSampler>[
    ShaderImageSampler.noiseTexture,
  ];

  /// Static presets value.
  static const presets = <SmokeRingPreset>[
    SmokeRingPreset('Default', SmokeRingParams()),
    SmokeRingPreset(
      'Line',
      SmokeRingParams(
        colors: <String>['#4540a4', '#1fe8ff'],
        thickness: 0.01,
        radius: 0.38,
        innerShape: 0.88,
        noiseScale: 1.1,
        noiseIterations: 2,
        sizing: ShaderSizing(fit: ShaderFit.contain),
        speed: 4,
      ),
    ),
    SmokeRingPreset(
      'Solar',
      SmokeRingParams(
        colors: <String>['#ffffff', '#ffca0a', '#fc6203', '#fc620366'],
        thickness: 0.8,
        radius: 0.4,
        innerShape: 4,
        noiseScale: 2,
        noiseIterations: 3,
        sizing: ShaderSizing(fit: ShaderFit.contain, scale: 2, offsetY: 1),
        speed: 1,
      ),
    ),
    SmokeRingPreset(
      'Cloud',
      SmokeRingParams(
        colorBack: '#81ADEC',
        radius: 0.5,
        innerShape: 0.85,
        noiseIterations: 10,
        sizing: ShaderSizing(fit: ShaderFit.contain, scale: 2.5),
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

/// Widget that renders the smoke ring shader.
class SmokeRingView extends StatelessWidget {
  /// Creates smoke ring view.
  const SmokeRingView({this.params = const SmokeRingParams(), super.key});

  /// Params.
  final SmokeRingParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: SmokeRingShader.assetKey,
      uniforms: params.uniforms,
      imageSamplers: SmokeRingShader.imageSamplers,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}
