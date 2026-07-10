import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sampler.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Options for halftone dots grid.
enum HalftoneDotsGrid {
  square(0),
  hex(1);

  /// Creates halftone dots grid.
  const HalftoneDotsGrid(this.uniformValue);

  /// Uniform value.
  final double uniformValue;
}

/// Options for halftone dots type.
enum HalftoneDotsType {
  classic(0),
  gooey(1),
  holes(2),
  soft(3);

  /// Creates halftone dots type.
  const HalftoneDotsType(this.uniformValue);

  /// Uniform value.
  final double uniformValue;
}

/// Parameters used to render the halftone dots shader.
class HalftoneDotsParams {
  /// Creates halftone dots params.
  const HalftoneDotsParams({
    this.colorFront = '#2b2b2b',
    this.colorBack = '#f2f1e8',
    this.radius = 1.25,
    this.contrast = 0.4,
    this.size = 0.5,
    this.grainMixer = 0.2,
    this.grainOverlay = 0.2,
    this.grainSize = 0.5,
    this.grid = HalftoneDotsGrid.hex,
    this.originalColors = false,
    this.inverted = false,
    this.type = HalftoneDotsType.gooey,
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

  /// Radius.
  final double radius;

  /// Contrast.
  final double contrast;

  /// Size.
  final double size;

  /// Grain mixer.
  final double grainMixer;

  /// Grain overlay.
  final double grainOverlay;

  /// Grain size.
  final double grainSize;

  /// Grid.
  final HalftoneDotsGrid grid;

  /// Original colors.
  final bool originalColors;

  /// Inverted.
  final bool inverted;

  /// Type.
  final HalftoneDotsType type;

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
      FloatUniform(radius),
      FloatUniform(contrast),
      FloatUniform(size),
      FloatUniform(grainMixer),
      FloatUniform(grainOverlay),
      FloatUniform(grainSize),
      FloatUniform(grid.uniformValue),
      FloatUniform(originalColors ? 1 : 0),
      FloatUniform(inverted ? 1 : 0),
      FloatUniform(type.uniformValue),
    ];
  }
}

/// Named preset for the halftone dots shader.
class HalftoneDotsPreset {
  /// Creates halftone dots preset.
  const HalftoneDotsPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final HalftoneDotsParams params;
}

/// Catalog metadata for the halftone dots shader.
class HalftoneDotsShader {
  /// Creates halftone dots shader.
  const HalftoneDotsShader._();

  /// Static name value.
  static const name = 'halftone-dots';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/halftone_dots.frag';
  static const isAnimated = false;

  /// Static image samplers value.
  static const imageSamplers = <ShaderImageSampler>[
    ShaderImageSampler.flowersImage,
  ];

  /// Static presets value.
  static const presets = <HalftoneDotsPreset>[
    HalftoneDotsPreset('Default', HalftoneDotsParams()),
    HalftoneDotsPreset(
      'LED screen',
      HalftoneDotsParams(
        colorFront: '#29ff7b',
        colorBack: '#000000',
        radius: 1.5,
        contrast: 0.3,
        grainMixer: 0,
        grainOverlay: 0,
        grid: HalftoneDotsGrid.square,
        type: HalftoneDotsType.soft,
      ),
    ),
    HalftoneDotsPreset(
      'Mosaic',
      HalftoneDotsParams(
        colorFront: '#b2aeae',
        colorBack: '#000000',
        radius: 2,
        contrast: 0.01,
        size: 0.6,
        grainMixer: 0,
        grainOverlay: 0,
        originalColors: true,
        type: HalftoneDotsType.classic,
      ),
    ),
    HalftoneDotsPreset(
      'Round and square',
      HalftoneDotsParams(
        colorFront: '#ff8000',
        colorBack: '#141414',
        radius: 1,
        contrast: 1,
        size: 0.8,
        grainMixer: 0.05,
        grainOverlay: 0.3,
        grid: HalftoneDotsGrid.square,
        inverted: true,
        type: HalftoneDotsType.holes,
      ),
    ),
  ];

  /// Static catalog entry value.
  static final catalogEntry = ShaderCatalogEntry(
    name: name,
    assetKey: assetKey,
    isAnimated: isAnimated,
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

/// Widget that renders the halftone dots shader.
class HalftoneDotsView extends StatelessWidget {
  /// Creates halftone dots view.
  const HalftoneDotsView({this.params = const HalftoneDotsParams(), super.key});

  /// Params.
  final HalftoneDotsParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: HalftoneDotsShader.assetKey,
      isAnimated: HalftoneDotsShader.isAnimated,
      uniforms: params.uniforms,
      imageSamplers: HalftoneDotsShader.imageSamplers,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}

const double _testImageAspectRatio = 1500 / 1124;
