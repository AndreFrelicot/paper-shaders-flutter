import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sampler.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Parameters used to render the heatmap shader.
class HeatmapParams {
  /// Creates heatmap params.
  const HeatmapParams({
    this.colors = const <String>[
      '#11206a',
      '#1f3ba2',
      '#2f63e7',
      '#6bd7ff',
      '#ffe679',
      '#ff991e',
      '#ff4c00',
    ],
    this.colorBack = '#000000',
    this.angle = 0,
    this.noise = 0,
    this.innerGlow = 0.5,
    this.outerGlow = 0.5,
    this.contour = 0.5,
    this.sizing = const ShaderSizing.object(
      fit: ShaderFit.contain,
      scale: 0.75,
      imageAspectRatio: _heatmapImageAspectRatio,
    ),
    this.speed = 1,
    this.frame = 0,
  });

  /// Colors.
  final List<String> colors;

  /// Color back.
  final String colorBack;

  /// Angle.
  final double angle;

  /// Noise.
  final double noise;

  /// Inner glow.
  final double innerGlow;

  /// Outer glow.
  final double outerGlow;

  /// Contour.
  final double contour;

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
      FloatUniform(angle),
      FloatUniform(noise),
      FloatUniform(innerGlow),
      FloatUniform(outerGlow),
      FloatUniform(contour),
    ];
  }
}

/// Named preset for the heatmap shader.
class HeatmapPreset {
  /// Creates heatmap preset.
  const HeatmapPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final HeatmapParams params;
}

/// Catalog metadata for the heatmap shader.
class HeatmapShader {
  /// Creates heatmap shader.
  const HeatmapShader._();

  /// Static name value.
  static const name = 'heatmap';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/heatmap.frag';

  /// Static image samplers value.
  static const imageSamplers = <ShaderImageSampler>[
    ShaderImageSampler.heatmapImage,
  ];

  /// Static presets value.
  static const presets = <HeatmapPreset>[
    HeatmapPreset('Default', HeatmapParams()),
    HeatmapPreset(
      'Sepia',
      HeatmapParams(
        colors: <String>['#997F45', '#ffffff'],
        noise: 0.75,
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

/// Widget that renders the heatmap shader.
class HeatmapView extends StatelessWidget {
  /// Creates heatmap view.
  const HeatmapView({this.params = const HeatmapParams(), super.key});

  /// Params.
  final HeatmapParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: HeatmapShader.assetKey,
      uniforms: params.uniforms,
      imageSamplers: HeatmapShader.imageSamplers,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}

const double _heatmapImageAspectRatio = 1750 / 1499;
