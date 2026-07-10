import 'shader_sampler.dart';
import 'shader_sizing.dart';
import 'shader_uniforms.dart';
import 'shaders/color_panels.dart';
import 'shaders/dithering.dart';
import 'shaders/dot_grid.dart';
import 'shaders/dot_orbit.dart';
import 'shaders/fluted_glass.dart';
import 'shaders/gem_smoke.dart';
import 'shaders/god_rays.dart';
import 'shaders/grain_gradient.dart';
import 'shaders/halftone_cmyk.dart';
import 'shaders/halftone_dots.dart';
import 'shaders/heatmap.dart';
import 'shaders/image_dithering.dart';
import 'shaders/liquid_metal.dart';
import 'shaders/mesh_gradient.dart';
import 'shaders/metaballs.dart';
import 'shaders/neuro_noise.dart';
import 'shaders/paper_texture.dart';
import 'shaders/perlin_noise.dart';
import 'shaders/pulsing_border.dart';
import 'shaders/simplex_noise.dart';
import 'shaders/smoke_ring.dart';
import 'shaders/spiral.dart';
import 'shaders/static_mesh_gradient.dart';
import 'shaders/static_radial_gradient.dart';
import 'shaders/swirl.dart';
import 'shaders/voronoi.dart';
import 'shaders/warp.dart';
import 'shaders/water.dart';
import 'shaders/waves.dart';

/// Shader catalog entry.
class ShaderCatalogEntry {
  /// Creates shader catalog entry.
  const ShaderCatalogEntry({
    required this.name,
    required this.assetKey,
    required this.presets,
    this.imageSamplers = const <ShaderImageSampler>[],
    this.isAnimated = true,
  });

  /// Name.
  final String name;

  /// Asset key.
  final String assetKey;

  /// Image samplers.
  final List<ShaderImageSampler> imageSamplers;

  /// Whether the fragment output depends on the global time uniform.
  final bool isAnimated;

  /// Presets.
  final List<ShaderPreset> presets;
}

/// Named preset for the shader shader.
class ShaderPreset {
  /// Creates shader preset.
  const ShaderPreset({
    required this.name,
    required this.sizing,
    required this.uniforms,
    required this.speed,
    this.frame = 0,
  });

  /// Name.
  final String name;

  /// Sizing.
  final ShaderSizing sizing;

  /// Uniforms.
  final List<ShaderUniform> uniforms;

  /// Speed.
  final double speed;

  /// Frame.
  final double frame;
}

/// Shader catalog.
class ShaderCatalog {
  /// Creates shader catalog.
  const ShaderCatalog._();

  /// Static all value.
  static final all = <ShaderCatalogEntry>[
    SimplexNoiseShader.catalogEntry,
    DotOrbitShader.catalogEntry,
    MeshGradientShader.catalogEntry,
    WavesShader.catalogEntry,
    PulsingBorderShader.catalogEntry,
    HalftoneCmykShader.catalogEntry,
    PaperTextureShader.catalogEntry,
    GrainGradientShader.catalogEntry,
    GemSmokeShader.catalogEntry,
    HalftoneDotsShader.catalogEntry,
    HeatmapShader.catalogEntry,
    ImageDitheringShader.catalogEntry,
    LiquidMetalShader.catalogEntry,
    ColorPanelsShader.catalogEntry,
    DitheringShader.catalogEntry,
    DotGridShader.catalogEntry,
    GodRaysShader.catalogEntry,
    MetaballsShader.catalogEntry,
    NeuroNoiseShader.catalogEntry,
    PerlinNoiseShader.catalogEntry,
    SmokeRingShader.catalogEntry,
    SpiralShader.catalogEntry,
    StaticMeshGradientShader.catalogEntry,
    StaticRadialGradientShader.catalogEntry,
    SwirlShader.catalogEntry,
    VoronoiShader.catalogEntry,
    WarpShader.catalogEntry,
    WaterShader.catalogEntry,
    FlutedGlassShader.catalogEntry,
  ];
}
