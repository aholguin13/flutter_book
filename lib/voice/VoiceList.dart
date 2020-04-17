import 'dart:io';
import 'package:edu/voice/VoiceModel.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'VoiceDBWorker.dart';
import 'VoiceNote.dart';

class VoiceList extends StatelessWidget with VoiceNote{

  @override
  Widget build(BuildContext context) {
    return ScopedModel<VoiceModel>(
        model: voiceModel,
        child: ScopedModelDescendant<VoiceModel>(
          builder: (BuildContext context, Widget child, VoiceModel model) {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add, color: Colors.white),
                onPressed: () async {
                  File recordingFile = voiceNoteTempFile();
                  if(recordingFile.existsSync()){
                    recordingFile.deleteSync();
                  }
                  voiceModel.entityBeingEdited = Voice();
                  voiceModel.setStackIndex(1);
                },
              ),

              body: ListView.builder(
                  itemCount: voiceModel.entityList.length,
                  itemBuilder: (BuildContext context, int index){
                   Voice voice = voiceModel.entityList[index];
                   File recordingFile = File(voiceNoteFileName(voice.id));
                   bool recordingFileExists = recordingFile.existsSync();
                   return Container(
                       padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                       child: Slidable(
                           actionPane: SlidableDrawerActionPane(),
                           actionExtentRatio: .25,
                           secondaryActions: [
                             IconSlideAction(
                                 caption: "Delete",
                                 color: Colors.red,
                                 icon: Icons.delete,
                                 onTap: () => _deleteNote(context, model, voice)//_deleteNote(context, model, note)
                             )
                           ],
                           child: Card(
                               elevation: 8,
                               child: ListTile(
                                 title: Text(voice.title),
                                 //subtitle: Text(note.content),
                                 onTap: () {
                                   model.entityBeingEdited = voice;
                                //   model.setColor(model.entityBeingEdited.color);
                                   model.setStackIndex(1);
                                 },
                               )
                           )
                       )
                   );

                  }
              ),
            );
          },
        ),
    );
  }

  _deleteNote(BuildContext context, VoiceModel model, Voice note) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext alertContext) {
          return AlertDialog(
              title: Text("Delete Note"),
              content: Text(
                  "Are you sure you want to delete ${note.title}?"
              ),
              actions: [
                FlatButton(child: Text("Cancel"),
                    onPressed: () {
                      Navigator.of(alertContext).pop();
                    }
                ),
                FlatButton(child: Text("Delete"),
                    onPressed: () async {
                      //model.noteList.remove(note);
                      //model.setStackIndex(0);
                      await VoiceDBWorker.db.delete(note.id);
                      Navigator.of(alertContext).pop();
                      Scaffold.of(context).showSnackBar(
                          SnackBar(
                              backgroundColor: Colors.red,
                              duration: Duration(seconds : 2),
                              content: Text("Note deleted")
                          )
                      );
                      model.loadData(VoiceDBWorker.db);
                    }
                )
              ]
          );
        }
    );
  }

}

