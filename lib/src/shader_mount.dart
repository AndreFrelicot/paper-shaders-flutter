import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'shader_sampler.dart';
import 'shader_sizing.dart';
import 'shader_uniforms.dart';

/// Catalog metadata for the paper shader.
class PaperShader extends StatefulWidget {
  /// Creates paper shader.
  const PaperShader({
    required this.assetKey,
    required this.uniforms,
    this.imageSamplers = const <ShaderImageSampler>[],
    this.sizing = const ShaderSizing.pattern(),
    this.speed = 1,
    this.frame = 0,
    this.isAnimated = true,
    super.key,
  });

  /// Asset key.
  final String assetKey;

  /// Uniforms.
  final List<ShaderUniform> uniforms;

  /// Image samplers.
  final List<ShaderImageSampler> imageSamplers;

  /// Sizing.
  final ShaderSizing sizing;

  /// Speed.
  final double speed;

  /// Frame.
  final double frame;

  /// Whether the fragment output depends on the global time uniform.
  final bool isAnimated;

  @override
  State<PaperShader> createState() => _PaperShaderState();
}

class _PaperShaderState extends State<PaperShader>
    with SingleTickerProviderStateMixin {
  ui.FragmentProgram? _program;
  List<ui.Image>? _imageSamplers;
  late Ticker _ticker;
  Duration? _lastElapsed;
  late double _frame;
  var _programLoadId = 0;
  var _imageLoadId = 0;

  @override
  void initState() {
    super.initState();
    _frame = widget.frame;
    _ticker = createTicker(_tick);
    _loadProgram();
    if (widget.imageSamplers.isEmpty) {
      _imageSamplers = const <ui.Image>[];
    } else {
      _loadImageSamplers();
    }
    if (_animationActive) {
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(PaperShader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetKey != widget.assetKey) {
      _loadProgram();
    }
    if (_imageSamplerKeysChanged(
      oldWidget.imageSamplers,
      widget.imageSamplers,
    )) {
      _loadImageSamplers();
    }
    if (widget.isAnimated &&
        (oldWidget.frame != widget.frame || !oldWidget.isAnimated)) {
      _frame = widget.frame;
      _lastElapsed = null;
    }
    if (oldWidget.speed != widget.speed ||
        oldWidget.isAnimated != widget.isAnimated) {
      if (!_animationActive) {
        _ticker.stop();
      } else if (!_ticker.isActive) {
        _lastElapsed = null;
        _ticker.start();
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _disposeImages(_imageSamplers);
    super.dispose();
  }

  Future<void> _loadProgram() async {
    final loadId = ++_programLoadId;
    try {
      final program = await ui.FragmentProgram.fromAsset(widget.assetKey);
      if (!mounted || loadId != _programLoadId) {
        return;
      }
      setState(() {
        _program = program;
      });
    } catch (error, stackTrace) {
      if (!mounted || loadId != _programLoadId) {
        return;
      }
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'paper_shaders',
          context: ErrorDescription(
            'while loading fragment shader ${widget.assetKey}',
          ),
        ),
      );
      setState(() {
        _program = null;
      });
    }
  }

  Future<void> _loadImageSamplers() async {
    final loadId = ++_imageLoadId;
    final samplers = widget.imageSamplers;
    if (samplers.isEmpty) {
      _replaceImages(const <ui.Image>[]);
      return;
    }

    try {
      final images = <ui.Image>[];
      for (final sampler in samplers) {
        final bytes = await rootBundle.load(sampler.assetKey);
        final codec = await ui.instantiateImageCodec(
          bytes.buffer.asUint8List(),
        );
        final frame = await codec.getNextFrame();
        images.add(frame.image);
      }
      if (!mounted || loadId != _imageLoadId) {
        _disposeImages(images);
        return;
      }
      _replaceImages(images);
    } catch (error, stackTrace) {
      if (!mounted || loadId != _imageLoadId) {
        return;
      }
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'paper_shaders',
          context: ErrorDescription('while loading shader image sampler'),
        ),
      );
      _replaceImages(null);
    }
  }

  void _replaceImages(List<ui.Image>? images) {
    final oldImages = _imageSamplers;
    setState(() {
      _imageSamplers = images;
    });
    if (oldImages != images) {
      _disposeImages(oldImages);
    }
  }

  void _disposeImages(List<ui.Image>? images) {
    if (images == null) {
      return;
    }
    for (final image in images) {
      image.dispose();
    }
  }

  bool _imageSamplerKeysChanged(
    List<ShaderImageSampler> previous,
    List<ShaderImageSampler> next,
  ) {
    if (previous.length != next.length) {
      return true;
    }
    for (var i = 0; i < previous.length; i += 1) {
      if (previous[i].assetKey != next[i].assetKey) {
        return true;
      }
    }
    return false;
  }

  void _tick(Duration elapsed) {
    final last = _lastElapsed ?? elapsed;
    _lastElapsed = elapsed;
    if (!_animationActive) {
      return;
    }
    final deltaMs = (elapsed - last).inMicroseconds / 1000;
    setState(() {
      _frame += deltaMs * widget.speed;
    });
  }

  bool get _animationActive => widget.isAnimated && widget.speed != 0;

  @override
  /// Builds the shader widget.
  Widget build(BuildContext context) {
    final program = _program;
    final imageSamplers = _imageSamplers;
    if (program == null || imageSamplers == null) {
      return const SizedBox.expand();
    }
    return CustomPaint(
      painter: _PaperShaderPainter(
        program: program,
        uniforms: widget.uniforms,
        imageSamplers: imageSamplers,
        sizing: widget.sizing,
        frame: _frame,
      ),
      size: Size.infinite,
    );
  }
}

class _PaperShaderPainter extends CustomPainter {
  const _PaperShaderPainter({
    required this.program,
    required this.uniforms,
    required this.imageSamplers,
    required this.sizing,
    required this.frame,
  });

  final ui.FragmentProgram program;

  /// Uniforms.
  final List<ShaderUniform> uniforms;
  final List<ui.Image> imageSamplers;

  /// Sizing.
  final ShaderSizing sizing;

  /// Frame.
  final double frame;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final shader = program.fragmentShader();
    var index = 0;
    shader.setFloat(index++, size.width);
    shader.setFloat(index++, size.height);
    shader.setFloat(index++, 1);
    shader.setFloat(index++, frame * 0.001);
    shader.setFloat(index++, sizing.fit.uniformValue);
    shader.setFloat(index++, sizing.scale);
    shader.setFloat(index++, sizing.rotation);
    shader.setFloat(index++, sizing.originX);
    shader.setFloat(index++, sizing.originY);
    shader.setFloat(index++, sizing.offsetX);
    shader.setFloat(index++, sizing.offsetY);
    shader.setFloat(index++, sizing.worldWidth);
    shader.setFloat(index++, sizing.worldHeight);
    shader.setFloat(index++, sizing.imageAspectRatio);

    for (final uniform in uniforms) {
      index = uniform.write(shader, index);
    }
    for (
      var samplerIndex = 0;
      samplerIndex < imageSamplers.length;
      samplerIndex += 1
    ) {
      shader.setImageSampler(samplerIndex, imageSamplers[samplerIndex]);
    }

    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _PaperShaderPainter oldDelegate) {
    return oldDelegate.program != program ||
        oldDelegate.frame != frame ||
        oldDelegate.uniforms != uniforms ||
        oldDelegate.imageSamplers != imageSamplers ||
        oldDelegate.sizing != sizing;
  }
}
