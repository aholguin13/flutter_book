import 'dart:io';
import 'package:path/path.dart';

mixin VoiceNote {
  static Directory tempDir;// = new Directory('/data/user/0/cs4381.cs.utep.edu/app_flutter');

  File voiceNoteTempFile() {
    return File(voiceNoteTempFileName());
  }

  String voiceNoteTempFileName() {
    return join(tempDir.path, "recording");
  }

  String voiceNoteFileName(int id){
    return join(tempDir.path, id.toString());
  }
}