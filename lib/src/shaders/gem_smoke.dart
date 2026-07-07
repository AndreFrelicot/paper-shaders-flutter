import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sampler.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Options for gem smoke shape.
enum GemSmokeShape {
  none(0),
  circle(1),
  daisy(2),
  diamond(3),
  metaballs(4);

  /// Creates gem smoke shape.
  const GemSmokeShape(this.uniformValue);

  /// Uniform value.
  final double uniformValue;
}

/// Parameters used to render the gem smoke shader.
class GemSmokeParams {
  /// Creates gem smoke params.
  const GemSmokeParams({
    this.colors = const <String>['#333333', '#e7e6df'],
    this.colorBack = '#f0efea',
    this.colorInner = '#fafaf5',
    this.innerDistortion = 0.8,
    this.outerDistortion = 0.6,
    this.outerGlow = 0.55,
    this.innerGlow = 1,
    this.offset = 0,
    this.angle = 0,
    this.size = 0.8,
    this.shape = GemSmokeShape.diamond,
    this.isImage = true,
    this.sizing = const ShaderSizing.object(
      fit: ShaderFit.contain,
      scale: 0.6,
      imageAspectRatio: _testImageAspectRatio,
    ),
    this.speed = 1,
    this.frame = 0,
  });

  /// Colors.
  final List<String> colors;

  /// Color back.
  final String colorBack;

  /// Color inner.
  final String colorInner;

  /// Inner distortion.
  final double innerDistortion;

  /// Outer distortion.
  final double outerDistortion;

  /// Outer glow.
  final double outerGlow;

  /// Inner glow.
  final double innerGlow;

  /// Offset.
  final double offset;

  /// Angle.
  final double angle;

  /// Size.
  final double size;

  /// Shape.
  final GemSmokeShape shape;

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
      Float4ArrayUniform.colors(colors, capacity: 6),
      FloatUniform(colors.isEmpty ? 1 : colors.length.toDouble()),
      Float4Uniform.color(colorBack),
      Float4Uniform.color(colorInner),
      FloatUniform(innerDistortion),
      FloatUniform(outerDistortion),
      FloatUniform(outerGlow),
      FloatUniform(innerGlow),
      FloatUniform(offset),
      FloatUniform(angle),
      FloatUniform(size),
      FloatUniform(shape.uniformValue),
      FloatUniform(isImage ? 1 : 0),
    ];
  }
}

/// Named preset for the gem smoke shader.
class GemSmokePreset {
  /// Creates gem smoke preset.
  const GemSmokePreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final GemSmokeParams params;
}

/// Catalog metadata for the gem smoke shader.
class GemSmokeShader {
  /// Creates gem smoke shader.
  const GemSmokeShader._();

  /// Static name value.
  static const name = 'gem-smoke';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/gem_smoke.frag';

  /// Static image samplers value.
  static const imageSamplers = <ShaderImageSampler>[
    ShaderImageSampler.gemSmokeImage,
  ];

  /// Static presets value.
  static const presets = <GemSmokePreset>[
    GemSmokePreset('Default', GemSmokeParams()),
    GemSmokePreset(
      'Fire',
      GemSmokeParams(
        colors: <String>['#fe5b16', '#f7ff61', '#ffffff'],
        colorBack: '#000000',
        colorInner: '#000000',
        innerDistortion: 0.6,
        outerDistortion: 0.8,
        outerGlow: 1,
        innerGlow: 0.65,
      ),
    ),
    GemSmokePreset(
      'Fluorescent',
      GemSmokeParams(
        colors: <String>['#2fb64c', '#cdff61', '#ffffff'],
        colorBack: '#000000',
        colorInner: '#000000',
        innerDistortion: 1,
        outerDistortion: 0.8,
        outerGlow: 0,
        innerGlow: 1,
      ),
    ),
    GemSmokePreset(
      'Infrared',
      GemSmokeParams(
        colors: <String>['#ff9900', '#fff67a', '#dcff52', '#00ffbb', '#0077ff'],
        colorBack: '#cd28dc',
        colorInner: '#00000000',
        innerDistortion: 1,
        outerDistortion: 1,
        outerGlow: 1,
        innerGlow: 1,
        offset: 0.2,
        size: 1,
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

/// Widget that renders the gem smoke shader.
class GemSmokeView extends StatelessWidget {
  /// Creates gem smoke view.
  const GemSmokeView({this.params = const GemSmokeParams(), super.key});

  /// Params.
  final GemSmokeParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: GemSmokeShader.assetKey,
      uniforms: params.uniforms,
      imageSamplers: GemSmokeShader.imageSamplers,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}

const double _testImageAspectRatio = 1500 / 1124;
