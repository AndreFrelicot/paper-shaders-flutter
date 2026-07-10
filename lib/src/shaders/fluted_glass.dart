import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sampler.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Options for fluted glass shape.
enum FlutedGlassShape {
  lines(1),
  linesIrregular(2),
  wave(3),
  zigzag(4),
  pattern(5);

  /// Creates fluted glass shape.
  const FlutedGlassShape(this.uniformValue);

  /// Uniform value.
  final double uniformValue;
}

/// Options for fluted glass distortion shape.
enum FlutedGlassDistortionShape {
  prism(1),
  lens(2),
  contour(3),
  cascade(4),
  flat(5);

  /// Creates fluted glass distortion shape.
  const FlutedGlassDistortionShape(this.uniformValue);

  /// Uniform value.
  final double uniformValue;
}

/// Parameters used to render the fluted glass shader.
class FlutedGlassParams {
  /// Creates fluted glass params.
  const FlutedGlassParams({
    this.colorBack = '#00000000',
    this.colorShadow = '#000000',
    this.colorHighlight = '#ffffff',
    this.size = 0.5,
    this.shadows = 0.25,
    this.angle = 0,
    this.stretch = 0,
    this.shape = FlutedGlassShape.lines,
    this.distortion = 0.5,
    this.highlights = 0.1,
    this.distortionShape = FlutedGlassDistortionShape.prism,
    this.shift = 0,
    this.blur = 0,
    this.edges = 0.25,
    this.marginLeft = 0,
    this.marginRight = 0,
    this.marginTop = 0,
    this.marginBottom = 0,
    this.grainMixer = 0,
    this.grainOverlay = 0,
    this.sizing = const ShaderSizing.object(
      fit: ShaderFit.cover,
      imageAspectRatio: _testImageAspectRatio,
    ),
    this.speed = 0,
    this.frame = 0,
  });

  /// Color back.
  final String colorBack;

  /// Color shadow.
  final String colorShadow;

  /// Color highlight.
  final String colorHighlight;

  /// Size.
  final double size;

  /// Shadows.
  final double shadows;

  /// Angle.
  final double angle;

  /// Stretch.
  final double stretch;

  /// Shape.
  final FlutedGlassShape shape;

  /// Distortion.
  final double distortion;

  /// Highlights.
  final double highlights;

  /// Distortion shape.
  final FlutedGlassDistortionShape distortionShape;

  /// Shift.
  final double shift;

  /// Blur.
  final double blur;

  /// Edges.
  final double edges;

  /// Margin left.
  final double marginLeft;

  /// Margin right.
  final double marginRight;

  /// Margin top.
  final double marginTop;

  /// Margin bottom.
  final double marginBottom;

  /// Grain mixer.
  final double grainMixer;

  /// Grain overlay.
  final double grainOverlay;

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
      Float4Uniform.color(colorShadow),
      Float4Uniform.color(colorHighlight),
      FloatUniform(size),
      FloatUniform(shadows),
      FloatUniform(angle),
      FloatUniform(stretch),
      FloatUniform(shape.uniformValue),
      FloatUniform(distortion),
      FloatUniform(highlights),
      FloatUniform(distortionShape.uniformValue),
      FloatUniform(shift),
      FloatUniform(blur),
      FloatUniform(edges),
      FloatUniform(marginLeft),
      FloatUniform(marginRight),
      FloatUniform(marginTop),
      FloatUniform(marginBottom),
      FloatUniform(grainMixer),
      FloatUniform(grainOverlay),
    ];
  }
}

/// Named preset for the fluted glass shader.
class FlutedGlassPreset {
  /// Creates fluted glass preset.
  const FlutedGlassPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final FlutedGlassParams params;
}

/// Catalog metadata for the fluted glass shader.
class FlutedGlassShader {
  /// Creates fluted glass shader.
  const FlutedGlassShader._();

  /// Static name value.
  static const name = 'fluted-glass';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/fluted_glass.frag';
  static const isAnimated = false;

  /// Static image samplers value.
  static const imageSamplers = <ShaderImageSampler>[
    ShaderImageSampler.testImage,
  ];

  /// Static presets value.
  static const presets = <FlutedGlassPreset>[
    FlutedGlassPreset('Default', FlutedGlassParams()),
    FlutedGlassPreset(
      'Abstract',
      FlutedGlassParams(
        size: 0.7,
        shadows: 0,
        angle: 30,
        stretch: 1,
        shape: FlutedGlassShape.linesIrregular,
        distortion: 1,
        highlights: 0,
        distortionShape: FlutedGlassDistortionShape.flat,
        blur: 1,
        edges: 0.5,
        grainMixer: 0.1,
        grainOverlay: 0.1,
        sizing: ShaderSizing.object(
          fit: ShaderFit.cover,
          scale: 4,
          imageAspectRatio: _testImageAspectRatio,
        ),
      ),
    ),
    FlutedGlassPreset(
      'Waves',
      FlutedGlassParams(
        size: 0.9,
        shadows: 0,
        stretch: 1,
        shape: FlutedGlassShape.wave,
        highlights: 0,
        distortionShape: FlutedGlassDistortionShape.contour,
        blur: 0.1,
        edges: 0.5,
        grainOverlay: 0.05,
        sizing: ShaderSizing.object(
          fit: ShaderFit.cover,
          scale: 1.2,
          imageAspectRatio: _testImageAspectRatio,
        ),
      ),
    ),
    FlutedGlassPreset(
      'Folds',
      FlutedGlassParams(
        size: 0.4,
        shadows: 0.4,
        distortion: 0.75,
        highlights: 0,
        distortionShape: FlutedGlassDistortionShape.cascade,
        blur: 0.25,
        edges: 0.5,
        marginLeft: 0.1,
        marginRight: 0.1,
        marginTop: 0.1,
        marginBottom: 0.1,
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

/// Widget that renders the fluted glass shader.
class FlutedGlassView extends StatelessWidget {
  /// Creates fluted glass view.
  const FlutedGlassView({this.params = const FlutedGlassParams(), super.key});

  /// Params.
  final FlutedGlassParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: FlutedGlassShader.assetKey,
      isAnimated: FlutedGlassShader.isAnimated,
      uniforms: params.uniforms,
      imageSamplers: FlutedGlassShader.imageSamplers,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}

const double _testImageAspectRatio = 1500 / 1124;
