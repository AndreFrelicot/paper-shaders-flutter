import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

String get goldenTarget =>
    Platform.environment['PAPER_SHADERS_GOLDEN_TARGET'] ?? '';

String get goldenOutputPath =>
    Platform.environment['PAPER_SHADERS_GOLDEN_OUTPUT'] ?? '';

bool get shouldListGoldenTargets =>
    Platform.environment['PAPER_SHADERS_GOLDEN_LIST'] == '1';

void printGoldenTargets(Iterable<String> targets) {
  stdout.writeln(targets.join('\n'));
}

Future<void> writeGoldenPng(String path, Uint8List bytes) async {
  if (path == '-') {
    stdout.writeln('PAPER_SHADERS_GOLDEN_PNG_BEGIN');
    stdout.writeln(base64Encode(bytes));
    stdout.writeln('PAPER_SHADERS_GOLDEN_PNG_END');
    return;
  }

  if (path.isEmpty) {
    throw StateError('Missing PAPER_SHADERS_GOLDEN_OUTPUT');
  }
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes);
}

void printGoldenError(Object error, StackTrace stackTrace) {
  stderr.writeln(error);
  stderr.writeln(stackTrace);
}

Never exitGoldenRenderer(int code) {
  exit(code);
}
