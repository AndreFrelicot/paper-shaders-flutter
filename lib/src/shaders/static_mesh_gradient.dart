import 'package:flutter/widgets.dart';

import '../shader_catalog.dart';
import '../shader_mount.dart';
import '../shader_sizing.dart';
import '../shader_uniforms.dart';

/// Parameters used to render the static mesh gradient shader.
class StaticMeshGradientParams {
  /// Creates static mesh gradient params.
  const StaticMeshGradientParams({
    this.colors = const <String>['#ffad0a', '#6200ff', '#e2a3ff', '#ff99fd'],
    this.positions = 2,
    this.waveX = 1,
    this.waveXShift = 0.6,
    this.waveY = 1,
    this.waveYShift = 0.21,
    this.mixing = 0.93,
    this.grainMixer = 0,
    this.grainOverlay = 0,
    this.sizing = const ShaderSizing(fit: ShaderFit.contain, rotation: 270),
    this.speed = 0,
    this.frame = 0,
  });

  /// Colors.
  final List<String> colors;

  /// Positions.
  final double positions;

  /// Wave x.
  final double waveX;

  /// Wave xshift.
  final double waveXShift;

  /// Wave y.
  final double waveY;

  /// Wave yshift.
  final double waveYShift;

  /// Mixing.
  final double mixing;

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
      FloatUniform(positions),
      FloatUniform(waveX),
      FloatUniform(waveXShift),
      FloatUniform(waveY),
      FloatUniform(waveYShift),
      FloatUniform(mixing),
      FloatUniform(grainMixer),
      FloatUniform(grainOverlay),
    ];
  }
}

/// Named preset for the static mesh gradient shader.
class StaticMeshGradientPreset {
  /// Creates static mesh gradient preset.
  const StaticMeshGradientPreset(this.name, this.params);

  /// Name.
  final String name;

  /// Params.
  final StaticMeshGradientParams params;
}

/// Catalog metadata for the static mesh gradient shader.
class StaticMeshGradientShader {
  /// Creates static mesh gradient shader.
  const StaticMeshGradientShader._();

  /// Static name value.
  static const name = 'static-mesh-gradient';

  /// Static asset key value.
  static const assetKey =
      'packages/paper_shaders/shaders/static_mesh_gradient.frag';
  static const isAnimated = false;

  /// Static presets value.
  static const presets = <StaticMeshGradientPreset>[
    StaticMeshGradientPreset('Default', StaticMeshGradientParams()),
    StaticMeshGradientPreset(
      '1960s',
      StaticMeshGradientParams(
        colors: <String>['#000000', '#082400', '#b1aa91', '#8e8c15'],
        positions: 42,
        waveX: 0.45,
        waveXShift: 0,
        waveYShift: 0,
        mixing: 0,
        grainMixer: 0.37,
        grainOverlay: 0.78,
        sizing: ShaderSizing(fit: ShaderFit.contain),
      ),
    ),
    StaticMeshGradientPreset(
      'Sunset',
      StaticMeshGradientParams(
        colors: <String>['#264653', '#9c2b2b', '#f4a261', '#ffffff'],
        positions: 0,
        waveX: 0.6,
        waveXShift: 0.7,
        waveY: 0.7,
        waveYShift: 0.7,
        mixing: 0.5,
        sizing: ShaderSizing(fit: ShaderFit.contain),
      ),
    ),
    StaticMeshGradientPreset(
      'Sea',
      StaticMeshGradientParams(
        colors: <String>['#013b65', '#03738c', '#a3d3ff', '#f2faef'],
        positions: 0,
        waveX: 0.53,
        waveXShift: 0,
        waveY: 0.95,
        waveYShift: 0.64,
        mixing: 0.5,
        sizing: ShaderSizing(fit: ShaderFit.contain),
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

/// Widget that renders the static mesh gradient shader.
class StaticMeshGradientView extends StatelessWidget {
  /// Creates static mesh gradient view.
  const StaticMeshGradientView({
    this.params = const StaticMeshGradientParams(),
    super.key,
  });

  /// Params.
  final StaticMeshGradientParams params;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    return PaperShader(
      assetKey: StaticMeshGradientShader.assetKey,
      isAnimated: StaticMeshGradientShader.isAnimated,
      uniforms: params.uniforms,
      sizing: params.sizing,
      speed: params.speed,
      frame: params.frame,
    );
  }
}
