import '../BaseModel.dart';

VoiceModel voiceModel = VoiceModel();

class Voice {
  int id;
  String title;
  String date;
  String length;


  String toString() {
    return "{ id=$id, title=$title, date=$date, length=$length }";
  }
}

class VoiceModel extends BaseModel<Voice>{

}
