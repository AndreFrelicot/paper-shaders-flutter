import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sampler.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Parameters used to render the god rays shader.
class GodRaysParams {
  /// Creates god rays params.
  const GodRaysParams({
    this.colorBack = '#000000',
    this.colorBloom = '#0000ff',
    this.colors = const <String>[
      '#a600ff6e',
      '#6200fff0',
      '#ffffff',
      '#33fff5',
    ],
    this.density = 0.3,
    this.spotty = 0.3,
    this.midSize = 0.2,
    this.midIntensity = 0.4,
    this.intensity = 0.8,
    this.bloom = 0.4,
    this.sizing = const ShaderSizing(fit: ShaderFit.contain, offsetY: -0.55),
    this.speed = 0.75,
    this.frame = 0,
  });

  /// Color back.
  final String colorBack;

  /// Color bloom.
  final String colorBloom;

  /// Colors.
  final List<String> colors;

  /// Density.
  final double density;

  /// Spotty.
  final double spotty;

  /// Mid size.
  final double midSize;

  /// Mid intensity.
  final double midIntensity;

  /// Intensity.
  final double intensity;

  /// Bloom.
  final double bloom;

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
      Float4Uniform.color(colorBloom),
      Float4ArrayUniform.colors(colors, capacity: 5),
      FloatUniform(colors.isEmpty ? 1 : colors.length.toDouble()),
      FloatUniform(density),
      FloatUniform(spotty),
      FloatUniform(midSize),
      FloatUniform(midIntensity),
      FloatUniform(intensity),
      FloatUniform(bloom),
    ];
  }
}

/// Named preset for the god rays shader.
class GodRaysPreset {
  /// Creates god rays preset.
  const GodRaysPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final GodRaysParams params;
}

/// Catalog metadata for the god rays shader.
class GodRaysShader {
  /// Creates god rays shader.
  const GodRaysShader._();

  /// Static name value.
  static const name = 'god-rays';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/god_rays.frag';

  /// Static image samplers value.
  static const imageSamplers = <ShaderImageSampler>[
    ShaderImageSampler.noiseTexture,
  ];

  /// Static presets value.
  static const presets = <GodRaysPreset>[
    GodRaysPreset('Default', GodRaysParams()),
    GodRaysPreset(
      'Warp',
      GodRaysParams(
        colorBloom: '#222288',
        colors: <String>['#ff47d4', '#ff8c00', '#ffffff'],
        density: 0.45,
        spotty: 0.15,
        midSize: 0.33,
        intensity: 0.79,
        sizing: ShaderSizing(fit: ShaderFit.contain),
        speed: 2,
      ),
    ),
    GodRaysPreset(
      'Linear',
      GodRaysParams(
        colorBloom: '#eeeeee',
        colors: <String>['#ffffff1f', '#ffffff3d', '#ffffff29'],
        density: 0.41,
        spotty: 0.25,
        midSize: 0.1,
        midIntensity: 0.75,
        intensity: 0.79,
        bloom: 1,
        sizing: ShaderSizing(
          fit: ShaderFit.contain,
          offsetX: 0.2,
          offsetY: -0.8,
        ),
        speed: 0.5,
      ),
    ),
    GodRaysPreset(
      'Ether',
      GodRaysParams(
        colorBack: '#090f1d',
        colorBloom: '#ffffff',
        colors: <String>['#148effa6', '#c4dffebe', '#232a47'],
        density: 0.03,
        spotty: 0.77,
        midSize: 0.1,
        midIntensity: 0.6,
        intensity: 0.6,
        bloom: 0.6,
        sizing: ShaderSizing(fit: ShaderFit.contain, offsetX: -0.6),
        speed: 1,
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

/// Widget that renders the god rays shader.
class GodRaysView extends StatelessWidget {
  /// Creates god rays view.
  const GodRaysView({this.params = const GodRaysParams(), super.key});

  /// Params.
  final GodRaysParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: GodRaysShader.assetKey,
      uniforms: params.uniforms,
      imageSamplers: GodRaysShader.imageSamplers,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}
