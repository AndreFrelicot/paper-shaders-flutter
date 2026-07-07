import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Parameters used to render the perlin noise shader.
class PerlinNoiseParams {
  /// Creates perlin noise params.
  const PerlinNoiseParams({
    this.colorFront = '#fccff7',
    this.colorBack = '#632ad5',
    this.proportion = 0.35,
    this.softness = 0.1,
    this.octaveCount = 1,
    this.persistence = 1,
    this.lacunarity = 1.5,
    this.sizing = const ShaderSizing(),
    this.speed = 0.5,
    this.frame = 0,
  });

  /// Color front.
  final String colorFront;

  /// Color back.
  final String colorBack;

  /// Proportion.
  final double proportion;

  /// Softness.
  final double softness;

  /// Octave count.
  final double octaveCount;

  /// Persistence.
  final double persistence;

  /// Lacunarity.
  final double lacunarity;

  /// Sizing.
  final ShaderSizing sizing;

  /// Speed.
  final double speed;

  /// Frame.
  final double frame;

  /// Uniform values packed in the shader declaration order.
  List<ShaderUniform> get uniforms {
    return <ShaderUniform>[
      Float4Uniform.color(colorFront),
      Float4Uniform.color(colorBack),
      FloatUniform(proportion),
      FloatUniform(softness),
      FloatUniform(octaveCount),
      FloatUniform(persistence),
      FloatUniform(lacunarity),
    ];
  }
}

/// Named preset for the perlin noise shader.
class PerlinNoisePreset {
  /// Creates perlin noise preset.
  const PerlinNoisePreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final PerlinNoiseParams params;
}

/// Catalog metadata for the perlin noise shader.
class PerlinNoiseShader {
  /// Creates perlin noise shader.
  const PerlinNoiseShader._();

  /// Static name value.
  static const name = 'perlin-noise';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/perlin_noise.frag';

  /// Static presets value.
  static const presets = <PerlinNoisePreset>[
    PerlinNoisePreset('Default', PerlinNoiseParams()),
    PerlinNoisePreset(
      'Nintendo Water',
      PerlinNoiseParams(
        colorFront: '#d1eefc',
        colorBack: '#2d69d4',
        proportion: 0.42,
        softness: 0,
        octaveCount: 2,
        persistence: 0.55,
        lacunarity: 1.8,
        sizing: ShaderSizing(scale: 5),
        speed: 0.4,
      ),
    ),
    PerlinNoisePreset(
      'Moss',
      PerlinNoiseParams(
        colorFront: '#262626',
        colorBack: '#05ff4a',
        proportion: 0.65,
        softness: 0.35,
        octaveCount: 6,
        lacunarity: 2.55,
        sizing: ShaderSizing(scale: 6.666666666666667),
        speed: 0.02,
      ),
    ),
    PerlinNoisePreset(
      'Worms',
      PerlinNoiseParams(
        colorFront: '#595959',
        colorBack: '#ffffff00',
        proportion: 0.5,
        softness: 0,
        sizing: ShaderSizing(scale: 0.9),
        speed: 0,
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

/// Widget that renders the perlin noise shader.
class PerlinNoiseView extends StatelessWidget {
  /// Creates perlin noise view.
  const PerlinNoiseView({this.params = const PerlinNoiseParams(), super.key});

  /// Params.
  final PerlinNoiseParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: PerlinNoiseShader.assetKey,
      uniforms: params.uniforms,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}
