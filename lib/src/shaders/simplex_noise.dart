import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Parameters used to render the simplex noise shader.
class SimplexNoiseParams {
  /// Creates simplex noise params.
  const SimplexNoiseParams({
    this.colors = const <String>[
      '#4449CF',
      '#FFD1E0',
      '#F94446',
      '#FFD36B',
      '#FFFFFF',
    ],
    this.stepsPerColor = 2,
    this.softness = 0,
    this.sizing = const ShaderSizing.pattern(scale: 0.6),
    this.speed = 0.5,
    this.frame = 0,
  });

  /// Colors.
  final List<String> colors;

  /// Steps per color.
  final double stepsPerColor;

  /// Softness.
  final double softness;

  /// Sizing.
  final ShaderSizing sizing;

  /// Speed.
  final double speed;

  /// Frame.
  final double frame;

  /// Uniform values packed in the shader declaration order.
  List<ShaderUniform> get uniforms {
    return <ShaderUniform>[
      Float4ArrayUniform.colors(colors, capacity: 10),
      FloatUniform(colors.isEmpty ? 1 : colors.length.toDouble()),
      FloatUniform(stepsPerColor),
      FloatUniform(softness),
    ];
  }
}

/// Named preset for the simplex noise shader.
class SimplexNoisePreset {
  /// Creates simplex noise preset.
  const SimplexNoisePreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final SimplexNoiseParams params;
}

/// Catalog metadata for the simplex noise shader.
class SimplexNoiseShader {
  /// Creates simplex noise shader.
  const SimplexNoiseShader._();

  /// Static name value.
  static const name = 'simplex-noise';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/simplex_noise.frag';

  /// Static presets value.
  static const presets = <SimplexNoisePreset>[
    SimplexNoisePreset('Default', SimplexNoiseParams()),
    SimplexNoisePreset(
      'Spots',
      SimplexNoiseParams(
        colors: <String>['#ff7b00', '#f9ffeb', '#320d82'],
        stepsPerColor: 1,
        sizing: ShaderSizing.pattern(scale: 1),
        speed: 0.6,
      ),
    ),
    SimplexNoisePreset(
      'First contact',
      SimplexNoiseParams(
        colors: <String>['#e8cce6', '#120d22', '#442c44', '#e6baba', '#fff5f5'],
        stepsPerColor: 2,
        sizing: ShaderSizing.pattern(scale: 0.2),
        speed: 2,
      ),
    ),
    SimplexNoisePreset(
      'Bubblegum',
      SimplexNoiseParams(
        colors: <String>['#ffffff', '#ff9e9e', '#5f57ff', '#00f7ff'],
        stepsPerColor: 1,
        softness: 1,
        sizing: ShaderSizing.pattern(scale: 1.6),
        speed: 2,
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

/// Widget that renders the simplex noise shader.
class SimplexNoiseView extends StatelessWidget {
  /// Creates simplex noise view.
  const SimplexNoiseView({this.params = const SimplexNoiseParams(), super.key});

  /// Params.
  final SimplexNoiseParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: SimplexNoiseShader.assetKey,
      uniforms: params.uniforms,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}
