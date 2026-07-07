import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sampler.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Parameters used to render the paper texture shader.
class PaperTextureParams {
  /// Creates paper texture params.
  const PaperTextureParams({
    this.colorFront = '#9fadbc',
    this.colorBack = '#ffffff',
    this.contrast = 0.3,
    this.roughness = 0.4,
    this.fiber = 0.3,
    this.fiberSize = 0.2,
    this.crumples = 0.3,
    this.crumpleSize = 0.35,
    this.folds = 0.65,
    this.foldCount = 5,
    this.drops = 0.2,
    this.seed = 5.8,
    this.fade = 0,
    this.sizing = const ShaderSizing.object(
      fit: ShaderFit.cover,
      scale: 0.6,
      imageAspectRatio: _testImageAspectRatio,
    ),
    this.speed = 0,
    this.frame = 0,
  });

  /// Color front.
  final String colorFront;

  /// Color back.
  final String colorBack;

  /// Contrast.
  final double contrast;

  /// Roughness.
  final double roughness;

  /// Fiber.
  final double fiber;

  /// Fiber size.
  final double fiberSize;

  /// Crumples.
  final double crumples;

  /// Crumple size.
  final double crumpleSize;

  /// Folds.
  final double folds;

  /// Fold count.
  final double foldCount;

  /// Drops.
  final double drops;

  /// Seed.
  final double seed;

  /// Fade.
  final double fade;

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
      FloatUniform(contrast),
      FloatUniform(roughness),
      FloatUniform(fiber),
      FloatUniform(fiberSize),
      FloatUniform(crumples),
      FloatUniform(crumpleSize),
      FloatUniform(folds),
      FloatUniform(foldCount),
      FloatUniform(drops),
      FloatUniform(seed),
      FloatUniform(fade),
    ];
  }
}

/// Named preset for the paper texture shader.
class PaperTexturePreset {
  /// Creates paper texture preset.
  const PaperTexturePreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final PaperTextureParams params;
}

/// Catalog metadata for the paper texture shader.
class PaperTextureShader {
  /// Creates paper texture shader.
  const PaperTextureShader._();

  /// Static name value.
  static const name = 'paper-texture';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/paper_texture.frag';

  /// Static image samplers value.
  static const imageSamplers = <ShaderImageSampler>[
    ShaderImageSampler.testImage,
    ShaderImageSampler.noiseTexture,
  ];

  /// Static presets value.
  static const presets = <PaperTexturePreset>[
    PaperTexturePreset('Default', PaperTextureParams()),
    PaperTexturePreset(
      'Cardboard',
      PaperTextureParams(
        colorFront: '#c7b89e',
        colorBack: '#999180',
        contrast: 0.4,
        roughness: 0,
        fiber: 0.35,
        fiberSize: 0.14,
        crumples: 0.7,
        crumpleSize: 0.1,
        folds: 0,
        foldCount: 1,
        drops: 0.1,
        seed: 1.6,
      ),
    ),
    PaperTexturePreset(
      'Abstract',
      PaperTextureParams(
        colorFront: '#00eeff',
        colorBack: '#ff0a81',
        contrast: 0.85,
        roughness: 0,
        fiber: 0.1,
        crumples: 0,
        crumpleSize: 0.3,
        folds: 1,
        foldCount: 3,
        seed: 2.2,
      ),
    ),
    PaperTexturePreset(
      'Details',
      PaperTextureParams(
        colorFront: '#00000000',
        colorBack: '#00000000',
        contrast: 0,
        roughness: 1,
        fiber: 0.27,
        fiberSize: 0.22,
        crumples: 1,
        crumpleSize: 0.5,
        folds: 1,
        foldCount: 15,
        drops: 0,
        seed: 6,
        sizing: ShaderSizing.object(
          fit: ShaderFit.cover,
          scale: 3,
          imageAspectRatio: _testImageAspectRatio,
        ),
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

/// Widget that renders the paper texture shader.
class PaperTextureView extends StatelessWidget {
  /// Creates paper texture view.
  const PaperTextureView({this.params = const PaperTextureParams(), super.key});

  /// Params.
  final PaperTextureParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: PaperTextureShader.assetKey,
      uniforms: params.uniforms,
      imageSamplers: PaperTextureShader.imageSamplers,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}

const double _testImageAspectRatio = 1500 / 1124;
