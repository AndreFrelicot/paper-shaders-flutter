import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Options for dithering shape.
enum DitheringShape {
  simplex(1),
  warp(2),
  dots(3),
  wave(4),
  ripple(5),
  swirl(6),
  sphere(7);

  /// Creates dithering shape.
  const DitheringShape(this.uniformValue);

  /// Uniform value.
  final double uniformValue;
}

/// Options for dithering type.
enum DitheringType {
  random(1),
  bayer2x2(2),
  bayer4x4(3),
  bayer8x8(4);

  /// Creates dithering type.
  const DitheringType(this.uniformValue);

  /// Uniform value.
  final double uniformValue;
}

/// Parameters used to render the dithering shader.
class DitheringParams {
  /// Creates dithering params.
  const DitheringParams({
    this.size = 2,
    this.colorBack = '#000000',
    this.colorFront = '#00b2ff',
    this.shape = DitheringShape.sphere,
    this.type = DitheringType.bayer4x4,
    this.sizing = const ShaderSizing(scale: 0.6),
    this.speed = 1,
    this.frame = 0,
  });

  /// Size.
  final double size;

  /// Color back.
  final String colorBack;

  /// Color front.
  final String colorFront;

  /// Shape.
  final DitheringShape shape;

  /// Type.
  final DitheringType type;

  /// Sizing.
  final ShaderSizing sizing;

  /// Speed.
  final double speed;

  /// Frame.
  final double frame;

  /// Uniform values packed in the shader declaration order.
  List<ShaderUniform> get uniforms {
    return <ShaderUniform>[
      FloatUniform(size),
      Float4Uniform.color(colorBack),
      Float4Uniform.color(colorFront),
      FloatUniform(shape.uniformValue),
      FloatUniform(type.uniformValue),
    ];
  }
}

/// Named preset for the dithering shader.
class DitheringPreset {
  /// Creates dithering preset.
  const DitheringPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final DitheringParams params;
}

/// Catalog metadata for the dithering shader.
class DitheringShader {
  /// Creates dithering shader.
  const DitheringShader._();

  /// Static name value.
  static const name = 'dithering';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/dithering.frag';

  /// Static presets value.
  static const presets = <DitheringPreset>[
    DitheringPreset('Default', DitheringParams()),
    DitheringPreset(
      'Warp',
      DitheringParams(
        size: 2.5,
        colorBack: '#301c2a',
        colorFront: '#56ae6c',
        shape: DitheringShape.warp,
        sizing: ShaderSizing(fit: ShaderFit.contain),
      ),
    ),
    DitheringPreset(
      'Sine Wave',
      DitheringParams(
        size: 11,
        colorBack: '#730d54',
        colorFront: '#00becc',
        shape: DitheringShape.wave,
        sizing: ShaderSizing(scale: 1.2),
      ),
    ),
    DitheringPreset(
      'Ripple',
      DitheringParams(
        size: 3,
        colorBack: '#603520',
        colorFront: '#c67953',
        shape: DitheringShape.ripple,
        type: DitheringType.bayer2x2,
        sizing: ShaderSizing(fit: ShaderFit.contain),
      ),
    ),
    DitheringPreset(
      'Bugs',
      DitheringParams(
        size: 9,
        colorFront: '#008000',
        shape: DitheringShape.dots,
        type: DitheringType.random,
        sizing: ShaderSizing(),
      ),
    ),
    DitheringPreset(
      'Swirl',
      DitheringParams(
        colorBack: '#00000000',
        colorFront: '#47a8e1',
        shape: DitheringShape.swirl,
        type: DitheringType.bayer8x8,
        sizing: ShaderSizing(fit: ShaderFit.contain),
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

/// Widget that renders the dithering shader.
class DitheringView extends StatelessWidget {
  /// Creates dithering view.
  const DitheringView({this.params = const DitheringParams(), super.key});

  /// Params.
  final DitheringParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: DitheringShader.assetKey,
      uniforms: params.uniforms,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}
