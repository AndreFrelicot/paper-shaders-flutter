import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Parameters used to render the neuro noise shader.
class NeuroNoiseParams {
  /// Creates neuro noise params.
  const NeuroNoiseParams({
    this.colorFront = '#ffffff',
    this.colorMid = '#47a6ff',
    this.colorBack = '#000000',
    this.brightness = 0.05,
    this.contrast = 0.3,
    this.sizing = const ShaderSizing(),
    this.speed = 1,
    this.frame = 0,
  });

  /// Color front.
  final String colorFront;

  /// Color mid.
  final String colorMid;

  /// Color back.
  final String colorBack;

  /// Brightness.
  final double brightness;

  /// Contrast.
  final double contrast;

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
      Float4Uniform.color(colorMid),
      Float4Uniform.color(colorBack),
      FloatUniform(brightness),
      FloatUniform(contrast),
    ];
  }
}

/// Named preset for the neuro noise shader.
class NeuroNoisePreset {
  /// Creates neuro noise preset.
  const NeuroNoisePreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final NeuroNoiseParams params;
}

/// Catalog metadata for the neuro noise shader.
class NeuroNoiseShader {
  /// Creates neuro noise shader.
  const NeuroNoiseShader._();

  /// Static name value.
  static const name = 'neuro-noise';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/neuro_noise.frag';

  /// Static presets value.
  static const presets = <NeuroNoisePreset>[
    NeuroNoisePreset('Default', NeuroNoiseParams()),
    NeuroNoisePreset(
      'Sensation',
      NeuroNoiseParams(
        colorFront: '#00c8ff',
        colorMid: '#fbff00',
        colorBack: '#8b42ff',
        brightness: 0.19,
        contrast: 0.12,
        sizing: ShaderSizing(scale: 3),
      ),
    ),
    NeuroNoisePreset(
      'Bloodstream',
      NeuroNoiseParams(
        colorFront: '#ff0000',
        colorMid: '#ff0000',
        colorBack: '#ffffff',
        brightness: 0.24,
        contrast: 0.17,
        sizing: ShaderSizing(scale: 0.7),
      ),
    ),
    NeuroNoisePreset(
      'Ghost',
      NeuroNoiseParams(
        colorMid: '#000000',
        colorBack: '#ffffff',
        brightness: 0,
        contrast: 1,
        sizing: ShaderSizing(scale: 0.55),
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

/// Widget that renders the neuro noise shader.
class NeuroNoiseView extends StatelessWidget {
  /// Creates neuro noise view.
  const NeuroNoiseView({this.params = const NeuroNoiseParams(), super.key});

  /// Params.
  final NeuroNoiseParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: NeuroNoiseShader.assetKey,
      uniforms: params.uniforms,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}
