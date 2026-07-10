import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Parameters used to render the static radial gradient shader.
class StaticRadialGradientParams {
  /// Creates static radial gradient params.
  const StaticRadialGradientParams({
    this.colorBack = '#000000',
    this.colors = const <String>['#00bbff', '#00ffe1', '#ffffff'],
    this.radius = 0.8,
    this.focalDistance = 0.99,
    this.focalAngle = 0,
    this.falloff = 0.24,
    this.mixing = 0.5,
    this.distortion = 0,
    this.distortionShift = 0,
    this.distortionFreq = 12,
    this.grainMixer = 0,
    this.grainOverlay = 0,
    this.sizing = const ShaderSizing(fit: ShaderFit.contain),
    this.speed = 0,
    this.frame = 0,
  });

  /// Color back.
  final String colorBack;

  /// Colors.
  final List<String> colors;

  /// Radius.
  final double radius;

  /// Focal distance.
  final double focalDistance;

  /// Focal angle.
  final double focalAngle;

  /// Falloff.
  final double falloff;

  /// Mixing.
  final double mixing;

  /// Distortion.
  final double distortion;

  /// Distortion shift.
  final double distortionShift;

  /// Distortion freq.
  final double distortionFreq;

  /// Grain mixer.
  final double grainMixer;

  /// Grain overlay.
  final double grainOverlay;

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
      FloatUniform(radius),
      FloatUniform(focalDistance),
      FloatUniform(focalAngle),
      FloatUniform(falloff),
      FloatUniform(mixing),
      FloatUniform(distortion),
      FloatUniform(distortionShift),
      FloatUniform(distortionFreq),
      FloatUniform(grainMixer),
      FloatUniform(grainOverlay),
    ];
  }
}

/// Named preset for the static radial gradient shader.
class StaticRadialGradientPreset {
  /// Creates static radial gradient preset.
  const StaticRadialGradientPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final StaticRadialGradientParams params;
}

/// Catalog metadata for the static radial gradient shader.
class StaticRadialGradientShader {
  /// Creates static radial gradient shader.
  const StaticRadialGradientShader._();

  /// Static name value.
  static const name = 'static-radial-gradient';

  /// Static asset key value.
  static const assetKey =
      'packages/paper_shaders/shaders/static_radial_gradient.frag';
  static const isAnimated = false;

  /// Static presets value.
  static const presets = <StaticRadialGradientPreset>[
    StaticRadialGradientPreset('Default', StaticRadialGradientParams()),
    StaticRadialGradientPreset(
      'Lo-Fi',
      StaticRadialGradientParams(
        colorBack: '#2e1f27',
        colors: <String>['#d72638', '#3f88c5', '#f49d37'],
        radius: 1,
        focalDistance: 0,
        falloff: 0.9,
        mixing: 0.7,
        grainMixer: 1,
        grainOverlay: 0.5,
      ),
    ),
    StaticRadialGradientPreset(
      'Cross Section',
      StaticRadialGradientParams(
        colorBack: '#3d348b',
        colors: <String>['#7678ed', '#f7b801', '#f18701', '#37a066'],
        radius: 1,
        focalDistance: 0,
        falloff: 0,
        mixing: 0,
        distortion: 1,
      ),
    ),
    StaticRadialGradientPreset(
      'Radial',
      StaticRadialGradientParams(
        colorBack: '#264653',
        colors: <String>['#9c2b2b', '#f4a261', '#ffffff'],
        radius: 1,
        focalDistance: 0,
        falloff: 0,
        mixing: 1,
      ),
    ),
  ];

  /// Static catalog entry value.
  static final catalogEntry = ShaderCatalogEntry(
    name: name,
    assetKey: assetKey,
    isAnimated: isAnimated,
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

/// Widget that renders the static radial gradient shader.
class StaticRadialGradientView extends StatelessWidget {
  /// Creates static radial gradient view.
  const StaticRadialGradientView({
    this.params = const StaticRadialGradientParams(),
    super.key,
  });

  /// Params.
  final StaticRadialGradientParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: StaticRadialGradientShader.assetKey,
      isAnimated: StaticRadialGradientShader.isAnimated,
      uniforms: params.uniforms,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}
