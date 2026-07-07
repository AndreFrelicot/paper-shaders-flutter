import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sampler.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Options for liquid metal shape.
enum LiquidMetalShape {
  none(0),
  circle(1),
  daisy(2),
  diamond(3),
  metaballs(4);

  /// Creates liquid metal shape.
  const LiquidMetalShape(this.uniformValue);

  /// Uniform value.
  final double uniformValue;
}

/// Parameters used to render the liquid metal shader.
class LiquidMetalParams {
  /// Creates liquid metal params.
  const LiquidMetalParams({
    this.colorBack = '#AAAAAC',
    this.colorTint = '#ffffff',
    this.softness = 0.1,
    this.repetition = 2,
    this.shiftRed = 0.3,
    this.shiftBlue = 0.3,
    this.distortion = 0.07,
    this.contour = 0.4,
    this.angle = 70,
    this.shape = LiquidMetalShape.diamond,
    this.isImage = true,
    this.sizing = const ShaderSizing.object(
      fit: ShaderFit.contain,
      scale: 0.6,
      imageAspectRatio: _testImageAspectRatio,
    ),
    this.speed = 1,
    this.frame = 0,
  });

  /// Color back.
  final String colorBack;

  /// Color tint.
  final String colorTint;

  /// Softness.
  final double softness;

  /// Repetition.
  final double repetition;

  /// Shift red.
  final double shiftRed;

  /// Shift blue.
  final double shiftBlue;

  /// Distortion.
  final double distortion;

  /// Contour.
  final double contour;

  /// Angle.
  final double angle;

  /// Shape.
  final LiquidMetalShape shape;

  /// Is image.
  final bool isImage;

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
      Float4Uniform.color(colorTint),
      FloatUniform(softness),
      FloatUniform(repetition),
      FloatUniform(shiftRed),
      FloatUniform(shiftBlue),
      FloatUniform(distortion),
      FloatUniform(contour),
      FloatUniform(angle),
      FloatUniform(shape.uniformValue),
      FloatUniform(isImage ? 1 : 0),
    ];
  }
}

/// Named preset for the liquid metal shader.
class LiquidMetalPreset {
  /// Creates liquid metal preset.
  const LiquidMetalPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final LiquidMetalParams params;
}

/// Catalog metadata for the liquid metal shader.
class LiquidMetalShader {
  /// Creates liquid metal shader.
  const LiquidMetalShader._();

  /// Static name value.
  static const name = 'liquid-metal';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/liquid_metal.frag';

  /// Static image samplers value.
  static const imageSamplers = <ShaderImageSampler>[
    ShaderImageSampler.liquidMetalImage,
  ];

  /// Static presets value.
  static const presets = <LiquidMetalPreset>[
    LiquidMetalPreset('Default', LiquidMetalParams()),
    LiquidMetalPreset(
      'Noir',
      LiquidMetalParams(
        colorBack: '#000000',
        colorTint: '#606060',
        softness: 0.45,
        repetition: 1.5,
        shiftRed: 0,
        shiftBlue: 0,
        distortion: 0,
        contour: 0,
        angle: 90,
      ),
    ),
    LiquidMetalPreset(
      'Backdrop',
      LiquidMetalParams(
        colorBack: '#AAAAAC',
        colorTint: '#ffffff',
        softness: 0.05,
        repetition: 1.5,
        shiftRed: 0.3,
        shiftBlue: 0.3,
        distortion: 0.1,
        contour: 0.4,
        angle: 90,
        shape: LiquidMetalShape.none,
        sizing: ShaderSizing.object(
          fit: ShaderFit.contain,
          imageAspectRatio: _testImageAspectRatio,
        ),
      ),
    ),
    LiquidMetalPreset(
      'Stripes',
      LiquidMetalParams(
        colorBack: '#000000',
        colorTint: '#2c5d72',
        softness: 0.8,
        repetition: 6,
        shiftRed: 1,
        shiftBlue: -1,
        distortion: 0.4,
        contour: 0.4,
        angle: 0,
        shape: LiquidMetalShape.circle,
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

/// Widget that renders the liquid metal shader.
class LiquidMetalView extends StatelessWidget {
  /// Creates liquid metal view.
  const LiquidMetalView({this.params = const LiquidMetalParams(), super.key});

  /// Params.
  final LiquidMetalParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: LiquidMetalShader.assetKey,
      uniforms: params.uniforms,
      imageSamplers: LiquidMetalShader.imageSamplers,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}

const double _testImageAspectRatio = 1500 / 1124;
