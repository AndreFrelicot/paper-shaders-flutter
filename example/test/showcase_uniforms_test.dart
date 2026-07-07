import 'package:flutter_test/flutter_test.dart';
import 'package:paper_shaders/paper_shaders.dart';
import 'package:paper_shaders_example/showcase_uniforms.dart';

void main() {
  test('showcase exposes one control spec for each editable uniform', () {
    for (final entry in ShaderCatalog.all) {
      final specs = showcaseUniforms[entry.name];
      expect(specs, isNotNull, reason: entry.name);

      for (final preset in entry.presets) {
        expect(
          specs!.length,
          preset.uniforms.length,
          reason: '${entry.name} / ${preset.name}',
        );
      }
    }
  });
}
