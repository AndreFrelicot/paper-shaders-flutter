import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sampler.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Parameters used to render the dot orbit shader.
class DotOrbitParams {
  /// Creates dot orbit params.
  const DotOrbitParams({
    this.colorBack = '#000000',
    this.colors = const <String>[
      '#ffc96b',
      '#ff6200',
      '#ff2f00',
      '#421100',
      '#1a0000',
    ],
    this.stepsPerColor = 4,
    this.size = 1,
    this.sizeRange = 0,
    this.spreading = 1,
    this.sizing = const ShaderSizing.pattern(scale: 1),
    this.speed = 1.5,
    this.frame = 0,
  });

  /// Color back.
  final String colorBack;

  /// Colors.
  final List<String> colors;

  /// Steps per color.
  final double stepsPerColor;

  /// Size.
  final double size;

  /// Size range.
  final double sizeRange;

  /// Spreading.
  final double spreading;

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
      FloatUniform(stepsPerColor),
      FloatUniform(size),
      FloatUniform(sizeRange),
      FloatUniform(spreading),
    ];
  }
}

/// Named preset for the dot orbit shader.
class DotOrbitPreset {
  /// Creates dot orbit preset.
  const DotOrbitPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final DotOrbitParams params;
}

/// Catalog metadata for the dot orbit shader.
class DotOrbitShader {
  /// Creates dot orbit shader.
  const DotOrbitShader._();

  /// Static name value.
  static const name = 'dot-orbit';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/dot_orbit.frag';

  /// Static image samplers value.
  static const imageSamplers = <ShaderImageSampler>[
    ShaderImageSampler.noiseTexture,
  ];

  /// Static presets value.
  static const presets = <DotOrbitPreset>[
    DotOrbitPreset('Default', DotOrbitParams()),
    DotOrbitPreset(
      'Bubbles',
      DotOrbitParams(
        colorBack: '#989CA4',
        colors: <String>['#D0D2D5'],
        stepsPerColor: 2,
        size: 0.9,
        sizeRange: 0.7,
        spreading: 1,
        sizing: ShaderSizing.pattern(scale: 1.64),
        speed: 0.4,
      ),
    ),
    DotOrbitPreset(
      'Shine',
      DotOrbitParams(
        colorBack: '#000000',
        colors: <String>['#ffffff', '#006aff', '#fff675'],
        stepsPerColor: 4,
        size: 0.3,
        sizeRange: 0.2,
        spreading: 1,
        sizing: ShaderSizing.pattern(scale: 0.4),
        speed: 0.1,
      ),
    ),
    DotOrbitPreset(
      'Hallucinatory',
      DotOrbitParams(
        colorBack: '#ffe500',
        colors: <String>['#000000'],
        stepsPerColor: 2,
        size: 0.65,
        sizeRange: 0,
        spreading: 0.3,
        sizing: ShaderSizing.pattern(scale: 0.5),
        speed: 5,
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

/// Widget that renders the dot orbit shader.
class DotOrbitView extends StatelessWidget {
  /// Creates dot orbit view.
  const DotOrbitView({this.params = const DotOrbitParams(), super.key});

  /// Params.
  final DotOrbitParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: DotOrbitShader.assetKey,
      uniforms: params.uniforms,
      imageSamplers: DotOrbitShader.imageSamplers,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}
