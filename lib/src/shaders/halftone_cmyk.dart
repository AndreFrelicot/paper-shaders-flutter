import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sampler.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Options for halftone cmyk type.
enum HalftoneCmykType {
  dots(0),
  ink(1),
  sharp(2);

  /// Creates halftone cmyk type.
  const HalftoneCmykType(this.uniformValue);

  /// Uniform value.
  final double uniformValue;
}

/// Parameters used to render the halftone cmyk shader.
class HalftoneCmykParams {
  /// Creates halftone cmyk params.
  const HalftoneCmykParams({
    this.colorBack = '#fbfaf5',
    this.colorC = '#00b4ff',
    this.colorM = '#fc519f',
    this.colorY = '#ffd800',
    this.colorK = '#231f20',
    this.size = 0.2,
    this.contrast = 1,
    this.grainSize = 0.5,
    this.grainMixer = 0,
    this.grainOverlay = 0,
    this.gridNoise = 0.2,
    this.softness = 1,
    this.floodC = 0.15,
    this.floodM = 0,
    this.floodY = 0,
    this.floodK = 0,
    this.gainC = 0.3,
    this.gainM = 0,
    this.gainY = 0.2,
    this.gainK = 0,
    this.type = HalftoneCmykType.ink,
    this.sizing = const ShaderSizing.object(
      fit: ShaderFit.cover,
      imageAspectRatio: _testImageAspectRatio,
    ),
    this.speed = 0,
    this.frame = 0,
  });

  /// Color back.
  final String colorBack;

  /// Color c.
  final String colorC;

  /// Color m.
  final String colorM;

  /// Color y.
  final String colorY;

  /// Color k.
  final String colorK;

  /// Size.
  final double size;

  /// Contrast.
  final double contrast;

  /// Grain size.
  final double grainSize;

  /// Grain mixer.
  final double grainMixer;

  /// Grain overlay.
  final double grainOverlay;

  /// Grid noise.
  final double gridNoise;

  /// Softness.
  final double softness;

  /// Flood c.
  final double floodC;

  /// Flood m.
  final double floodM;

  /// Flood y.
  final double floodY;

  /// Flood k.
  final double floodK;

  /// Gain c.
  final double gainC;

  /// Gain m.
  final double gainM;

  /// Gain y.
  final double gainY;

  /// Gain k.
  final double gainK;

  /// Type.
  final HalftoneCmykType type;

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
      Float4Uniform.color(colorC),
      Float4Uniform.color(colorM),
      Float4Uniform.color(colorY),
      Float4Uniform.color(colorK),
      FloatUniform(size),
      FloatUniform(contrast),
      FloatUniform(grainSize),
      FloatUniform(grainMixer),
      FloatUniform(grainOverlay),
      FloatUniform(gridNoise),
      FloatUniform(softness),
      FloatUniform(floodC),
      FloatUniform(floodM),
      FloatUniform(floodY),
      FloatUniform(floodK),
      FloatUniform(gainC),
      FloatUniform(gainM),
      FloatUniform(gainY),
      FloatUniform(gainK),
      FloatUniform(type.uniformValue),
    ];
  }
}

/// Named preset for the halftone cmyk shader.
class HalftoneCmykPreset {
  /// Creates halftone cmyk preset.
  const HalftoneCmykPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final HalftoneCmykParams params;
}

/// Catalog metadata for the halftone cmyk shader.
class HalftoneCmykShader {
  /// Creates halftone cmyk shader.
  const HalftoneCmykShader._();

  /// Static name value.
  static const name = 'halftone-cmyk';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/halftone_cmyk.frag';

  /// Static image samplers value.
  static const imageSamplers = <ShaderImageSampler>[
    ShaderImageSampler.testImage,
    ShaderImageSampler.noiseTexture,
  ];

  /// Static presets value.
  static const presets = <HalftoneCmykPreset>[
    HalftoneCmykPreset('Default', HalftoneCmykParams()),
    HalftoneCmykPreset(
      'Drops',
      HalftoneCmykParams(
        colorBack: '#eeefd7',
        colorC: '#00b2ff',
        colorM: '#fc4f4f',
        colorY: '#ffd900',
        size: 0.88,
        contrast: 1.15,
        grainSize: 0.01,
        grainMixer: 0.05,
        grainOverlay: 0.25,
        gridNoise: 0.5,
        softness: 0,
        gainC: 1,
        gainM: 0.44,
        gainY: -1,
      ),
    ),
    HalftoneCmykPreset(
      'Newspaper',
      HalftoneCmykParams(
        colorBack: '#f2f1e8',
        colorC: '#7a7a75',
        colorM: '#7a7a75',
        colorY: '#7a7a75',
        size: 0.01,
        contrast: 2,
        grainSize: 0,
        grainOverlay: 0.2,
        gridNoise: 0.6,
        softness: 0.2,
        floodC: 0,
        floodK: 0.1,
        gainC: -0.17,
        gainM: -0.45,
        gainY: -0.45,
        type: HalftoneCmykType.dots,
      ),
    ),
    HalftoneCmykPreset(
      'Vintage',
      HalftoneCmykParams(
        colorBack: '#fffaf0',
        colorC: '#59afc5',
        colorM: '#d8697c',
        colorY: '#fad85c',
        colorK: '#2d2824',
        contrast: 1.25,
        grainMixer: 0.15,
        grainOverlay: 0.1,
        gridNoise: 0.45,
        softness: 0.4,
        type: HalftoneCmykType.sharp,
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

/// Widget that renders the halftone cmyk shader.
class HalftoneCmykView extends StatelessWidget {
  /// Creates halftone cmyk view.
  const HalftoneCmykView({this.params = const HalftoneCmykParams(), super.key});

  /// Params.
  final HalftoneCmykParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: HalftoneCmykShader.assetKey,
      uniforms: params.uniforms,
      imageSamplers: HalftoneCmykShader.imageSamplers,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}

const double _testImageAspectRatio = 1500 / 1124;
