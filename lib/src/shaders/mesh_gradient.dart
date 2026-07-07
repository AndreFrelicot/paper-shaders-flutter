import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Parameters used to render the mesh gradient shader.
class MeshGradientParams {
  /// Creates mesh gradient params.
  const MeshGradientParams({
    this.colors = const <String>['#e0eaff', '#241d9a', '#f75092', '#9f50d3'],
    this.distortion = 0.8,
    this.swirl = 0.1,
    this.grainMixer = 0,
    this.grainOverlay = 0,
    this.sizing = const ShaderSizing.object(fit: ShaderFit.contain),
    this.speed = 1,
    this.frame = 0,
  });

  /// Colors.
  final List<String> colors;

  /// Distortion.
  final double distortion;

  /// Swirl.
  final double swirl;

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
      Float4ArrayUniform.colors(colors, capacity: 10),
      FloatUniform(colors.isEmpty ? 1 : colors.length.toDouble()),
      FloatUniform(distortion),
      FloatUniform(swirl),
      FloatUniform(grainMixer),
      FloatUniform(grainOverlay),
    ];
  }
}

/// Named preset for the mesh gradient shader.
class MeshGradientPreset {
  /// Creates mesh gradient preset.
  const MeshGradientPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final MeshGradientParams params;
}

/// Catalog metadata for the mesh gradient shader.
class MeshGradientShader {
  /// Creates mesh gradient shader.
  const MeshGradientShader._();

  /// Static name value.
  static const name = 'mesh-gradient';

  /// Static asset key value.
  static const assetKey = 'packages/paper_shaders/shaders/mesh_gradient.frag';

  /// Static presets value.
  static const presets = <MeshGradientPreset>[
    MeshGradientPreset('Default', MeshGradientParams()),
    MeshGradientPreset(
      'Ink',
      MeshGradientParams(
        colors: <String>['#ffffff', '#000000'],
        distortion: 1,
        swirl: 0.2,
        sizing: ShaderSizing.object(fit: ShaderFit.contain, rotation: 90),
        speed: 1,
      ),
    ),
    MeshGradientPreset(
      'Purple',
      MeshGradientParams(
        colors: <String>['#aaa7d7', '#3c2b8e'],
        distortion: 1,
        swirl: 1,
        sizing: ShaderSizing.object(fit: ShaderFit.contain),
        speed: 0.6,
      ),
    ),
    MeshGradientPreset(
      'Beach',
      MeshGradientParams(
        colors: <String>['#bcecf6', '#00aaff', '#00f7ff', '#ffd447'],
        distortion: 0.8,
        swirl: 0.35,
        sizing: ShaderSizing.object(fit: ShaderFit.contain),
        speed: 0.1,
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

/// Widget that renders the mesh gradient shader.
class MeshGradientView extends StatelessWidget {
  /// Creates mesh gradient view.
  const MeshGradientView({this.params = const MeshGradientParams(), super.key});

  /// Params.
  final MeshGradientParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: MeshGradientShader.assetKey,
      uniforms: params.uniforms,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}
