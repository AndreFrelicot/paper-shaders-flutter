import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sampler.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Parameters used to render the water shader.
class WaterParams {
  /// Creates water params.
  const WaterParams({
    this.colorBack = '#909090',
    this.colorHighlight = '#ffffff',
    this.highlights = 0.07,
    this.layering = 0.5,
    this.edges = 0.8,
    this.caustic = 0.1,
    this.waves = 0.3,
    this.size = 1,
    this.sizing = const ShaderSizing.object(
      fit: ShaderFit.contain,
      scale: 0.8,
      imageAspectRatio: _testImageAspectRatio,
    ),
    this.speed = 1,
    this.frame = 0,
  });

  /// Color back.
  final String colorBack;

  /// Color highlight.
  final String colorHighlight;

  /// Highlights.
  final double highlights;

  /// Layering.
  final double layering;

  /// Edges.
  final double edges;

  /// Caustic.
  final double caustic;

  /// Waves.
  final double waves;

  /// Size.
  final double size;

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
      Float4Uniform.color(colorHighlight),
      FloatUniform(highlights),
      FloatUniform(layering),
      FloatUniform(edges),
      FloatUniform(caustic),
      FloatUniform(waves),
      FloatUniform(size),
    ];
  }
}

/// Named preset for the water shader.
class WaterPreset {
  /// Creates water preset.
  const WaterPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final WaterParams params;
}

/// Catalog metadata for the water shader.
class WaterShader {
  /// Creates water shader.
  const WaterShader._();

  /// Static name value.
  static const name = 'water';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/water.frag';

  /// Static image samplers value.
  static const imageSamplers = <ShaderImageSampler>[
    ShaderImageSampler.testImage,
  ];

  /// Static presets value.
  static const presets = <WaterPreset>[
    WaterPreset('Default', WaterParams()),
    WaterPreset(
      'Slow-mo',
      WaterParams(
        highlights: 0.4,
        layering: 0,
        edges: 0,
        caustic: 0.2,
        waves: 0,
        size: 0.7,
        sizing: ShaderSizing.object(
          fit: ShaderFit.cover,
          imageAspectRatio: _testImageAspectRatio,
        ),
        speed: 0.1,
      ),
    ),
    WaterPreset(
      'Abstract',
      WaterParams(
        highlights: 0,
        layering: 0,
        edges: 1,
        caustic: 0.4,
        waves: 1,
        size: 0.15,
        sizing: ShaderSizing.object(
          fit: ShaderFit.cover,
          scale: 3,
          imageAspectRatio: _testImageAspectRatio,
        ),
      ),
    ),
    WaterPreset(
      'Streaming',
      WaterParams(
        highlights: 0,
        layering: 0,
        edges: 0,
        caustic: 0,
        waves: 0.5,
        size: 0.5,
        sizing: ShaderSizing.object(
          fit: ShaderFit.contain,
          scale: 0.4,
          imageAspectRatio: _testImageAspectRatio,
        ),
        speed: 2,
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

/// Widget that renders the water shader.
class WaterView extends StatelessWidget {
  /// Creates water view.
  const WaterView({this.params = const WaterParams(), super.key});

  /// Params.
  final WaterParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: WaterShader.assetKey,
      uniforms: params.uniforms,
      imageSamplers: WaterShader.imageSamplers,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}

const double _testImageAspectRatio = 1500 / 1124;
