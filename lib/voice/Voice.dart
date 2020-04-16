import 'package:edu/voice/VoiceEntry.dart';
import 'package:edu/voice/VoiceList.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import 'VoiceDBWorker.dart';
import 'VoiceModel.dart';

class Voice extends StatelessWidget {

  Voice() {
    voiceModel.loadData(VoiceDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<VoiceModel>(
      model: voiceModel,
      child: ScopedModelDescendant<VoiceModel>(
        builder: (BuildContext context, Widget child, VoiceModel model){
          return IndexedStack(
            index: model.stackIndex,
            children: <Widget>[VoiceList(), VoiceEntry()],
          );
        },
      )
    );
  }
}
