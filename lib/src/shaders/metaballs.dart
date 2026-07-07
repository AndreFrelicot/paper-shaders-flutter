import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sampler.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Parameters used to render the metaballs shader.
class MetaballsParams {
  /// Creates metaballs params.
  const MetaballsParams({
    this.colorBack = '#000000',
    this.colors = const <String>[
      '#6e33cc',
      '#ff5500',
      '#ffc105',
      '#ffc800',
      '#f585ff',
    ],
    this.size = 0.83,
    this.count = 10,
    this.sizing = const ShaderSizing(fit: ShaderFit.contain),
    this.speed = 1,
    this.frame = 0,
  });

  /// Color back.
  final String colorBack;

  /// Colors.
  final List<String> colors;

  /// Size.
  final double size;

  /// Count.
  final double count;

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
      Float4ArrayUniform.colors(colors, capacity: 8),
      FloatUniform(colors.isEmpty ? 1 : colors.length.toDouble()),
      FloatUniform(size),
      FloatUniform(count),
    ];
  }
}

/// Named preset for the metaballs shader.
class MetaballsPreset {
  /// Creates metaballs preset.
  const MetaballsPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final MetaballsParams params;
}

/// Catalog metadata for the metaballs shader.
class MetaballsShader {
  /// Creates metaballs shader.
  const MetaballsShader._();

  /// Static name value.
  static const name = 'metaballs';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/metaballs.frag';

  /// Static image samplers value.
  static const imageSamplers = <ShaderImageSampler>[
    ShaderImageSampler.noiseTexture,
  ];

  /// Static presets value.
  static const presets = <MetaballsPreset>[
    MetaballsPreset('Default', MetaballsParams()),
    MetaballsPreset(
      'Ink Drops',
      MetaballsParams(
        colorBack: '#ffffff00',
        colors: <String>['#000000'],
        size: 0.1,
        count: 18,
        speed: 2,
      ),
    ),
    MetaballsPreset(
      'Solar',
      MetaballsParams(
        colorBack: '#102f84',
        colors: <String>['#ffc800', '#ff5500', '#ffc105'],
        size: 0.75,
        count: 7,
      ),
    ),
    MetaballsPreset(
      'Background',
      MetaballsParams(
        colorBack: '#2a273f',
        colors: <String>['#ae00ff', '#00ff95', '#ffc105'],
        size: 0.81,
        count: 13,
        sizing: ShaderSizing(fit: ShaderFit.contain, scale: 4, offsetX: -0.3),
        speed: 0.5,
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

/// Widget that renders the metaballs shader.
class MetaballsView extends StatelessWidget {
  /// Creates metaballs view.
  const MetaballsView({this.params = const MetaballsParams(), super.key});

  /// Params.
  final MetaballsParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: MetaballsShader.assetKey,
      uniforms: params.uniforms,
      imageSamplers: MetaballsShader.imageSamplers,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}
