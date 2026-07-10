import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Options for dot grid shape.
enum DotGridShape {
  circle(0),
  diamond(1),
  square(2),
  triangle(3);

  /// Creates dot grid shape.
  const DotGridShape(this.uniformValue);

  /// Uniform value.
  final double uniformValue;
}

/// Parameters used to render the dot grid shader.
class DotGridParams {
  /// Creates dot grid params.
  const DotGridParams({
    this.colorBack = '#000000',
    this.colorFill = '#ffffff',
    this.colorStroke = '#ffaa00',
    this.size = 2,
    this.gapX = 32,
    this.gapY = 32,
    this.strokeWidth = 0,
    this.sizeRange = 0,
    this.opacityRange = 0,
    this.shape = DotGridShape.circle,
    this.sizing = const ShaderSizing(),
    this.speed = 0,
    this.frame = 0,
  });

  /// Color back.
  final String colorBack;

  /// Color fill.
  final String colorFill;

  /// Color stroke.
  final String colorStroke;

  /// Size.
  final double size;

  /// Gap x.
  final double gapX;

  /// Gap y.
  final double gapY;

  /// Stroke width.
  final double strokeWidth;

  /// Size range.
  final double sizeRange;

  /// Opacity range.
  final double opacityRange;

  /// Shape.
  final DotGridShape shape;

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
      Float4Uniform.color(colorFill),
      Float4Uniform.color(colorStroke),
      FloatUniform(size),
      FloatUniform(gapX),
      FloatUniform(gapY),
      FloatUniform(strokeWidth),
      FloatUniform(sizeRange),
      FloatUniform(opacityRange),
      FloatUniform(shape.uniformValue),
    ];
  }
}

/// Named preset for the dot grid shader.
class DotGridPreset {
  /// Creates dot grid preset.
  const DotGridPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final DotGridParams params;
}

/// Catalog metadata for the dot grid shader.
class DotGridShader {
  /// Creates dot grid shader.
  const DotGridShader._();

  /// Static name value.
  static const name = 'dot-grid';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/dot_grid.frag';
  static const isAnimated = false;

  /// Static presets value.
  static const presets = <DotGridPreset>[
    DotGridPreset('Default', DotGridParams()),
    DotGridPreset(
      'Triangles',
      DotGridParams(
        colorBack: '#ffffff',
        colorStroke: '#808080',
        size: 5,
        strokeWidth: 1,
        shape: DotGridShape.triangle,
      ),
    ),
    DotGridPreset(
      'Tree line',
      DotGridParams(
        colorBack: '#f4fce7',
        colorFill: '#052e19',
        colorStroke: '#000000',
        size: 8,
        gapX: 20,
        gapY: 90,
        sizeRange: 1,
        opacityRange: 0.6,
      ),
    ),
    DotGridPreset(
      'Wallpaper',
      DotGridParams(
        colorBack: '#204030',
        colorFill: '#000000',
        colorStroke: '#bd955b',
        size: 9,
        strokeWidth: 1,
        shape: DotGridShape.diamond,
      ),
    ),
  ];

  /// Static catalog entry value.
  static final catalogEntry = ShaderCatalogEntry(
    name: name,
    assetKey: assetKey,
    isAnimated: isAnimated,
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

/// Widget that renders the dot grid shader.
class DotGridView extends StatelessWidget {
  /// Creates dot grid view.
  const DotGridView({this.params = const DotGridParams(), super.key});

  /// Params.
  final DotGridParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: DotGridShader.assetKey,
      isAnimated: DotGridShader.isAnimated,
      uniforms: params.uniforms,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}
