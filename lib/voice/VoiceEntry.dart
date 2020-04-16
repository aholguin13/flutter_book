import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'Recording.dart';
import 'VoiceDBWorker.dart';
import 'VoiceModel.dart';
import '../utils.dart' as utils;

class VoiceEntry extends StatelessWidget with Recording {
  final TextEditingController _titleEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  VoiceEntry() {
    _titleEditingController.addListener(() {
      voiceModel.entityBeingEdited.title = _titleEditingController.text;
    });
  }


  @override
  Widget build(BuildContext context) {
    return ScopedModel<VoiceModel>(
      model: voiceModel,
      child: ScopedModelDescendant<VoiceModel>(
        builder: (BuildContext context, Widget child, VoiceModel model){
          if(model.entityBeingEdited != null) {
            _titleEditingController.text = model.entityBeingEdited.title;
          }

          File recordingFile = recordingTempFile();
          if(!recordingFile.existsSync()){
            if(model.entityBeingEdited != null && model.entityBeingEdited.id != null) {
              recordingFile = File(recordingFileName(model.entityBeingEdited.id));
            }
          }

          return Scaffold(
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: <Widget>[
                  FlatButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      File recordingFile = recordingTempFile();
                      if(recordingFile.existsSync()){
                        recordingFile.deleteSync();
                      }
                      FocusScope.of(context).requestFocus(FocusNode());
                      model.setStackIndex(0);
                    },
                  ),
                  Spacer(),
                  FlatButton(
                    child: Text('Save'),
                    onPressed: () {
                      _save(context, model);
                    },
                  )
                ],
              ),
            ),
            body: Form(
              key: _formKey,
                child: ListView(
                  children: [
                    ListTile(
                      leading: Icon(Icons.title),
                      title: TextFormField(
                        decoration: InputDecoration(hintText: 'Title'),
                        controller: _titleEditingController,
                        validator: (String value) {
                          if(value.length == 0){
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                    ),
                    ListTile(
                      trailing: Wrap(
                        spacing: 15,
                        children: <Widget>[
                          Icon(Icons.play_arrow),
                          Icon(Icons.pause),
                          Icon(Icons.stop)
                        ],
                      ),
                    )
                  ],
                ),
            ),
          );
        },
      ),
    );
  }


  void _save(BuildContext context, VoiceModel model) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    int id = 0;
    if (model.entityBeingEdited.id == null) {
      await VoiceDBWorker.db.create(voiceModel.entityBeingEdited);
    } else {
      await VoiceDBWorker.db.update(voiceModel.entityBeingEdited);
    }
    File avatarFile = recordingTempFile();
    if (avatarFile.existsSync()) {
      File f = avatarFile.renameSync(recordingFileName(id));

      // FIXME: force to reload the avartar in the ContactsList
    }
    voiceModel.loadData(VoiceDBWorker.db);
    model.setStackIndex(0);
    Scaffold.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2), content: Text('Recording saved'),
        )
    );
  }



}


