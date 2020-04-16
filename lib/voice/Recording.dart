import 'dart:io';
import 'package:path/path.dart';

mixin Recording {
  static Directory docsDir;

  File recordingTempFile() {
    return File(recordingTempFileName());
  }

  String recordingTempFileName() {
    return join(docsDir.path, "recording");
  }

  String recordingFileName(int id){
    return join(docsDir.path, id.toString());
  }
}