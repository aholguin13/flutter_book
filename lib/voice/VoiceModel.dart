import '../BaseModel.dart';

VoiceModel voiceModel = VoiceModel();

class Voice {
  int id;
  String title;
  String date;
  String length;
  String path;


  String toString() {
    return "{ id=$id, title=$title, date=$date, length=$length, path=$path }";
  }
}

class VoiceModel extends BaseModel<Voice>{

}
