import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Parameters used to render the spiral shader.
class SpiralParams {
  /// Creates spiral params.
  const SpiralParams({
    this.colorBack = '#001429',
    this.colorFront = '#79D1FF',
    this.density = 1,
    this.distortion = 0,
    this.strokeWidth = 0.5,
    this.strokeCap = 0,
    this.strokeTaper = 0,
    this.noise = 0,
    this.noiseFrequency = 0,
    this.softness = 0,
    this.sizing = const ShaderSizing(),
    this.speed = 1,
    this.frame = 0,
  });

  /// Color back.
  final String colorBack;

  /// Color front.
  final String colorFront;

  /// Density.
  final double density;

  /// Distortion.
  final double distortion;

  /// Stroke width.
  final double strokeWidth;

  /// Stroke cap.
  final double strokeCap;

  /// Stroke taper.
  final double strokeTaper;

  /// Noise.
  final double noise;

  /// Noise frequency.
  final double noiseFrequency;

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
      Float4Uniform.color(colorBack),
      Float4Uniform.color(colorFront),
      FloatUniform(density),
      FloatUniform(distortion),
      FloatUniform(strokeWidth),
      FloatUniform(strokeCap),
      FloatUniform(strokeTaper),
      FloatUniform(noise),
      FloatUniform(noiseFrequency),
      FloatUniform(softness),
    ];
  }
}

/// Named preset for the spiral shader.
class SpiralPreset {
  /// Creates spiral preset.
  const SpiralPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final SpiralParams params;
}

/// Catalog metadata for the spiral shader.
class SpiralShader {
  /// Creates spiral shader.
  const SpiralShader._();

  /// Static name value.
  static const name = 'spiral';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/spiral.frag';

  /// Static presets value.
  static const presets = <SpiralPreset>[
    SpiralPreset('Default', SpiralParams()),
    SpiralPreset(
      'Jungle',
      SpiralParams(
        colorBack: '#a0ef2a',
        colorFront: '#288b18',
        density: 0.5,
        noise: 1,
        noiseFrequency: 0.25,
        sizing: ShaderSizing(scale: 1.3),
        speed: 0.75,
      ),
    ),
    SpiralPreset(
      'Droplet',
      SpiralParams(
        colorBack: '#effafe',
        colorFront: '#bf40a0',
        density: 0.9,
        strokeWidth: 0.75,
        strokeCap: 1,
        strokeTaper: 0.18,
        noise: 0.74,
        noiseFrequency: 0.33,
        softness: 0.02,
      ),
    ),
    SpiralPreset(
      'Swirl',
      SpiralParams(
        colorBack: '#b3e6d9',
        colorFront: '#1a2b4d',
        density: 0.2,
        noiseFrequency: 0.3,
        softness: 0.5,
        sizing: ShaderSizing(scale: 0.45),
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

/// Widget that renders the spiral shader.
class SpiralView extends StatelessWidget {
  /// Creates spiral view.
  const SpiralView({this.params = const SpiralParams(), super.key});

  /// Params.
  final SpiralParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: SpiralShader.assetKey,
      uniforms: params.uniforms,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}
