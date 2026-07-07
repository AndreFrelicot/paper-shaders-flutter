import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paper_shaders/paper_shaders.dart';

void main() {
  testWidgets('catalog shaders compile and declare loadable samplers', (
    tester,
  ) async {
    for (final entry in ShaderCatalog.all) {
      await ui.FragmentProgram.fromAsset(_localAssetKey(entry.assetKey));

      for (final sampler in entry.imageSamplers) {
        final bytes = await rootBundle.load(_localAssetKey(sampler.assetKey));
        expect(bytes.lengthInBytes, greaterThan(0));
      }
    }
  });
}

String _localAssetKey(String assetKey) {
  return assetKey.replaceFirst('packages/paper_shaders/', '');
}
