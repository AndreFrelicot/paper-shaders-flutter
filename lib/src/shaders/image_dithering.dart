import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sampler.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Options for image dithering type.
enum ImageDitheringType {
  random(1),
  bayer2x2(2),
  bayer4x4(3),
  bayer8x8(4);

  /// Creates image dithering type.
  const ImageDitheringType(this.uniformValue);

  /// Uniform value.
  final double uniformValue;
}

/// Parameters used to render the image dithering shader.
class ImageDitheringParams {
  /// Creates image dithering params.
  const ImageDitheringParams({
    this.colorFront = '#94ffaf',
    this.colorBack = '#000c38',
    this.colorHighlight = '#eaff94',
    this.type = ImageDitheringType.bayer8x8,
    this.size = 2,
    this.originalColors = false,
    this.inverted = false,
    this.colorSteps = 2,
    this.sizing = const ShaderSizing.object(
      fit: ShaderFit.cover,
      imageAspectRatio: _testImageAspectRatio,
    ),
    this.speed = 0,
    this.frame = 0,
  });

  /// Color front.
  final String colorFront;

  /// Color back.
  final String colorBack;

  /// Color highlight.
  final String colorHighlight;

  /// Type.
  final ImageDitheringType type;

  /// Size.
  final double size;

  /// Original colors.
  final bool originalColors;

  /// Inverted.
  final bool inverted;

  /// Color steps.
  final double colorSteps;

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
      Float4Uniform.color(colorHighlight),
      FloatUniform(type.uniformValue),
      FloatUniform(size),
      FloatUniform(originalColors ? 1 : 0),
      FloatUniform(inverted ? 1 : 0),
      FloatUniform(colorSteps),
    ];
  }
}

/// Named preset for the image dithering shader.
class ImageDitheringPreset {
  /// Creates image dithering preset.
  const ImageDitheringPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final ImageDitheringParams params;
}

/// Catalog metadata for the image dithering shader.
class ImageDitheringShader {
  /// Creates image dithering shader.
  const ImageDitheringShader._();

  /// Static name value.
  static const name = 'image-dithering';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/image_dithering.frag';

  /// Static image samplers value.
  static const imageSamplers = <ShaderImageSampler>[
    ShaderImageSampler.flowersImage,
  ];

  /// Static presets value.
  static const presets = <ImageDitheringPreset>[
    ImageDitheringPreset('Default', ImageDitheringParams()),
    ImageDitheringPreset(
      'Noise',
      ImageDitheringParams(
        colorFront: '#a2997c',
        colorBack: '#000000',
        colorHighlight: '#ededed',
        type: ImageDitheringType.random,
        size: 1,
        colorSteps: 1,
      ),
    ),
    ImageDitheringPreset(
      'Retro',
      ImageDitheringParams(
        colorFront: '#eeeeee',
        colorBack: '#5452ff',
        colorHighlight: '#eeeeee',
        type: ImageDitheringType.bayer2x2,
        size: 3,
        originalColors: true,
        colorSteps: 1,
      ),
    ),
    ImageDitheringPreset(
      'Natural',
      ImageDitheringParams(
        colorFront: '#ffffff',
        colorBack: '#000000',
        colorHighlight: '#ffffff',
        type: ImageDitheringType.bayer8x8,
        size: 2,
        originalColors: true,
        colorSteps: 5,
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

/// Widget that renders the image dithering shader.
class ImageDitheringView extends StatelessWidget {
  /// Creates image dithering view.
  const ImageDitheringView({
    this.params = const ImageDitheringParams(),
    super.key,
  });

  /// Params.
  final ImageDitheringParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: ImageDitheringShader.assetKey,
      uniforms: params.uniforms,
      imageSamplers: ImageDitheringShader.imageSamplers,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}

const double _testImageAspectRatio = 1500 / 1124;
