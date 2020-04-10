import 'package:scoped_model/scoped_model.dart';

NotesModel notesModel = NotesModel();

class Note {
  String title;
  String content;
  String color;

  String toString() {
    return "{ title=$title, content=$content, color=$color }";
  }
}

class NotesModel extends Model {
  int stackIndex = 0;
  List<Note> noteList = [];
  Note noteBeingEdited;
  String color;

  void setStackIndex(int stackIndex) {
    this.stackIndex = stackIndex;
    notifyListeners();
  }

  void setColor(String color) {
    this.color = color;
    notifyListeners();
  }
}