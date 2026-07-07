import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sampler.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Parameters used to render the voronoi shader.
class VoronoiParams {
  /// Creates voronoi params.
  const VoronoiParams({
    this.colors = const <String>['#ff8247', '#ffe53d'],
    this.stepsPerColor = 3,
    this.colorGlow = '#ffffff',
    this.colorGap = '#2e0000',
    this.distortion = 0.4,
    this.gap = 0.04,
    this.glow = 0,
    this.sizing = const ShaderSizing(scale: 0.5),
    this.speed = 0.5,
    this.frame = 0,
  });

  /// Colors.
  final List<String> colors;

  /// Steps per color.
  final double stepsPerColor;

  /// Color glow.
  final String colorGlow;

  /// Color gap.
  final String colorGap;

  /// Distortion.
  final double distortion;

  /// Gap.
  final double gap;

  /// Glow.
  final double glow;

  /// Sizing.
  final ShaderSizing sizing;

  /// Speed.
  final double speed;

  /// Frame.
  final double frame;

  /// Uniform values packed in the shader declaration order.
  List<ShaderUniform> get uniforms {
    return <ShaderUniform>[
      Float4ArrayUniform.colors(colors, capacity: 5),
      FloatUniform(colors.isEmpty ? 1 : colors.length.toDouble()),
      FloatUniform(stepsPerColor),
      Float4Uniform.color(colorGlow),
      Float4Uniform.color(colorGap),
      FloatUniform(distortion),
      FloatUniform(gap),
      FloatUniform(glow),
    ];
  }
}

/// Named preset for the voronoi shader.
class VoronoiPreset {
  /// Creates voronoi preset.
  const VoronoiPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final VoronoiParams params;
}

/// Catalog metadata for the voronoi shader.
class VoronoiShader {
  /// Creates voronoi shader.
  const VoronoiShader._();

  /// Static name value.
  static const name = 'voronoi';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/voronoi.frag';

  /// Static image samplers value.
  static const imageSamplers = <ShaderImageSampler>[
    ShaderImageSampler.noiseTexture,
  ];

  /// Static presets value.
  static const presets = <VoronoiPreset>[
    VoronoiPreset('Default', VoronoiParams()),
    VoronoiPreset(
      'Lights',
      VoronoiParams(
        colors: <String>['#fffffffc', '#bbff00', '#00ffff'],
        stepsPerColor: 2,
        colorGlow: '#ff00d0',
        colorGap: '#ff00d0',
        distortion: 0.38,
        gap: 0,
        glow: 1,
        sizing: ShaderSizing(scale: 3.3),
      ),
    ),
    VoronoiPreset(
      'Cells',
      VoronoiParams(
        colors: <String>['#ffffff'],
        stepsPerColor: 1,
        colorGap: '#000000',
        distortion: 0.5,
        gap: 0.03,
        glow: 0.8,
      ),
    ),
    VoronoiPreset(
      'Bubbles',
      VoronoiParams(
        colors: <String>['#83c9fb'],
        stepsPerColor: 1,
        colorGap: '#ffffff',
        gap: 0,
        glow: 1,
        sizing: ShaderSizing(scale: 0.75),
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

/// Widget that renders the voronoi shader.
class VoronoiView extends StatelessWidget {
  /// Creates voronoi view.
  const VoronoiView({this.params = const VoronoiParams(), super.key});

  /// Params.
  final VoronoiParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: VoronoiShader.assetKey,
      uniforms: params.uniforms,
      imageSamplers: VoronoiShader.imageSamplers,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}
