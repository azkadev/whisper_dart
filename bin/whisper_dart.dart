import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:whisper_dart/whisper_dart.dart';

void main(List<String> arguments) {
  Whisper whisper = Whisper(whisperLib: "/home/hexaminate/Documents/HEXAMINATE/app/ai/whisper_dart/whisper.cpp/azka.so");
  print(json.encode(whisper.test));
}
