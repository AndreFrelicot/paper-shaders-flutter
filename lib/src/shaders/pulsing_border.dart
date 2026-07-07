import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sampler.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Options for pulsing border aspect ratio.
enum PulsingBorderAspectRatio {
  auto(0),
  square(1);

  /// Creates pulsing border aspect ratio.
  const PulsingBorderAspectRatio(this.uniformValue);

  /// Uniform value.
  final double uniformValue;
}

/// Parameters used to render the pulsing border shader.
class PulsingBorderParams {
  /// Creates pulsing border params.
  const PulsingBorderParams({
    this.colorBack = '#000000',
    this.colors = const <String>['#0dc1fd', '#d915ef', '#ff3f2ecc'],
    this.roundness = 0.25,
    this.thickness = 0.1,
    this.marginLeft = 0,
    this.marginRight = 0,
    this.marginTop = 0,
    this.marginBottom = 0,
    this.aspectRatio = PulsingBorderAspectRatio.auto,
    this.softness = 0.75,
    this.intensity = 0.2,
    this.bloom = 0.25,
    this.spots = 5,
    this.spotSize = 0.5,
    this.pulse = 0.25,
    this.smoke = 0.3,
    this.smokeSize = 0.6,
    this.sizing = const ShaderSizing.pattern(
      fit: ShaderFit.contain,
      scale: 0.6,
    ),
    this.speed = 1,
    this.frame = 0,
  });

  /// Color back.
  final String colorBack;

  /// Colors.
  final List<String> colors;

  /// Roundness.
  final double roundness;

  /// Thickness.
  final double thickness;

  /// Margin left.
  final double marginLeft;

  /// Margin right.
  final double marginRight;

  /// Margin top.
  final double marginTop;

  /// Margin bottom.
  final double marginBottom;

  /// Aspect ratio.
  final PulsingBorderAspectRatio aspectRatio;

  /// Softness.
  final double softness;

  /// Intensity.
  final double intensity;

  /// Bloom.
  final double bloom;

  /// Spots.
  final double spots;

  /// Spot size.
  final double spotSize;

  /// Pulse.
  final double pulse;

  /// Smoke.
  final double smoke;

  /// Smoke size.
  final double smokeSize;

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
      Float4ArrayUniform.colors(colors, capacity: 5),
      FloatUniform(colors.isEmpty ? 1 : colors.length.toDouble()),
      FloatUniform(roundness),
      FloatUniform(thickness),
      FloatUniform(marginLeft),
      FloatUniform(marginRight),
      FloatUniform(marginTop),
      FloatUniform(marginBottom),
      FloatUniform(aspectRatio.uniformValue),
      FloatUniform(softness),
      FloatUniform(intensity),
      FloatUniform(bloom),
      FloatUniform(spotSize),
      FloatUniform(spots),
      FloatUniform(pulse),
      FloatUniform(smoke),
      FloatUniform(smokeSize),
    ];
  }
}

/// Named preset for the pulsing border shader.
class PulsingBorderPreset {
  /// Creates pulsing border preset.
  const PulsingBorderPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final PulsingBorderParams params;
}

/// Catalog metadata for the pulsing border shader.
class PulsingBorderShader {
  /// Creates pulsing border shader.
  const PulsingBorderShader._();

  /// Static name value.
  static const name = 'pulsing-border';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/pulsing_border.frag';

  /// Static image samplers value.
  static const imageSamplers = <ShaderImageSampler>[
    ShaderImageSampler.noiseTexture,
  ];

  /// Static presets value.
  static const presets = <PulsingBorderPreset>[
    PulsingBorderPreset('Default', PulsingBorderParams()),
    PulsingBorderPreset(
      'Circle',
      PulsingBorderParams(
        roundness: 1,
        thickness: 0,
        aspectRatio: PulsingBorderAspectRatio.square,
        bloom: 0.45,
        spots: 3,
        spotSize: 0.4,
        pulse: 0.5,
        smoke: 1,
        smokeSize: 0,
      ),
    ),
    PulsingBorderPreset(
      'Northern lights',
      PulsingBorderParams(
        colorBack: '#0c182c',
        colors: <String>['#4c4794', '#774a7d', '#12694a', '#0aff78', '#4733cc'],
        roundness: 0,
        thickness: 1,
        softness: 1,
        intensity: 0.1,
        bloom: 0.2,
        spots: 4,
        spotSize: 0.25,
        pulse: 0,
        smoke: 0.32,
        smokeSize: 0.5,
        sizing: ShaderSizing.pattern(fit: ShaderFit.contain, scale: 1.1),
        speed: 0.18,
      ),
    ),
    PulsingBorderPreset(
      'Solid line',
      PulsingBorderParams(
        colorBack: '#00000000',
        colors: <String>['#81ADEC'],
        roundness: 0,
        thickness: 0.05,
        softness: 0,
        intensity: 0,
        bloom: 0.15,
        spots: 4,
        spotSize: 1,
        pulse: 0,
        smoke: 0,
        smokeSize: 0,
        sizing: ShaderSizing.pattern(fit: ShaderFit.contain),
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

/// Widget that renders the pulsing border shader.
class PulsingBorderView extends StatelessWidget {
  /// Creates pulsing border view.
  const PulsingBorderView({
    this.params = const PulsingBorderParams(),
    super.key,
  });

  /// Params.
  final PulsingBorderParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: PulsingBorderShader.assetKey,
      uniforms: params.uniforms,
      imageSamplers: PulsingBorderShader.imageSamplers,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}
