import 'dart:io';
import 'package:edu/voice/VoiceModel.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'VoiceDBWorker.dart';
import 'VoiceNote.dart';
import 'package:audioplayer/audioplayer.dart';

enum state {stopped, playing, paused}

class VoiceList extends StatefulWidget {
  @override
  _VoiceListState createState() => _VoiceListState();
}

class _VoiceListState extends State<VoiceList> with VoiceNote{

  AudioPlayer _audioPlayer = AudioPlayer();
  state playerState = state.stopped;
  Duration duration;
  Duration position;

  get isPlaying => playerState == state.playing;
  get isPause => playerState == state.paused;


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

            body: GridView.builder(
                itemCount: voiceModel.entityList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  crossAxisCount:2,
                ),
                itemBuilder: (BuildContext context, int index){
                  Voice voice = voiceModel.entityList[index];
                  return Container(
                      padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                      margin: EdgeInsets.all(1),
                      child: Slidable(
                          actionPane: SlidableScrollActionPane(),
                          actionExtentRatio: .25,
                          secondaryActions: [
                            IconSlideAction(
                                caption: "Delete",
                                color: Colors.red,
                                icon: Icons.delete,
                                onTap: () => _deleteRecording(context, model, voice)//_deleteNote(context, model, note)
                            )
                          ],
                          child: Card(
                              elevation: 8,
                              child: ListTile(
                                title:
                                Column(
                                  children: <Widget>[
                                    Text('${voice.title != null ? voice.title:'null'}'),
                                    //Text(voice.path),
                                    Flexible(
                                      fit: FlexFit.tight,
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        children: <Widget>[
                                          IconButton(
                                            icon: Icon(Icons.play_arrow),
                                            onPressed: isPlaying ? null : () => _play(voice),
                                            iconSize: 30,
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.pause),
                                            onPressed: isPlaying ? () => _pause() : null,
                                            iconSize: 30,
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.stop),
                                            onPressed: isPlaying || isPause ? () => _stop() : null,
                                            iconSize: 30,
                                          ),
                                          Text('Time Created: ${voice.date}',
                                          textAlign: TextAlign.center,),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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

  _deleteRecording(BuildContext context, VoiceModel model, Voice voice) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext alertContext) {
          return AlertDialog(
              title: Text("Delete Recording"),
              content: Text(
                  "Are you sure you want to delete ${voice.title}?"
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
                      print(voice.path);
                      //Directory(voice.path).deleteSync(recursive: true);
                      await VoiceDBWorker.db.delete(voice.id);
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

  _play(Voice voice) async{
    await _audioPlayer.play(voice.path);
    setState(() {
      playerState = state.playing;
      position = Duration();
    });
  }

  _pause() async{
    await _audioPlayer.pause();
    setState(() {
      playerState = state.paused;
    });
  }

  _stop() async{
    await _audioPlayer.stop();
    setState(() {
      playerState = state.stopped;
      position = Duration();
    });
  }

}

