import 'dart:ui';

import 'shader_color.dart';

/// Value that can write itself into a Flutter [FragmentShader].
abstract interface class ShaderUniform {
  /// Writes this uniform into [shader] starting at [index].
  int write(FragmentShader shader, int index);
}

/// Float uniform.
class FloatUniform implements ShaderUniform {
  /// Creates float uniform.
  const FloatUniform(this.value);

  /// Value.
  final double value;

  /// Writes the scalar value into the shader.
  @override
  int write(FragmentShader shader, int index) {
    shader.setFloat(index, value);
    return index + 1;
  }
}

/// Float4 uniform.
class Float4Uniform implements ShaderUniform {
  /// Creates float4 uniform.
  const Float4Uniform(this.values);

  /// Values.
  final List<double> values;

  /// Creates float4 uniform.
  factory Float4Uniform.color(String color) {
    return Float4Uniform(ShaderColor.parse(color).premultiplied);
  }

  /// Writes the four-component value into the shader.
  @override
  int write(FragmentShader shader, int index) {
    return _writeFloat4(shader, index, values);
  }
}

/// Float4 array uniform.
class Float4ArrayUniform implements ShaderUniform {
  /// Creates float4 array uniform.
  const Float4ArrayUniform(this.values, {required this.capacity});

  /// Values.
  final List<List<double>> values;

  /// Capacity.
  final int capacity;

  /// Creates float4 array uniform.
  factory Float4ArrayUniform.colors(
    List<String> colors, {
    required int capacity,
  }) {
    return Float4ArrayUniform(
      colors.map((color) => ShaderColor.parse(color).premultiplied).toList(),
      capacity: capacity,
    );
  }

  /// Writes the fixed-capacity array into the shader.
  @override
  int write(FragmentShader shader, int index) {
    for (var item = 0; item < capacity; item += 1) {
      final color = item < values.length
          ? values[item]
          : const <double>[0, 0, 0, 0];
      index = _writeFloat4(shader, index, color);
    }
    return index;
  }
}

int _writeFloat4(FragmentShader shader, int index, List<double> values) {
  for (var component = 0; component < 4; component += 1) {
    shader.setFloat(index, component < values.length ? values[component] : 0);
    index += 1;
  }
  return index;
}
