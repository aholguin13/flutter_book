import 'dart:io';
import 'package:edu/voice/VoiceModel.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'VoiceDBWorker.dart';
import 'Recording.dart';

class VoiceList extends StatelessWidget with Recording{

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
                  File recordingFile = recordingTempFile();
                  if(recordingFile.existsSync()){
                    recordingFile.deleteSync();
                  }
                  voiceModel.entityBeingEdited = Voice();
                  voiceModel.setStackIndex(1);
                },
              ),

              body: ListView.builder(
                  itemBuilder: (BuildContext context, int index){
                   Voice voice = voiceModel.entityList[index];
                   File recordingFile = File(recordingFileName(voice.id));
                   bool recordingFileExists = recordingFile.existsSync();
                   return Column();

                  }
              ),
            );
          },
        ),
    );
  }
}

