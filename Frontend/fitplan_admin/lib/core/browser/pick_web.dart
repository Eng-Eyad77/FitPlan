import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Opens the browser's file picker. null when nothing was picked.
Future<({String name, Uint8List bytes})?> pickFile(String accept) {
  final done = Completer<({String name, Uint8List bytes})?>();
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = accept;
  input.onchange = (web.Event _) {
    final file = input.files?.item(0);
    if (file == null) {
      done.complete(null);
      return;
    }
    file.arrayBuffer().toDart.then((buffer) => done.complete((name: file.name, bytes: buffer.toDart.asUint8List())), onError: done.completeError);
  }.toJS;
  // closing the picker without a file
  input.oncancel = (web.Event _) {
    if (!done.isCompleted) done.complete(null);
  }.toJS;
  input.click();
  return done.future;
}
