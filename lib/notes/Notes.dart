import 'package:edu/notes/NotesDBWorker.dart';
import 'package:edu/notes/NotesEntry.dart';
import 'package:edu/notes/NotesList.dart';
import 'package:edu/notes/NotesModel.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class Notes extends StatelessWidget {

  Notes() {
    notesModel.loadData(NotesDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<NotesModel>(
        model: notesModel,
        child: ScopedModelDescendant<NotesModel>(
            builder: (BuildContext context, Widget child, NotesModel model) {
              return IndexedStack(
                index: model.stackIndex,
                children: <Widget>[NotesList(), NotesEntry()],
              );
            }
        )
    );
  }
}
