import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:paper_shaders/paper_shaders.dart';

import 'golden_environment.dart';
import 'showcase_uniforms.dart';

void main() {
  final goldenTargets = _buildGoldenTargets();
  if (shouldListGoldenTargets) {
    printGoldenTargets(goldenTargets.keys);
    exitGoldenRenderer(0);
  }

  final target = goldenTarget;
  if (target.isNotEmpty) {
    final selected = goldenTargets[target];
    if (selected == null) {
      throw StateError('Unknown golden target: $target');
    }
    runApp(PaperShadersGoldenApp(target: selected));
    return;
  }

  runApp(const PaperShadersExampleApp());
}

class PaperShadersExampleApp extends StatelessWidget {
  const PaperShadersExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Paper Shaders',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffd7ff42),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Avenir Next',
        sliderTheme: const SliderThemeData(
          showValueIndicator: ShowValueIndicator.never,
          trackHeight: 2,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
        ),
      ),
      home: const ShaderShowcaseScreen(),
    );
  }
}

class ShaderShowcaseScreen extends StatefulWidget {
  const ShaderShowcaseScreen({super.key});

  @override
  State<ShaderShowcaseScreen> createState() => _ShaderShowcaseScreenState();
}

class _ShaderShowcaseScreenState extends State<ShaderShowcaseScreen> {
  var _shaderIndex = 0;
  var _presetIndex = 0;
  var _showControls = false;
  var _showShaderStrip = false;
  var _showFullscreen = false;
  var _showFpsHud = true;
  String? _activeSliderKey;
  late List<ShaderUniform> _uniforms;
  late ShaderSizing _sizing;
  late double _speed;
  late double _frame;

  ShaderCatalogEntry get _entry => ShaderCatalog.all[_shaderIndex];

  ShaderPreset get _preset => _entry.presets[_presetIndex];

  List<ShowcaseUniformSpec> get _specs {
    return showcaseUniforms[_entry.name] ?? const <ShowcaseUniformSpec>[];
  }

  @override
  void initState() {
    super.initState();
    _applyPreset();
  }

  void _selectShader(int index) {
    setState(() {
      _shaderIndex = index;
      _presetIndex = 0;
      _showShaderStrip = false;
      _activeSliderKey = null;
      _applyPreset();
    });
  }

  void _selectPreset(int index) {
    setState(() {
      _presetIndex = index;
      _activeSliderKey = null;
      _applyPreset();
    });
  }

  void _setActiveSlider(String? key) {
    setState(() {
      _activeSliderKey = key;
    });
  }

  void _setShowFpsHud(bool value) {
    setState(() {
      _showFpsHud = value;
    });
  }

  void _applyPreset() {
    final preset = _preset;
    _uniforms = _cloneUniforms(preset.uniforms);
    _sizing = preset.sizing;
    _speed = preset.speed;
    _frame = preset.frame;
  }

  void _setSizing(ShaderSizing sizing) {
    setState(() {
      _sizing = sizing;
    });
  }

  void _setSpeed(double speed) {
    setState(() {
      _speed = speed;
    });
  }

  void _setFrame(double frame) {
    setState(() {
      _frame = frame;
    });
  }

  void _setUniform(int index, ShaderUniform uniform) {
    final next = _cloneUniforms(_uniforms);
    next[index] = uniform;
    setState(() {
      _uniforms = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff10110f),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (_showFullscreen) {
            return _FullscreenShowcase(
              entry: _entry,
              preset: _preset,
              uniforms: _uniforms,
              sizing: _sizing,
              speed: _speed,
              frame: _frame,
              showFpsHud: _showFpsHud,
              onDismissed: () {
                setState(() {
                  _showFullscreen = false;
                });
              },
            );
          }

          return SafeArea(
            child: Builder(
              builder: (context) {
                final wide = constraints.maxWidth >= 980;
                if (wide) {
                  return Row(
                    children: [
                      SizedBox(
                        width: 268,
                        child: _ShaderRail(
                          selectedIndex: _shaderIndex,
                          onSelected: _selectShader,
                        ),
                      ),
                      Expanded(
                        child: _PreviewPane(
                          entry: _entry,
                          preset: _preset,
                          uniforms: _uniforms,
                          sizing: _sizing,
                          speed: _speed,
                          frame: _frame,
                          showFpsHud: _showFpsHud,
                          onFullscreenPressed: () {
                            setState(() {
                              _showFullscreen = true;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 372,
                        child: _ControlPane(
                          entry: _entry,
                          presetIndex: _presetIndex,
                          uniforms: _uniforms,
                          specs: _specs,
                          sizing: _sizing,
                          speed: _speed,
                          frame: _frame,
                          showFpsHud: _showFpsHud,
                          activeSliderKey: _activeSliderKey,
                          onPresetSelected: _selectPreset,
                          onSizingChanged: _setSizing,
                          onSpeedChanged: _setSpeed,
                          onFrameChanged: _setFrame,
                          onUniformChanged: _setUniform,
                          onShowFpsHudChanged: _setShowFpsHud,
                          onActiveSliderChanged: _setActiveSlider,
                        ),
                      ),
                    ],
                  );
                }

                return _CompactShowcase(
                  entry: _entry,
                  preset: _preset,
                  shaderIndex: _shaderIndex,
                  presetIndex: _presetIndex,
                  showControls: _showControls,
                  showShaderStrip: _showShaderStrip,
                  uniforms: _uniforms,
                  specs: _specs,
                  sizing: _sizing,
                  speed: _speed,
                  frame: _frame,
                  showFpsHud: _showFpsHud,
                  activeSliderKey: _activeSliderKey,
                  onShaderStripToggled: () {
                    setState(() {
                      _showShaderStrip = !_showShaderStrip;
                    });
                  },
                  onControlsToggled: () {
                    setState(() {
                      _showControls = !_showControls;
                    });
                  },
                  onFullscreenPressed: () {
                    setState(() {
                      _showFullscreen = true;
                    });
                  },
                  onShaderSelected: _selectShader,
                  onPresetSelected: _selectPreset,
                  onSizingChanged: _setSizing,
                  onSpeedChanged: _setSpeed,
                  onFrameChanged: _setFrame,
                  onUniformChanged: _setUniform,
                  onShowFpsHudChanged: _setShowFpsHud,
                  onActiveSliderChanged: _setActiveSlider,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CompactShowcase extends StatelessWidget {
  const _CompactShowcase({
    required this.entry,
    required this.preset,
    required this.shaderIndex,
    required this.presetIndex,
    required this.showControls,
    required this.showShaderStrip,
    required this.uniforms,
    required this.specs,
    required this.sizing,
    required this.speed,
    required this.frame,
    required this.showFpsHud,
    required this.activeSliderKey,
    required this.onShaderStripToggled,
    required this.onControlsToggled,
    required this.onFullscreenPressed,
    required this.onShaderSelected,
    required this.onPresetSelected,
    required this.onSizingChanged,
    required this.onSpeedChanged,
    required this.onFrameChanged,
    required this.onUniformChanged,
    required this.onShowFpsHudChanged,
    required this.onActiveSliderChanged,
  });

  final ShaderCatalogEntry entry;
  final ShaderPreset preset;
  final int shaderIndex;
  final int presetIndex;
  final bool showControls;
  final bool showShaderStrip;
  final List<ShaderUniform> uniforms;
  final List<ShowcaseUniformSpec> specs;
  final ShaderSizing sizing;
  final double speed;
  final double frame;
  final bool showFpsHud;
  final String? activeSliderKey;
  final VoidCallback onShaderStripToggled;
  final VoidCallback onControlsToggled;
  final VoidCallback onFullscreenPressed;
  final ValueChanged<int> onShaderSelected;
  final ValueChanged<int> onPresetSelected;
  final ValueChanged<ShaderSizing> onSizingChanged;
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<double> onFrameChanged;
  final void Function(int index, ShaderUniform uniform) onUniformChanged;
  final ValueChanged<bool> onShowFpsHudChanged;
  final ValueChanged<String?> onActiveSliderChanged;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final panelHeight = math.min(430.0, size.height * 0.58);
    final bottomButtonOffset = showControls ? panelHeight + 24 : 18.0;
    final shaderListBottom = showControls ? panelHeight + 26.0 : 12.0;
    final shaderListHeight = math.max(
      180.0,
      size.height - shaderListBottom - 92.0,
    );
    final shaderListWidth = math.min(360.0, size.width - 24.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        _PreviewPane(
          entry: entry,
          preset: preset,
          uniforms: uniforms,
          sizing: sizing,
          speed: speed,
          frame: frame,
          showFpsHud: showFpsHud,
          fullBleed: true,
        ),
        Positioned(
          left: 12,
          right: 12,
          top: 0,
          child: SafeArea(
            bottom: false,
            child: _CompactTopBar(
              entry: entry,
              preset: preset,
              showControls: showControls,
              showShaderStrip: showShaderStrip,
              onShaderStripToggled: onShaderStripToggled,
              onControlsToggled: onControlsToggled,
              onFullscreenPressed: onFullscreenPressed,
            ),
          ),
        ),
        if (showShaderStrip)
          Positioned(
            left: 12,
            top: 72,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                width: shaderListWidth,
                height: shaderListHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _CompactShaderList(
                    selectedIndex: shaderIndex,
                    onSelected: onShaderSelected,
                  ),
                ),
              ),
            ),
          ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          right: 16,
          bottom: bottomButtonOffset,
          child: SafeArea(
            top: false,
            child: FloatingActionButton.small(
              heroTag: 'controls-toggle',
              backgroundColor: const Color(0xcc171813),
              foregroundColor: const Color(0xfff7f6ec),
              onPressed: onControlsToggled,
              child: Icon(showControls ? Icons.close : Icons.tune_rounded),
            ),
          ),
        ),
        if (showControls)
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: SafeArea(
              top: false,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  height: panelHeight,
                  child: _ControlPane(
                    entry: entry,
                    presetIndex: presetIndex,
                    uniforms: uniforms,
                    specs: specs,
                    sizing: sizing,
                    speed: speed,
                    frame: frame,
                    showFpsHud: showFpsHud,
                    activeSliderKey: activeSliderKey,
                    floating: true,
                    onPresetSelected: onPresetSelected,
                    onSizingChanged: onSizingChanged,
                    onSpeedChanged: onSpeedChanged,
                    onFrameChanged: onFrameChanged,
                    onUniformChanged: onUniformChanged,
                    onShowFpsHudChanged: onShowFpsHudChanged,
                    onActiveSliderChanged: onActiveSliderChanged,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CompactTopBar extends StatelessWidget {
  const _CompactTopBar({
    required this.entry,
    required this.preset,
    required this.showControls,
    required this.showShaderStrip,
    required this.onShaderStripToggled,
    required this.onControlsToggled,
    required this.onFullscreenPressed,
  });

  final ShaderCatalogEntry entry;
  final ShaderPreset preset;
  final bool showControls;
  final bool showShaderStrip;
  final VoidCallback onShaderStripToggled;
  final VoidCallback onControlsToggled;
  final VoidCallback onFullscreenPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xcc171813),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x442b2d25)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Shaders',
              visualDensity: VisualDensity.compact,
              onPressed: onShaderStripToggled,
              icon: Icon(
                showShaderStrip
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.grid_view_rounded,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xfff7f6ec),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    preset.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xffc0c6b2),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Fullscreen',
              visualDensity: VisualDensity.compact,
              onPressed: onFullscreenPressed,
              icon: const Icon(Icons.fullscreen_rounded),
            ),
            IconButton(
              tooltip: 'Controls',
              visualDensity: VisualDensity.compact,
              onPressed: onControlsToggled,
              icon: Icon(showControls ? Icons.close : Icons.tune_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullscreenShowcase extends StatelessWidget {
  const _FullscreenShowcase({
    required this.entry,
    required this.preset,
    required this.uniforms,
    required this.sizing,
    required this.speed,
    required this.frame,
    required this.showFpsHud,
    required this.onDismissed,
  });

  final ShaderCatalogEntry entry;
  final ShaderPreset preset;
  final List<ShaderUniform> uniforms;
  final ShaderSizing sizing;
  final double speed;
  final double frame;
  final bool showFpsHud;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _PreviewPane(
          entry: entry,
          preset: preset,
          uniforms: uniforms,
          sizing: sizing,
          speed: speed,
          frame: frame,
          showFpsHud: showFpsHud,
          fullBleed: true,
        ),
        Positioned(
          top: 16,
          right: 16,
          child: SafeArea(
            child: FloatingActionButton.small(
              heroTag: 'fullscreen-exit',
              backgroundColor: const Color(0xaa171813),
              foregroundColor: const Color(0xfff7f6ec),
              onPressed: onDismissed,
              child: const Icon(Icons.close_rounded),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShaderRail extends StatelessWidget {
  const _ShaderRail({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xff171813),
        border: Border(right: BorderSide(color: Color(0xff2b2d25))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 22, 20, 12),
            child: Text(
              'Paper Shaders',
              style: TextStyle(
                color: Color(0xfff7f6ec),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              '29 shaders / 120 presets',
              style: TextStyle(color: Color(0xffa7ac97), fontSize: 12),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 18),
              itemCount: ShaderCatalog.all.length,
              itemBuilder: (context, index) {
                final entry = ShaderCatalog.all[index];
                final selected = index == selectedIndex;
                return _ShaderListButton(
                  entry: entry,
                  selected: selected,
                  onTap: () => onSelected(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactShaderList extends StatelessWidget {
  const _CompactShaderList({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xcc171813),
        border: Border.all(color: const Color(0x442b2d25)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: ShaderCatalog.all.length,
        itemExtent: 52,
        itemBuilder: (context, index) {
          final entry = ShaderCatalog.all[index];
          final selected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Material(
              color: selected
                  ? const Color(0xffd7ff42)
                  : const Color(0xdd25271f),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onSelected(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      _ShaderThumbnail(name: entry.name, size: 34),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected
                                ? const Color(0xff11120e)
                                : const Color(0xfff2f0e6),
                            fontSize: 13,
                            fontWeight: selected
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${entry.presets.length}',
                        style: TextStyle(
                          color: selected
                              ? const Color(0xff3b3d2d)
                              : const Color(0xff9aa08d),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ShaderListButton extends StatelessWidget {
  const _ShaderListButton({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  final ShaderCatalogEntry entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? const Color(0xffd7ff42) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                _ShaderThumbnail(name: entry.name, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? const Color(0xff11120e)
                          : const Color(0xfff2f0e6),
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${entry.presets.length}',
                  style: TextStyle(
                    color: selected
                        ? const Color(0xff3b3d2d)
                        : const Color(0xff777c6d),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShaderChip extends StatelessWidget {
  const _ShaderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xffd7ff42) : const Color(0xff25271f),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? const Color(0xff11120e) : Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShaderThumbnail extends StatelessWidget {
  const _ShaderThumbnail({required this.name, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xff25271f),
          border: Border.all(color: const Color(0x332b2d25)),
        ),
        child: Image.asset(
          'assets/thumbnails/$name.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return SizedBox(
              width: size,
              height: size,
              child: const Icon(
                Icons.blur_on_rounded,
                color: Color(0xffc8ccba),
                size: 18,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PreviewPane extends StatelessWidget {
  const _PreviewPane({
    required this.entry,
    required this.preset,
    required this.uniforms,
    required this.sizing,
    required this.speed,
    required this.frame,
    required this.showFpsHud,
    this.fullBleed = false,
    this.onFullscreenPressed,
  });

  final ShaderCatalogEntry entry;
  final ShaderPreset preset;
  final List<ShaderUniform> uniforms;
  final ShaderSizing sizing;
  final double speed;
  final double frame;
  final bool showFpsHud;
  final bool fullBleed;
  final VoidCallback? onFullscreenPressed;

  @override
  Widget build(BuildContext context) {
    if (fullBleed) {
      return ColoredBox(
        color: Colors.white,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PaperShader(
              key: ValueKey(entry.assetKey),
              assetKey: entry.assetKey,
              uniforms: uniforms,
              imageSamplers: entry.imageSamplers,
              sizing: sizing,
              speed: speed,
              frame: frame,
            ),
            if (showFpsHud)
              const Positioned(left: 16, bottom: 16, child: _FpsHud()),
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0x18000000), width: 1),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xfff7f6ec),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (onFullscreenPressed != null)
                IconButton(
                  tooltip: 'Fullscreen',
                  onPressed: onFullscreenPressed,
                  icon: const Icon(Icons.fullscreen_rounded),
                ),
              if (onFullscreenPressed != null) const SizedBox(width: 4),
              Text(
                preset.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xffa7ac97),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xff303227)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 30,
                    offset: Offset(0, 18),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ColoredBox(
                  color: Colors.white,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PaperShader(
                        key: ValueKey(entry.assetKey),
                        assetKey: entry.assetKey,
                        uniforms: uniforms,
                        imageSamplers: entry.imageSamplers,
                        sizing: sizing,
                        speed: speed,
                        frame: frame,
                      ),
                      if (showFpsHud)
                        const Positioned(
                          left: 14,
                          bottom: 14,
                          child: _FpsHud(),
                        ),
                      IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0x24000000),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FpsHud extends StatefulWidget {
  const _FpsHud();

  @override
  State<_FpsHud> createState() => _FpsHudState();
}

class _FpsHudState extends State<_FpsHud> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration? _windowStart;
  Duration? _lastElapsed;
  var _frames = 0;
  var _fps = 0.0;
  var _frameMs = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    _frames += 1;
    final windowStart = _windowStart ?? elapsed;
    final lastElapsed = _lastElapsed ?? elapsed;
    _windowStart = windowStart;
    _lastElapsed = elapsed;
    _frameMs = (elapsed - lastElapsed).inMicroseconds / 1000;

    if (elapsed - windowStart >= const Duration(milliseconds: 500)) {
      setState(() {
        _fps = _frames * 1000 / (elapsed - windowStart).inMicroseconds * 1000;
        _frames = 0;
        _windowStart = elapsed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final viewport = media.size;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x8a000000),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x28ffffff)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: DefaultTextStyle(
          style: const TextStyle(
            color: Color(0xffffffff),
            fontSize: 11,
            fontFeatures: [ui.FontFeature.tabularFigures()],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _HudLine(label: 'FPS', value: _fps.toStringAsFixed(0)),
              _HudLine(
                label: 'Frame',
                value: '${_frameMs.toStringAsFixed(1)} ms',
              ),
              _HudLine(
                label: 'Viewport',
                value:
                    '${viewport.width.toStringAsFixed(0)}x${viewport.height.toStringAsFixed(0)}',
              ),
              _HudLine(
                label: 'DPR',
                value: media.devicePixelRatio.toStringAsFixed(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HudLine extends StatelessWidget {
  const _HudLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 176,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xb3ffffff)),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ControlPane extends StatelessWidget {
  const _ControlPane({
    required this.entry,
    required this.presetIndex,
    required this.uniforms,
    required this.specs,
    required this.sizing,
    required this.speed,
    required this.frame,
    required this.showFpsHud,
    required this.activeSliderKey,
    required this.onPresetSelected,
    required this.onSizingChanged,
    required this.onSpeedChanged,
    required this.onFrameChanged,
    required this.onUniformChanged,
    required this.onShowFpsHudChanged,
    required this.onActiveSliderChanged,
    this.floating = false,
  });

  final ShaderCatalogEntry entry;
  final int presetIndex;
  final List<ShaderUniform> uniforms;
  final List<ShowcaseUniformSpec> specs;
  final ShaderSizing sizing;
  final double speed;
  final double frame;
  final bool showFpsHud;
  final String? activeSliderKey;
  final ValueChanged<int> onPresetSelected;
  final ValueChanged<ShaderSizing> onSizingChanged;
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<double> onFrameChanged;
  final void Function(int index, ShaderUniform uniform) onUniformChanged;
  final ValueChanged<bool> onShowFpsHudChanged;
  final ValueChanged<String?> onActiveSliderChanged;
  final bool floating;

  @override
  Widget build(BuildContext context) {
    final visibleSliderKey = floating ? activeSliderKey : null;
    final dragging = visibleSliderKey != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: floating
            ? (dragging ? const Color(0x00171813) : const Color(0xcc171813))
            : const Color(0xff171813),
        border: Border(
          left: BorderSide(
            color: floating ? const Color(0x442b2d25) : const Color(0xff2b2d25),
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
        children: [
          _ControlDragVisibility(
            activeSliderKey: visibleSliderKey,
            child: const _SectionTitle('Preset'),
          ),
          _ControlDragVisibility(
            activeSliderKey: visibleSliderKey,
            child: _PresetSelector(
              entry: entry,
              selectedIndex: presetIndex,
              onSelected: onPresetSelected,
            ),
          ),
          const SizedBox(height: 20),
          _ControlDragVisibility(
            activeSliderKey: visibleSliderKey,
            child: const _SectionTitle('Motion'),
          ),
          _ControlDragVisibility(
            activeSliderKey: visibleSliderKey,
            controlKey: 'motion.speed',
            child: _NumberControl(
              label: 'Speed',
              value: speed,
              min: 0,
              max: 4,
              divisions: 80,
              sliderKey: 'motion.speed',
              activeSliderKey: visibleSliderKey,
              onChanged: onSpeedChanged,
              onActiveSliderChanged: onActiveSliderChanged,
            ),
          ),
          _ControlDragVisibility(
            activeSliderKey: visibleSliderKey,
            controlKey: 'motion.frame',
            child: _NumberControl(
              label: 'Frame',
              value: frame,
              min: 0,
              max: 120000,
              divisions: 240,
              sliderKey: 'motion.frame',
              activeSliderKey: visibleSliderKey,
              onChanged: onFrameChanged,
              onActiveSliderChanged: onActiveSliderChanged,
            ),
          ),
          const SizedBox(height: 20),
          _ControlDragVisibility(
            activeSliderKey: visibleSliderKey,
            child: const _SectionTitle('Sizing'),
          ),
          _ControlDragVisibility(
            activeSliderKey: visibleSliderKey,
            child: _FitControl(
              sizing: sizing,
              onChanged: (fit) =>
                  onSizingChanged(_copySizing(sizing, fit: fit)),
            ),
          ),
          _ControlDragVisibility(
            activeSliderKey: visibleSliderKey,
            controlKey: 'sizing.scale',
            child: _NumberControl(
              label: 'Scale',
              value: sizing.scale,
              min: 0.05,
              max: 5,
              sliderKey: 'sizing.scale',
              activeSliderKey: visibleSliderKey,
              onChanged: (value) {
                onSizingChanged(_copySizing(sizing, scale: value));
              },
              onActiveSliderChanged: onActiveSliderChanged,
            ),
          ),
          _ControlDragVisibility(
            activeSliderKey: visibleSliderKey,
            controlKey: 'sizing.rotation',
            child: _NumberControl(
              label: 'Rotation',
              value: sizing.rotation,
              min: -360,
              max: 360,
              sliderKey: 'sizing.rotation',
              activeSliderKey: visibleSliderKey,
              onChanged: (value) {
                onSizingChanged(_copySizing(sizing, rotation: value));
              },
              onActiveSliderChanged: onActiveSliderChanged,
            ),
          ),
          _ControlDragVisibility(
            activeSliderKey: visibleSliderKey,
            controlKey: 'sizing.offsetX',
            child: _NumberControl(
              label: 'Offset X',
              value: sizing.offsetX,
              min: -1,
              max: 1,
              sliderKey: 'sizing.offsetX',
              activeSliderKey: visibleSliderKey,
              onChanged: (value) {
                onSizingChanged(_copySizing(sizing, offsetX: value));
              },
              onActiveSliderChanged: onActiveSliderChanged,
            ),
          ),
          _ControlDragVisibility(
            activeSliderKey: visibleSliderKey,
            controlKey: 'sizing.offsetY',
            child: _NumberControl(
              label: 'Offset Y',
              value: sizing.offsetY,
              min: -1,
              max: 1,
              sliderKey: 'sizing.offsetY',
              activeSliderKey: visibleSliderKey,
              onChanged: (value) {
                onSizingChanged(_copySizing(sizing, offsetY: value));
              },
              onActiveSliderChanged: onActiveSliderChanged,
            ),
          ),
          const SizedBox(height: 20),
          _ControlDragVisibility(
            activeSliderKey: visibleSliderKey,
            child: const _SectionTitle('Shader'),
          ),
          for (
            var index = 0;
            index < math.min(specs.length, uniforms.length);
            index += 1
          )
            _ControlDragVisibility(
              activeSliderKey: visibleSliderKey,
              controlKey: 'uniform.$index',
              child: _UniformControl(
                spec: specs[index],
                uniform: uniforms[index],
                presets: entry.presets,
                uniformIndex: index,
                activeSliderKey: visibleSliderKey,
                onChanged: (uniform) => onUniformChanged(index, uniform),
                onActiveSliderChanged: onActiveSliderChanged,
              ),
            ),
          const SizedBox(height: 20),
          _ControlDragVisibility(
            activeSliderKey: visibleSliderKey,
            child: const _SectionTitle('Render'),
          ),
          _ControlDragVisibility(
            activeSliderKey: visibleSliderKey,
            child: _BooleanControl(
              label: 'Show FPS HUD',
              value: showFpsHud,
              onChanged: onShowFpsHudChanged,
            ),
          ),
          const SizedBox(height: 20),
          _ControlDragVisibility(
            activeSliderKey: visibleSliderKey,
            child: const _SectionTitle('Code'),
          ),
          _ControlDragVisibility(
            activeSliderKey: visibleSliderKey,
            child: _CodeSnippetCard(
              title: 'Dart preset',
              snippet: _dartInitializationSnippet(
                entry: entry,
                specs: specs,
                uniforms: uniforms,
                sizing: sizing,
                speed: speed,
                frame: frame,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetSelector extends StatelessWidget {
  const _PresetSelector({
    required this.entry,
    required this.selectedIndex,
    required this.onSelected,
  });

  final ShaderCatalogEntry entry;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var index = 0; index < entry.presets.length; index += 1)
          _ShaderChip(
            label: entry.presets[index].name,
            selected: index == selectedIndex,
            onTap: () => onSelected(index),
          ),
      ],
    );
  }
}

class _FitControl extends StatelessWidget {
  const _FitControl({required this.sizing, required this.onChanged});

  final ShaderSizing sizing;
  final ValueChanged<ShaderFit> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Fit',
              style: TextStyle(color: Color(0xffdfe2d2), fontSize: 13),
            ),
          ),
          DropdownButton<ShaderFit>(
            value: sizing.fit,
            dropdownColor: const Color(0xff25271f),
            underline: const SizedBox.shrink(),
            borderRadius: BorderRadius.circular(8),
            items: const [
              DropdownMenuItem(value: ShaderFit.none, child: Text('None')),
              DropdownMenuItem(
                value: ShaderFit.contain,
                child: Text('Contain'),
              ),
              DropdownMenuItem(value: ShaderFit.cover, child: Text('Cover')),
            ],
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _UniformControl extends StatelessWidget {
  const _UniformControl({
    required this.spec,
    required this.uniform,
    required this.presets,
    required this.uniformIndex,
    required this.activeSliderKey,
    required this.onChanged,
    required this.onActiveSliderChanged,
  });

  final ShowcaseUniformSpec spec;
  final ShaderUniform uniform;
  final List<ShaderPreset> presets;
  final int uniformIndex;
  final String? activeSliderKey;
  final ValueChanged<ShaderUniform> onChanged;
  final ValueChanged<String?> onActiveSliderChanged;

  @override
  Widget build(BuildContext context) {
    return switch (spec.kind) {
      ShowcaseUniformKind.float => _buildFloatControl(),
      ShowcaseUniformKind.color => _buildColorControl(),
      ShowcaseUniformKind.colorArray => _buildColorArrayControl(),
    };
  }

  Widget _buildFloatControl() {
    final value = uniform is FloatUniform
        ? (uniform as FloatUniform).value
        : 0.0;

    if (_isSwitchSpec(spec.name)) {
      return _SwitchControl(
        label: spec.label,
        value: value >= 0.5,
        onChanged: (enabled) {
          onChanged(FloatUniform(enabled ? 1 : 0));
        },
      );
    }

    final range = _rangeForFloat(spec.name, uniformIndex, value, presets);
    return _NumberControl(
      label: spec.label,
      value: value.clamp(range.min, range.max),
      min: range.min,
      max: range.max,
      divisions: range.divisions,
      sliderKey: 'uniform.$uniformIndex',
      activeSliderKey: activeSliderKey,
      onChanged: (next) => onChanged(FloatUniform(next)),
      onActiveSliderChanged: onActiveSliderChanged,
    );
  }

  Widget _buildColorControl() {
    final value = uniform is Float4Uniform
        ? _colorFromPremultiplied((uniform as Float4Uniform).values)
        : Colors.white;
    return _ColorControl(
      label: spec.label,
      colors: [value],
      onColorChanged: (_, color) {
        onChanged(Float4Uniform(_premultiplied(color)));
      },
    );
  }

  Widget _buildColorArrayControl() {
    final value = uniform is Float4ArrayUniform
        ? uniform as Float4ArrayUniform
        : const Float4ArrayUniform(<List<double>>[], capacity: 0);
    final colors = <Color>[
      for (final item in value.values) _colorFromPremultiplied(item),
    ];
    return _ColorControl(
      label: spec.label,
      colors: colors,
      onColorChanged: (index, color) {
        if (index >= value.values.length) {
          return;
        }
        final nextValues = <List<double>>[
          for (final item in value.values) List<double>.of(item),
        ];
        nextValues[index] = _premultiplied(color);
        onChanged(Float4ArrayUniform(nextValues, capacity: value.capacity));
      },
    );
  }
}

class _BooleanControl extends StatelessWidget {
  const _BooleanControl({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xffdfe2d2), fontSize: 13),
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _NumberControl extends StatelessWidget {
  const _NumberControl({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.sliderKey,
    required this.activeSliderKey,
    required this.onActiveSliderChanged,
    this.divisions,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String sliderKey;
  final String? activeSliderKey;
  final ValueChanged<String?> onActiveSliderChanged;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(min, max);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xffdfe2d2),
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                _formatNumber(value),
                style: const TextStyle(
                  color: Color(0xff9aa08d),
                  fontSize: 12,
                  fontFeatures: [ui.FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          Slider(
            value: clamped,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            onChangeStart: (_) => onActiveSliderChanged(sliderKey),
            onChangeEnd: (_) => onActiveSliderChanged(null),
          ),
        ],
      ),
    );
  }
}

class _ControlDragVisibility extends StatelessWidget {
  const _ControlDragVisibility({
    required this.activeSliderKey,
    required this.child,
    this.controlKey,
  });

  final String? activeSliderKey;
  final String? controlKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final focused = activeSliderKey == null || activeSliderKey == controlKey;
    return IgnorePointer(
      ignoring: !focused,
      child: AnimatedOpacity(
        opacity: focused ? 1 : 0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }
}

class _SwitchControl extends StatelessWidget {
  const _SwitchControl({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xffdfe2d2), fontSize: 13),
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ColorControl extends StatelessWidget {
  const _ColorControl({
    required this.label,
    required this.colors,
    required this.onColorChanged,
  });

  final String label;
  final List<Color> colors;
  final void Function(int index, Color color) onColorChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xffdfe2d2), fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (var index = 0; index < colors.length; index += 1)
                Tooltip(
                  message: _hexColor(colors[index]),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () async {
                      final selected = await _pickColor(context, colors[index]);
                      if (selected != null) {
                        onColorChanged(index, selected);
                      }
                    },
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors[index],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xffe8eadf)),
                      ),
                      child: const SizedBox(width: 28, height: 28),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CodeSnippetCard extends StatefulWidget {
  const _CodeSnippetCard({required this.title, required this.snippet});

  final String title;
  final String snippet;

  @override
  State<_CodeSnippetCard> createState() => _CodeSnippetCardState();
}

class _CodeSnippetCardState extends State<_CodeSnippetCard> {
  var _copied = false;

  @override
  void didUpdateWidget(covariant _CodeSnippetCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.snippet != widget.snippet) {
      _copied = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x5211120e),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x332b2d25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Color(0xffc0c6b2),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.snippet));
                    setState(() {
                      _copied = true;
                    });
                  },
                  icon: Icon(
                    _copied ? Icons.check_rounded : Icons.copy_rounded,
                    size: 16,
                  ),
                  label: Text(_copied ? 'Copied' : 'Copy'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                widget.snippet,
                style: const TextStyle(
                  color: Color(0xfff7f6ec),
                  fontSize: 11,
                  height: 1.35,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Color?> _pickColor(BuildContext context, Color initialColor) {
  var draftColor = initialColor;
  return showDialog<Color>(
    context: context,
    builder: (context) {
      final pickerWidth = math.min(
        320.0,
        MediaQuery.sizeOf(context).width - 72,
      );
      return AlertDialog(
        backgroundColor: const Color(0xff171813),
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Color',
          style: TextStyle(
            color: Color(0xfff7f6ec),
            fontWeight: FontWeight.w800,
          ),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: initialColor,
            onColorChanged: (color) {
              draftColor = color;
            },
            enableAlpha: true,
            displayThumbColor: true,
            hexInputBar: true,
            paletteType: PaletteType.hsvWithHue,
            labelTypes: const <ColorLabelType>[
              ColorLabelType.rgb,
              ColorLabelType.hsv,
            ],
            pickerAreaBorderRadius: BorderRadius.circular(8),
            pickerAreaHeightPercent: 0.78,
            colorPickerWidth: pickerWidth,
            portraitOnly: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(draftColor),
            child: const Text('Done'),
          ),
        ],
      );
    },
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Color(0xffd7ff42),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _Range {
  const _Range(this.min, this.max, this.divisions);

  final double min;
  final double max;
  final int divisions;
}

class GoldenTarget {
  const GoldenTarget({required this.entry, required this.preset});

  final ShaderCatalogEntry entry;
  final ShaderPreset preset;
}

class PaperShadersGoldenApp extends StatefulWidget {
  const PaperShadersGoldenApp({required this.target, super.key});

  final GoldenTarget target;

  @override
  State<PaperShadersGoldenApp> createState() => _PaperShadersGoldenAppState();
}

class _PaperShadersGoldenAppState extends State<PaperShadersGoldenApp> {
  final _captureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _capturePng();
    });
  }

  Future<void> _capturePng() async {
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await WidgetsBinding.instance.endOfFrame;

      final renderObject = _captureKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        throw StateError('Golden capture boundary is not ready');
      }

      final image = await renderObject.toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (bytes == null) {
        throw StateError('Golden renderer failed to encode PNG');
      }

      await writeGoldenPng(goldenOutputPath, bytes.buffer.asUint8List());
      exitGoldenRenderer(0);
    } catch (error, stackTrace) {
      printGoldenError(error, stackTrace);
      exitGoldenRenderer(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(
        key: _captureKey,
        child: ColoredBox(
          color: const Color(0xffffffff),
          child: SizedBox.expand(
            child: PaperShader(
              assetKey: widget.target.entry.assetKey,
              uniforms: widget.target.preset.uniforms,
              imageSamplers: widget.target.entry.imageSamplers,
              sizing: widget.target.preset.sizing,
              speed: 0,
              frame: 41500,
            ),
          ),
        ),
      ),
    );
  }
}

Map<String, GoldenTarget> _buildGoldenTargets() {
  return <String, GoldenTarget>{
    for (final entry in ShaderCatalog.all)
      for (final preset in entry.presets)
        '${entry.name}--${_slug(preset.name)}': GoldenTarget(
          entry: entry,
          preset: preset,
        ),
  };
}

String _slug(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

List<ShaderUniform> _cloneUniforms(List<ShaderUniform> uniforms) {
  return <ShaderUniform>[
    for (final uniform in uniforms)
      switch (uniform) {
        FloatUniform() => FloatUniform(uniform.value),
        Float4Uniform() => Float4Uniform(List<double>.of(uniform.values)),
        Float4ArrayUniform() => Float4ArrayUniform(<List<double>>[
          for (final item in uniform.values) List<double>.of(item),
        ], capacity: uniform.capacity),
        _ => uniform,
      },
  ];
}

ShaderSizing _copySizing(
  ShaderSizing sizing, {
  ShaderFit? fit,
  double? scale,
  double? rotation,
  double? originX,
  double? originY,
  double? offsetX,
  double? offsetY,
  double? worldWidth,
  double? worldHeight,
  double? imageAspectRatio,
}) {
  return ShaderSizing(
    fit: fit ?? sizing.fit,
    scale: scale ?? sizing.scale,
    rotation: rotation ?? sizing.rotation,
    originX: originX ?? sizing.originX,
    originY: originY ?? sizing.originY,
    offsetX: offsetX ?? sizing.offsetX,
    offsetY: offsetY ?? sizing.offsetY,
    worldWidth: worldWidth ?? sizing.worldWidth,
    worldHeight: worldHeight ?? sizing.worldHeight,
    imageAspectRatio: imageAspectRatio ?? sizing.imageAspectRatio,
  );
}

bool _isSwitchSpec(String name) {
  return name == 'u_isImage' ||
      name == 'u_originalColors' ||
      name == 'u_inverted';
}

_Range _rangeForFloat(
  String name,
  int index,
  double value,
  List<ShaderPreset> presets,
) {
  if (_isSwitchSpec(name)) {
    return const _Range(0, 1, 1);
  }
  if (name == 'u_colorsCount') {
    return const _Range(1, 10, 9);
  }
  if (name == 'u_stepsPerColor') {
    return _Range(
      stepsPerColorSliderRange.min,
      stepsPerColorSliderRange.max,
      stepsPerColorSliderRange.divisions,
    );
  }
  if (name.contains('angle') || name.contains('Angle')) {
    return const _Range(-360, 360, 144);
  }
  if (name.contains('gap') || name.contains('Gap')) {
    return const _Range(0, 96, 96);
  }

  final values = <double>[value];
  for (final preset in presets) {
    if (index < preset.uniforms.length &&
        preset.uniforms[index] is FloatUniform) {
      values.add((preset.uniforms[index] as FloatUniform).value);
    }
  }

  var minValue = values.reduce(math.min);
  var maxValue = values.reduce(math.max);
  if (minValue >= 0 && maxValue <= 1) {
    return const _Range(0, 1, 100);
  }
  if (minValue == maxValue) {
    final padding = math.max(1, minValue.abs() * 0.5);
    minValue -= padding;
    maxValue += padding;
    if (minValue >= 0) {
      minValue = 0;
    }
  } else {
    final padding = math.max((maxValue - minValue) * 0.25, 0.5);
    minValue -= padding;
    maxValue += padding;
    if (minValue > 0 && value >= 0) {
      minValue = 0;
    }
  }

  final span = maxValue - minValue;
  final divisions = span <= 12 ? 120 : 100;
  return _Range(minValue, maxValue, divisions);
}

String _formatNumber(double value) {
  if (value.abs() >= 100) {
    return value.toStringAsFixed(0);
  }
  if (value.abs() >= 10) {
    return value.toStringAsFixed(1);
  }
  return value.toStringAsFixed(2);
}

String _dartInitializationSnippet({
  required ShaderCatalogEntry entry,
  required List<ShowcaseUniformSpec> specs,
  required List<ShaderUniform> uniforms,
  required ShaderSizing sizing,
  required double speed,
  required double frame,
}) {
  final typedSnippet = _dartTypedInitializationSnippet(
    entry: entry,
    specs: specs,
    uniforms: uniforms,
    sizing: sizing,
    speed: speed,
    frame: frame,
  );
  if (typedSnippet != null) {
    return typedSnippet;
  }

  final shaderType = _dartShaderTypeName(entry.name);
  final uniformLines = Iterable<int>.generate(uniforms.length)
      .map((index) {
        final specComment = index < specs.length
            ? ' // ${specs[index].name}'
            : '';
        return '    ${_dartUniformLiteral(uniforms[index])},$specComment';
      })
      .join('\n');

  return '''
final customPreset = ShaderPreset(
  name: 'Custom ${entry.name}',
  sizing: ${_dartSizingLiteral(sizing)},
  uniforms: <ShaderUniform>[
$uniformLines
  ],
  speed: ${_formatCodeNumber(speed)},
  frame: ${_formatCodeNumber(frame)},
);

PaperShader(
  assetKey: $shaderType.assetKey,
  imageSamplers: $shaderType.catalogEntry.imageSamplers,
  uniforms: customPreset.uniforms,
  sizing: customPreset.sizing,
  speed: customPreset.speed,
  frame: customPreset.frame,
);
''';
}

String? _dartTypedInitializationSnippet({
  required ShaderCatalogEntry entry,
  required List<ShowcaseUniformSpec> specs,
  required List<ShaderUniform> uniforms,
  required ShaderSizing sizing,
  required double speed,
  required double frame,
}) {
  final baseType = _dartShaderBaseTypeName(entry.name);
  final viewType = '${baseType}View';
  final paramsType = '${baseType}Params';
  final arguments = <String>[];

  for (
    var index = 0;
    index < math.min(specs.length, uniforms.length);
    index += 1
  ) {
    final argument = _dartTypedArgument(specs[index].name, uniforms[index]);
    if (argument == null) {
      return null;
    }
    if (argument.isNotEmpty) {
      arguments.add(argument);
    }
  }

  arguments
    ..add('sizing: ${_dartSizingLiteral(sizing)}')
    ..add('speed: ${_formatCodeNumber(speed)}')
    ..add('frame: ${_formatCodeNumber(frame)}');

  final argumentLines = arguments
      .map((argument) => '    $argument')
      .join(',\n');
  return '''
$viewType(
  params: $paramsType(
$argumentLines
  ),
);
''';
}

String? _dartTypedArgument(String uniformName, ShaderUniform uniform) {
  final parameter = _dartParameterName(uniformName);
  if (parameter == 'colorsCount') {
    return '';
  }
  if (_dartEnumBackedParameters.contains(parameter)) {
    return null;
  }

  return switch (uniform) {
    FloatUniform(:final value) => '$parameter: ${_formatCodeNumber(value)}',
    Float4Uniform(:final values) =>
      "$parameter: '${_hexColorFromPremultiplied(values)}'",
    Float4ArrayUniform(:final values) when parameter == 'colors' =>
      "colors: <String>[${values.map((value) => "'${_hexColorFromPremultiplied(value)}'").join(', ')}]",
    Float4ArrayUniform() => null,
    _ => null,
  };
}

const _dartEnumBackedParameters = <String>{
  'aspectRatio',
  'ditherType',
  'distortionShape',
  'dotType',
  'grid',
  'shape',
  'strokeCap',
  'type',
};

String _dartParameterName(String uniformName) {
  final raw = uniformName.startsWith('u_')
      ? uniformName.substring(2)
      : uniformName;
  if (raw.isEmpty) {
    return raw;
  }
  return raw.substring(0, 1).toLowerCase() + raw.substring(1);
}

String _dartShaderTypeName(String name) {
  return '${_dartShaderBaseTypeName(name)}Shader';
}

String _dartShaderBaseTypeName(String name) {
  final parts = name.split('-');
  return parts.map((part) {
    if (part.isEmpty) {
      return '';
    }
    return part.substring(0, 1).toUpperCase() + part.substring(1);
  }).join();
}

String _dartSizingLiteral(ShaderSizing sizing) {
  return '''ShaderSizing(
    fit: ShaderFit.${sizing.fit.name},
    scale: ${_formatCodeNumber(sizing.scale)},
    rotation: ${_formatCodeNumber(sizing.rotation)},
    originX: ${_formatCodeNumber(sizing.originX)},
    originY: ${_formatCodeNumber(sizing.originY)},
    offsetX: ${_formatCodeNumber(sizing.offsetX)},
    offsetY: ${_formatCodeNumber(sizing.offsetY)},
    worldWidth: ${_formatCodeNumber(sizing.worldWidth)},
    worldHeight: ${_formatCodeNumber(sizing.worldHeight)},
    imageAspectRatio: ${_formatCodeNumber(sizing.imageAspectRatio)},
  )''';
}

String _dartUniformLiteral(ShaderUniform uniform) {
  return switch (uniform) {
    FloatUniform(:final value) => 'FloatUniform(${_formatCodeNumber(value)})',
    Float4Uniform(:final values) =>
      "Float4Uniform.color('${_hexColorFromPremultiplied(values)}')",
    Float4ArrayUniform(:final values, :final capacity) =>
      "Float4ArrayUniform.colors(<String>[\n${values.map((value) => "      '${_hexColorFromPremultiplied(value)}',").join('\n')}\n    ], capacity: $capacity)",
    _ => 'FloatUniform(0)',
  };
}

String _formatCodeNumber(double value) {
  if (value == 0) {
    return '0';
  }
  if (value == value.roundToDouble() && value.abs() < 1000000) {
    return value.toInt().toString();
  }
  return value.toStringAsPrecision(6);
}

String _hexColorFromPremultiplied(List<double> values) {
  final alpha = values.length > 3 ? values[3].clamp(0.0, 1.0) : 1.0;
  final red = alpha == 0 ? 0.0 : (values.isNotEmpty ? values[0] / alpha : 0.0);
  final green = alpha == 0
      ? 0.0
      : (values.length > 1 ? values[1] / alpha : 0.0);
  final blue = alpha == 0 ? 0.0 : (values.length > 2 ? values[2] / alpha : 0.0);
  final components = <int>[
    (red.clamp(0.0, 1.0) * 255).round(),
    (green.clamp(0.0, 1.0) * 255).round(),
    (blue.clamp(0.0, 1.0) * 255).round(),
  ];
  if (alpha >= 0.999) {
    return '#${components.map(_hexByte).join()}';
  }
  return '#${components.map(_hexByte).join()}${_hexByte((alpha * 255).round())}';
}

String _hexByte(int value) {
  return value.clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase();
}

Color _colorFromPremultiplied(List<double> values) {
  final alpha = _clamp01(values.length > 3 ? values[3] : 1);
  final red = alpha <= 0
      ? 0.0
      : _clamp01(values.isNotEmpty ? values[0] / alpha : 0);
  final green = alpha <= 0
      ? 0.0
      : _clamp01(values.length > 1 ? values[1] / alpha : 0);
  final blue = alpha <= 0
      ? 0.0
      : _clamp01(values.length > 2 ? values[2] / alpha : 0);
  return Color.from(alpha: alpha, red: red, green: green, blue: blue);
}

List<double> _premultiplied(Color color) {
  final alpha = color.a;
  return <double>[color.r * alpha, color.g * alpha, color.b * alpha, alpha];
}

double _clamp01(double value) {
  return value.clamp(0.0, 1.0);
}

String _hexColor(Color color) {
  return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
}
