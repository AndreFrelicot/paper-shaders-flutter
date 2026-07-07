import 'dart:typed_data';

String get goldenTarget => '';

String get goldenOutputPath => '';

bool get shouldListGoldenTargets => false;

void printGoldenTargets(Iterable<String> targets) {}

Future<void> writeGoldenPng(String path, Uint8List bytes) {
  throw UnsupportedError(
    'Golden renderer file output is only available on IO platforms.',
  );
}

void printGoldenError(Object error, StackTrace stackTrace) {}

Never exitGoldenRenderer(int code) {
  throw UnsupportedError(
    'Golden renderer exit is only available on IO platforms.',
  );
}
