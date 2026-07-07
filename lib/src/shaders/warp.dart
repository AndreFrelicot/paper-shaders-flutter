import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sampler.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Options for warp shape.
enum WarpShape {
  checks(0),
  stripes(1),
  edge(2);

  /// Creates warp shape.
  const WarpShape(this.uniformValue);

  /// Uniform value.
  final double uniformValue;
}

/// Parameters used to render the warp shader.
class WarpParams {
  /// Creates warp params.
  const WarpParams({
    this.colors = const <String>['#121212', '#9470ff', '#121212', '#8838ff'],
    this.proportion = 0.45,
    this.softness = 1,
    this.shape = WarpShape.checks,
    this.shapeScale = 0.1,
    this.distortion = 0.25,
    this.swirl = 0.8,
    this.swirlIterations = 10,
    this.sizing = const ShaderSizing(),
    this.speed = 1,
    this.frame = 0,
  });

  /// Colors.
  final List<String> colors;

  /// Proportion.
  final double proportion;

  /// Softness.
  final double softness;

  /// Shape.
  final WarpShape shape;

  /// Shape scale.
  final double shapeScale;

  /// Distortion.
  final double distortion;

  /// Swirl.
  final double swirl;

  /// Swirl iterations.
  final double swirlIterations;

  /// Sizing.
  final ShaderSizing sizing;

  /// Speed.
  final double speed;

  /// Frame.
  final double frame;

  /// Uniform values packed in the shader declaration order.
  List<ShaderUniform> get uniforms {
    return <ShaderUniform>[
      Float4ArrayUniform.colors(colors, capacity: 10),
      FloatUniform(colors.isEmpty ? 1 : colors.length.toDouble()),
      FloatUniform(proportion),
      FloatUniform(softness),
      FloatUniform(shape.uniformValue),
      FloatUniform(shapeScale),
      FloatUniform(distortion),
      FloatUniform(swirl),
      FloatUniform(swirlIterations),
    ];
  }
}

/// Named preset for the warp shader.
class WarpPreset {
  /// Creates warp preset.
  const WarpPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final WarpParams params;
}

/// Catalog metadata for the warp shader.
class WarpShader {
  /// Creates warp shader.
  const WarpShader._();

  /// Static name value.
  static const name = 'warp';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/warp.frag';

  /// Static image samplers value.
  static const imageSamplers = <ShaderImageSampler>[
    ShaderImageSampler.noiseTexture,
  ];

  /// Static presets value.
  static const presets = <WarpPreset>[
    WarpPreset('Default', WarpParams()),
    WarpPreset(
      'Cauldron Pot',
      WarpParams(
        colors: <String>['#a7e58b', '#324472', '#0a180d'],
        proportion: 0.64,
        softness: 1.5,
        shape: WarpShape.edge,
        shapeScale: 0.6,
        distortion: 0.2,
        swirl: 0.86,
        swirlIterations: 7,
        sizing: ShaderSizing(scale: 0.9, rotation: 160),
        speed: 10,
      ),
    ),
    WarpPreset(
      'Live Ink',
      WarpParams(
        colors: <String>['#111314', '#9faeab', '#f3fee7', '#f3fee7'],
        proportion: 0.05,
        softness: 0,
        shapeScale: 0.28,
        sizing: ShaderSizing(scale: 1.2, rotation: 44, offsetY: -0.3),
        speed: 2.5,
      ),
    ),
    WarpPreset(
      'Kelp',
      WarpParams(
        colors: <String>['#dbff8f', '#404f3e', '#091316'],
        proportion: 0.67,
        softness: 0,
        shape: WarpShape.stripes,
        shapeScale: 1,
        distortion: 0,
        swirl: 0.2,
        swirlIterations: 3,
        sizing: ShaderSizing(scale: 0.8, rotation: 50),
        speed: 20,
      ),
    ),
    WarpPreset(
      'Nectar',
      WarpParams(
        colors: <String>['#151310', '#d3a86b', '#f0edea'],
        proportion: 0.24,
        shape: WarpShape.edge,
        shapeScale: 0.75,
        distortion: 0.21,
        swirl: 0.57,
        sizing: ShaderSizing(scale: 2, offsetY: 0.6),
        speed: 4.2,
      ),
    ),
    WarpPreset(
      'Passion',
      WarpParams(
        colors: <String>['#3b1515', '#954751', '#ffc085'],
        proportion: 0.5,
        shapeScale: 0.25,
        distortion: 0.09,
        swirl: 0.9,
        swirlIterations: 6,
        sizing: ShaderSizing(scale: 2.5, rotation: 1.35),
        speed: 3,
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

/// Widget that renders the warp shader.
class WarpView extends StatelessWidget {
  /// Creates warp view.
  const WarpView({this.params = const WarpParams(), super.key});

  /// Params.
  final WarpParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: WarpShader.assetKey,
      uniforms: params.uniforms,
      imageSamplers: WarpShader.imageSamplers,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}
