// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:ffi';
import 'package:ffmpeg_dart/ffmpeg_dart.dart';
import 'package:universal_io/io.dart';

import 'package:ffi/ffi.dart';

// ignore: camel_case_types
typedef whisper_request_native = Pointer<Utf8> Function(Pointer<Utf8> body);

class Whisper {
  late String whisper_lib = "whisper_dart.so";
  Whisper({String? whisperLib}) {
    if (whisperLib != null) {
      whisper_lib = whisperLib;
    }
  }

  DynamicLibrary openLib({
    String? whisperLib,
  }) {
    whisperLib ??= whisper_lib;
    if (Platform.isIOS || Platform.isMacOS) {
      return DynamicLibrary.process();
    } else {
      return DynamicLibrary.open(whisperLib);
    }
  }

  WhisperResponse request({
    required WhisperRequest whisperRequest,
    String? whisperLib,
  }) {
    whisperLib ??= whisper_lib;
    try {
      var res = openLib(whisperLib: whisperLib).lookupFunction<whisper_request_native, whisper_request_native>("request").call(whisperRequest.toString().toNativeUtf8());
      Map result = json.decode(res.toDartString());
      return WhisperResponse(result);
    } catch (e) {
      print(e);
      return WhisperResponse({"@type": "error", "message": "${e.toString()}"});
    }
  }
}

class WhisperAudioconvert {
  WhisperAudioconvert();
  static File convert({
    required File audioInput,
    required File audioOutput,
    String? pathFFmpeg,
    FFmpegArgs? fFmpegArgs,
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    Duration? timeout,
  }) {
    timeout ??= Duration(seconds: 10);
    DateTime time_expire = DateTime.now().add(timeout);
    var res = FFmpeg(pathFFmpeg: pathFFmpeg).convertAudioToWavWhisper(pathAudioInput: audioInput.path, pathAudioOutput: audioOutput.path, pathFFmpeg: pathFFmpeg, fFmpegArgs: fFmpegArgs, workingDirectory: workingDirectory, environment: environment, runInShell: runInShell);
    while (true) {
      if (DateTime.now().isAfter(time_expire)) {
        throw "time out";
      }
      if (res) {
        if (audioOutput.existsSync()) {
          return audioOutput;
        }
      } else {
        if (!audioInput.existsSync()) {
          throw "audio input not found";
        }
      }
    }
  }
}

/// Don't forget to run malloc.free with result!
Pointer<Pointer<Utf8>> strListToPointer(List<String> strings) {
  List<Pointer<Utf8>> utf8PointerList = strings.map((str) => str.toNativeUtf8()).toList();

  final Pointer<Pointer<Utf8>> pointerPointer = malloc.allocate(utf8PointerList.length);

  strings.asMap().forEach((index, utf) {
    pointerPointer[index] = utf8PointerList[index];
  });

  return pointerPointer;
}

class WhisperArgs {
  late List<String> args;
  WhisperArgs(this.args);
  Pointer<Pointer<Utf8>> toNativeList() {
    List<Pointer<Utf8>> utf8PointerList = args.map((str) => str.toNativeUtf8()).toList();

    final Pointer<Pointer<Utf8>> pointerPointer = malloc.allocate(utf8PointerList.length);

    args.asMap().forEach((index, utf) {
      pointerPointer[index] = utf8PointerList[index];
    });
    return pointerPointer;
  }
}

class WhisperRequest {
  late Map rawData;
  WhisperRequest(this.rawData);

  factory WhisperRequest.fromWavFile({
    required File audio,
    required File model,
    bool is_translate = false,
    int threads = 4,
    bool is_verbose = false,
    String language = "id",
    bool is_special_tokens = false,
    bool is_no_timestamps = false,
  }) {
    return WhisperRequest({
      "@type": "getTextFromWavFile",
      "is_translate": is_translate,
      "threads": threads,
      "is_verbose": is_verbose,
      "language": language,
      "is_special_tokens": is_special_tokens,
      "is_no_timestamps": is_no_timestamps,
      "audio": audio.path,
      "model": model.path,
    });
  }

  Map toMap() {
    return (rawData);
  }

  Map toJson() {
    return (rawData);
  }

  @override
  String toString() {
    return json.encode(rawData);
  }
}

class WhisperResponse {
  late Map rawData;
  WhisperResponse(this.rawData);

  String? get special_type {
    try {
      if (rawData["@type"] is String == false) {
        return null;
      }
      return rawData["@type"] as String;
    } catch (e) {
      return null;
    }
  }

  String? get text {
    try {
      if (rawData["text"] is String == false) {
        return null;
      }
      return rawData["text"] as String;
    } catch (e) {
      return null;
    }
  }

  Map toMap() {
    return (rawData);
  }

  Map toJson() {
    return (rawData);
  }

  @override
  String toString() {
    return json.encode(rawData);
  }
}

extension ConvertAudioToWavWhisper on FFmpeg {
  bool convertAudioToWavWhisper({
    required String pathAudioInput,
    required String pathAudioOutput,
    String? pathFFmpeg,
    FFmpegArgs? fFmpegArgs,
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
  }) {
    File input_audio_file = File(pathAudioInput);
    if (!input_audio_file.existsSync()) {
      return false;
    }
    File output_audio_file = File(pathAudioOutput);
    if (output_audio_file.existsSync()) {
      output_audio_file.deleteSync(recursive: true);
    }
    FFmpegRawResponse res = invokeSync(
      pathFFmpeg: pathFFmpeg,
      fFmpegArgs: FFmpegArgs(
        [
          "-i",
          pathAudioInput,
          "-ar",
          "16000",
          "-ac",
          "1",
          "-c:a",
          "pcm_s16le",
          pathAudioOutput,
        ],
      ),
    );
    if (res.special_type == "ok") {
      return true;
    } else {
      print(res.toJson());
    }
    return false;
  }
}
