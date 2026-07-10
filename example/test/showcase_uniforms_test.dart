import 'package:flutter_test/flutter_test.dart';
import 'package:paper_shaders/paper_shaders.dart';
import 'package:paper_shaders_example/showcase_uniforms.dart';

void main() {
  test('steps per color slider is bounded to the canonical range', () {
    expect(stepsPerColorSliderRange.min, 1);
    expect(stepsPerColorSliderRange.max, 100);
    expect(stepsPerColorSliderRange.divisions, 99);
  });

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
