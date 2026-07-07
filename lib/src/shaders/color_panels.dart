import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Parameters used to render the color panels shader.
class ColorPanelsParams {
  /// Creates color panels params.
  const ColorPanelsParams({
    this.colors = const <String>[
      '#ff9d00',
      '#fd4f30',
      '#809bff',
      '#6d2eff',
      '#333aff',
      '#f15cff',
      '#ffd557',
    ],
    this.colorBack = '#000000',
    this.density = 3,
    this.angle1 = 0,
    this.angle2 = 0,
    this.length = 1.1,
    this.edges = false,
    this.blur = 0,
    this.fadeIn = 1,
    this.fadeOut = 0.3,
    this.gradient = 0,
    this.sizing = const ShaderSizing(fit: ShaderFit.contain, scale: 0.8),
    this.speed = 0.5,
    this.frame = 0,
  });

  /// Colors.
  final List<String> colors;

  /// Color back.
  final String colorBack;

  /// Density.
  final double density;

  /// Angle1.
  final double angle1;

  /// Angle2.
  final double angle2;

  /// Length.
  final double length;

  /// Edges.
  final bool edges;

  /// Blur.
  final double blur;

  /// Fade in.
  final double fadeIn;

  /// Fade out.
  final double fadeOut;

  /// Gradient.
  final double gradient;

  /// Sizing.
  final ShaderSizing sizing;

  /// Speed.
  final double speed;

  /// Frame.
  final double frame;

  /// Uniform values packed in the shader declaration order.
  List<ShaderUniform> get uniforms {
    return <ShaderUniform>[
      Float4ArrayUniform.colors(colors, capacity: 7),
      FloatUniform(colors.isEmpty ? 1 : colors.length.toDouble()),
      Float4Uniform.color(colorBack),
      FloatUniform(density),
      FloatUniform(angle1),
      FloatUniform(angle2),
      FloatUniform(length),
      FloatUniform(edges ? 1 : 0),
      FloatUniform(blur),
      FloatUniform(fadeIn),
      FloatUniform(fadeOut),
      FloatUniform(gradient),
    ];
  }
}

/// Named preset for the color panels shader.
class ColorPanelsPreset {
  /// Creates color panels preset.
  const ColorPanelsPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final ColorPanelsParams params;
}

/// Catalog metadata for the color panels shader.
class ColorPanelsShader {
  /// Creates color panels shader.
  const ColorPanelsShader._();

  /// Static name value.
  static const name = 'color-panels';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/color_panels.frag';

  /// Static presets value.
  static const presets = <ColorPanelsPreset>[
    ColorPanelsPreset('Default', ColorPanelsParams()),
    ColorPanelsPreset(
      'Glass',
      ColorPanelsParams(
        colors: <String>['#00cfff', '#ff2d55', '#34c759', '#af52de'],
        colorBack: '#ffffff00',
        density: 1.6,
        angle1: 0.3,
        angle2: 0.3,
        length: 1,
        edges: true,
        blur: 0.25,
        fadeIn: 0.85,
        sizing: ShaderSizing(fit: ShaderFit.contain, rotation: 112),
        speed: 1,
      ),
    ),
    ColorPanelsPreset(
      'Gradient',
      ColorPanelsParams(
        colors: <String>[
          '#f2ff00',
          '#00000000',
          '#00000000',
          '#5a0283',
          '#005eff',
        ],
        colorBack: '#8ffff2',
        density: 1.65,
        angle1: 0.4,
        angle2: 0.4,
        length: 3,
        blur: 0.5,
        fadeOut: 0.39,
        gradient: 0.78,
        sizing: ShaderSizing(
          fit: ShaderFit.contain,
          scale: 1.72,
          rotation: 270,
          offsetX: 0.18,
        ),
      ),
    ),
    ColorPanelsPreset(
      'Opening',
      ColorPanelsParams(
        colors: <String>['#00ffff'],
        colorBack: '#570044',
        density: 2.21,
        angle1: -1,
        angle2: -1,
        length: 0.52,
        fadeIn: 0,
        fadeOut: 1,
        sizing: ShaderSizing(
          fit: ShaderFit.contain,
          scale: 2.32,
          rotation: 360,
          offsetX: -0.3,
          offsetY: 0.6,
        ),
        speed: 2,
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

/// Widget that renders the color panels shader.
class ColorPanelsView extends StatelessWidget {
  /// Creates color panels view.
  const ColorPanelsView({this.params = const ColorPanelsParams(), super.key});

  /// Params.
  final ColorPanelsParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: ColorPanelsShader.assetKey,
      uniforms: params.uniforms,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}
