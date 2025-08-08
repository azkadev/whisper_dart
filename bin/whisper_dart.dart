import 'package:hyperio/hyperio.dart';
import "package:whisper_gpl/whisper_gpl.dart";

void main(List<String> arguments) async {
  final HyperioAzkadev hyperioAzkadev = HyperioAzkadev();
  hyperioAzkadev.ensureInitialized();
  final WhisperGpl whisperGpl = WhisperGpl();
  whisperGpl.ensureInitialized(

  );
  await whisperGpl.initialized();
  hyperioAzkadev.all("/", (req, res) {
    return res.send("ok");
  });
  hyperioAzkadev.post("/api", (req, res) {
    return res.send("ok");
  });

  await hyperioAzkadev.listen();
}
