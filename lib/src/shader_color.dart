/// Shader color.
class ShaderColor {
  /// Creates shader color.
  const ShaderColor(this.r, this.g, this.b, this.a);

  /// R.
  final double r;

  /// G.
  final double g;

  /// B.
  final double b;

  /// A.
  final double a;

  /// RGBA components premultiplied for Flutter fragment shader uniforms.
  List<double> get premultiplied => <double>[r * a, g * a, b * a, a];

  /// Parses CSS-style hex colors used by the upstream presets.
  static ShaderColor parse(String value) {
    final trimmed = value.trim();
    if (!trimmed.startsWith('#')) {
      return const ShaderColor(0, 0, 0, 1);
    }

    final hex = trimmed.substring(1);
    if (hex.length == 3) {
      final r = hex[0] + hex[0];
      final g = hex[1] + hex[1];
      final b = hex[2] + hex[2];
      return _fromHex('$r$g$b');
    }
    if (hex.length == 6 || hex.length == 8) {
      return _fromHex(hex);
    }
    return const ShaderColor(0, 0, 0, 1);
  }

  static ShaderColor _fromHex(String hex) {
    final value = int.tryParse(hex, radix: 16);
    if (value == null) {
      return const ShaderColor(0, 0, 0, 1);
    }
    if (hex.length == 8) {
      return ShaderColor(
        ((value >> 24) & 0xff) / 255,
        ((value >> 16) & 0xff) / 255,
        ((value >> 8) & 0xff) / 255,
        (value & 0xff) / 255,
      );
    }
    return ShaderColor(
      ((value >> 16) & 0xff) / 255,
      ((value >> 8) & 0xff) / 255,
      (value & 0xff) / 255,
      1,
    );
  }
}
