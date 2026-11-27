import 'dart:typed_data';

/// Outside a browser (the widget tests) there is no file to pick.
Future<({String name, Uint8List bytes})?> pickFile(String accept) async => null;
