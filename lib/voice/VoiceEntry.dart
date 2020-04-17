import 'dart:io';
import 'dart:typed_data';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'VoiceNote.dart';
import 'VoiceDBWorker.dart';
import 'VoiceModel.dart';
import '../utils.dart' as utils;

class VoiceEntry extends StatefulWidget with VoiceNote{

  @override
  _VoiceEntryState createState() => _VoiceEntryState();
}

class _VoiceEntryState extends State<VoiceEntry> with VoiceNote{

  final TextEditingController _titleEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Recording _recording = new Recording();
  bool _isRecording = false;

  _VoiceEntryState() {
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

          File recordingFile = voiceNoteTempFile();
          print(recordingFile.path);
          if(!recordingFile.existsSync()){
            if(model.entityBeingEdited != null && model.entityBeingEdited.id != null) {
              print('inside entity being edited');
              recordingFile = File(voiceNoteFileName(model.entityBeingEdited.id));
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
                      File recordingFile = voiceNoteTempFile();
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
                        IconButton(
                          icon: Icon(Icons.mic),
                          onPressed: _isRecording ? null : _startRecording,
                        ),
                        IconButton(
                          icon: Icon(Icons.stop),
                          onPressed: _isRecording ? _stop : null,
                        ),
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
    File voiceNoteFile = voiceNoteTempFile();
    if (voiceNoteFile.existsSync()) {
      File f = voiceNoteFile.renameSync(voiceNoteFileName(id));

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

  _startRecording() async{

    try{
      if(await AudioRecorder.hasPermissions) {
        print("Start recording: ${voiceNoteTempFileName()}");
        String path = voiceNoteTempFileName()+ DateTime.now().millisecondsSinceEpoch.toString();
        await AudioRecorder.start(
            path: path, audioOutputFormat: AudioOutputFormat.AAC
        );

        bool isRecording = await AudioRecorder.isRecording;
        setState(() {
          _recording = new Recording(duration: new Duration(), path: "");
          _isRecording = isRecording;
        });

      } else {
        Scaffold.of(context).showSnackBar(
          new SnackBar(content: new Text('You must accept permissions'))
        );
      }
    } catch (e) {
      print(e);
    }
  }

  _stop() async {
    var recording = await AudioRecorder.stop();
    print("Stop recording: ${recording.path}");
    bool isRecording = await AudioRecorder.isRecording;
    File file = File(recording.path);
    print('${await file.length()}');


    setState(() {
      _recording = recording;
      _isRecording = isRecording;
    });
  }

}