import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Parameters used to render the swirl shader.
class SwirlParams {
  /// Creates swirl params.
  const SwirlParams({
    this.colorBack = '#330000',
    this.colors = const <String>['#ffd1d1', '#ff8a8a', '#660000'],
    this.bandCount = 4,
    this.twist = 0.1,
    this.center = 0.2,
    this.proportion = 0.5,
    this.softness = 0,
    this.noise = 0.2,
    this.noiseFrequency = 0.4,
    this.sizing = const ShaderSizing(fit: ShaderFit.contain),
    this.speed = 0.32,
    this.frame = 0,
  });

  /// Color back.
  final String colorBack;

  /// Colors.
  final List<String> colors;

  /// Band count.
  final double bandCount;

  /// Twist.
  final double twist;

  /// Center.
  final double center;

  /// Proportion.
  final double proportion;

  /// Softness.
  final double softness;

  /// Noise.
  final double noise;

  /// Noise frequency.
  final double noiseFrequency;

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
      FloatUniform(bandCount),
      FloatUniform(twist),
      FloatUniform(center),
      FloatUniform(proportion),
      FloatUniform(softness),
      FloatUniform(noise),
      FloatUniform(noiseFrequency),
    ];
  }
}

/// Named preset for the swirl shader.
class SwirlPreset {
  /// Creates swirl preset.
  const SwirlPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final SwirlParams params;
}

/// Catalog metadata for the swirl shader.
class SwirlShader {
  /// Creates swirl shader.
  const SwirlShader._();

  /// Static name value.
  static const name = 'swirl';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/swirl.frag';

  /// Static presets value.
  static const presets = <SwirlPreset>[
    SwirlPreset('Default', SwirlParams()),
    SwirlPreset(
      '007',
      SwirlParams(
        colorBack: '#E9E7DA',
        colors: <String>['#000000'],
        bandCount: 5,
        twist: 0.3,
        center: 0,
        proportion: 0,
        noise: 0,
        noiseFrequency: 0.5,
        speed: 1,
      ),
    ),
    SwirlPreset(
      'Opening',
      SwirlParams(
        colorBack: '#ff8b61',
        colors: <String>['#fefff0', '#ffd8bd', '#ff8b61'],
        bandCount: 2,
        twist: 0.3,
        noise: 0,
        noiseFrequency: 0,
        sizing: ShaderSizing(fit: ShaderFit.contain, offsetX: -0.4, offsetY: 1),
        speed: 0.5,
      ),
    ),
    SwirlPreset(
      'Candy',
      SwirlParams(
        colorBack: '#ffcd66',
        colors: <String>['#6bbceb', '#d7b3ff', '#ff9fff'],
        bandCount: 2,
        twist: 0.15,
        softness: 1,
        noise: 0,
        noiseFrequency: 0.5,
        speed: 1,
      ),
    ),
  ];

  /// Static catalog entry value.
  static final catalogEntry = ShaderCatalogEntry(
    name: name,
    assetKey: assetKey,
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

/// Widget that renders the swirl shader.
class SwirlView extends StatelessWidget {
  /// Creates swirl view.
  const SwirlView({this.params = const SwirlParams(), super.key});

  /// Params.
  final SwirlParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: SwirlShader.assetKey,
      uniforms: params.uniforms,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}
