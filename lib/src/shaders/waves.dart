import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Parameters used to render the waves shader.
class WavesParams {
  /// Creates waves params.
  const WavesParams({
    this.colorFront = '#ffbb00',
    this.colorBack = '#000000',
    this.shape = 0,
    this.frequency = 0.5,
    this.amplitude = 0.5,
    this.spacing = 1.2,
    this.proportion = 0.1,
    this.softness = 0,
    this.sizing = const ShaderSizing.pattern(scale: 0.6),
    this.speed = 0,
    this.frame = 0,
  });

  /// Color front.
  final String colorFront;

  /// Color back.
  final String colorBack;

  /// Shape.
  final double shape;

  /// Frequency.
  final double frequency;

  /// Amplitude.
  final double amplitude;

  /// Spacing.
  final double spacing;

  /// Proportion.
  final double proportion;

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
      Float4Uniform.color(colorFront),
      Float4Uniform.color(colorBack),
      FloatUniform(shape),
      FloatUniform(frequency),
      FloatUniform(amplitude),
      FloatUniform(spacing),
      FloatUniform(proportion),
      FloatUniform(softness),
    ];
  }
}

/// Named preset for the waves shader.
class WavesPreset {
  /// Creates waves preset.
  const WavesPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final WavesParams params;
}

/// Catalog metadata for the waves shader.
class WavesShader {
  /// Creates waves shader.
  const WavesShader._();

  /// Static name value.
  static const name = 'waves';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/waves.frag';

  /// Static presets value.
  static const presets = <WavesPreset>[
    WavesPreset('Default', WavesParams()),
    WavesPreset(
      'Groovy',
      WavesParams(
        colorFront: '#fcfcee',
        colorBack: '#ff896b',
        shape: 3,
        frequency: 0.2,
        amplitude: 0.25,
        spacing: 1.17,
        proportion: 0.57,
        sizing: ShaderSizing.pattern(scale: 5, rotation: 90),
      ),
    ),
    WavesPreset(
      'Tangled up',
      WavesParams(
        colorFront: '#133a41',
        colorBack: '#c2d8b6',
        shape: 2.07,
        frequency: 0.44,
        amplitude: 0.57,
        spacing: 1.05,
        proportion: 0.75,
        sizing: ShaderSizing.pattern(scale: 0.5),
      ),
    ),
    WavesPreset(
      'Ride the wave',
      WavesParams(
        colorFront: '#fdffe6',
        colorBack: '#1f1f1f',
        shape: 2.25,
        frequency: 0.2,
        amplitude: 1,
        spacing: 1.25,
        proportion: 1,
        sizing: ShaderSizing.pattern(scale: 1.7),
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

/// Widget that renders the waves shader.
class WavesView extends StatelessWidget {
  /// Creates waves view.
  const WavesView({this.params = const WavesParams(), super.key});

  /// Params.
  final WavesParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: WavesShader.assetKey,
      uniforms: params.uniforms,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}
