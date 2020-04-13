import 'package:edu/notes/NotesModel.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'NotesDBWorker.dart';

//import 'NotesModel.dart';

class NotesEntry extends StatelessWidget {

  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  NotesEntry() {
    _titleEditingController.addListener(() { 
       notesModel.noteBeingEdited.title = _titleEditingController.text;
    });
    _contentEditingController.addListener(() { 
       notesModel.noteBeingEdited.content  = _contentEditingController.text;
    });
  }

  Future<void> _save(BuildContext context, NotesModel model) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    if (model.noteBeingEdited.id == null) {
      await NotesDBWorker.db.create(notesModel.noteBeingEdited);
    } else {
      await NotesDBWorker.db.update(notesModel.noteBeingEdited);
    }
    notesModel.loadData(NotesDBWorker.db);

    model.setStackIndex(0);
    Scaffold.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2), content: Text('Note saved'),
        )
    );
  }

  ListTile _buildTitleListTile() {
    return ListTile(
        leading: Icon(Icons.title),
        title: TextFormField(
          decoration: InputDecoration(hintText: 'Title'),
          controller: _titleEditingController,
          validator: (String value) {
            if (value.length == 0) {
              return 'Please enter a title';
            }
            return null;
            },
        )
    );
  }

  ListTile _buildContentListTile() {
    return ListTile(
        leading: Icon(Icons.content_paste),
        title: TextFormField(
            keyboardType: TextInputType.multiline,
            maxLines: 8,
            decoration: InputDecoration(hintText: 'Content'),
            controller: _contentEditingController,
            validator: (String value) {
              if (value.length == 0) {
                return 'Please enter content';
              }
              return null;
            }
        )
    );
  }

  ListTile _buildColorListTile(BuildContext context) {
    const colors = const ['red', 'green', 'blue', 'yellow', 'grey', 'purple'];
    return ListTile(
        leading: Icon(Icons.color_lens),
        title: Row(
            children: colors.expand((c) => 
            [_buildColorBox(context, c), Spacer()]).toList()..removeLast()
        )
    );
  }

  Color _toColor(String color){
    Color colorValue = Colors.white;
    switch (color) {
      case "red" : colorValue = Colors.red; break;
      case "green" : colorValue = Colors.green; break;
      case "blue" : colorValue = Colors.blue; break;
      case "yellow" : colorValue = Colors.yellow; break;
      case "grey" : colorValue = Colors.grey; break;
      case "purple" : colorValue = Colors.purple; break;
    }
    return colorValue;
  }

  GestureDetector _buildColorBox(BuildContext context, String color) {
    Color colorValue = _toColor(color);

    return GestureDetector(
        child: Container(
            decoration: ShapeDecoration(
                shape: Border.all(width: 16, color: colorValue) +
                    Border.all(width: 4,  color: notesModel.color == color ? colorValue : Theme.of(context).canvasColor)
               )
        ),
        onTap: () {
          notesModel.noteBeingEdited.color = color;
          notesModel.setColor(color);
        }
    );
  }

   Row _buildControlButtons(BuildContext context, NotesModel model) {
    return Row(children: [
      FlatButton(
        child: Text('Cancel'),
        onPressed: () {
          FocusScope.of(context).requestFocus(FocusNode());
          model.setStackIndex(0);
        },
      ),
      Spacer(),
      FlatButton(
        child: Text('Save'),
        onPressed: () {
          _save(context, notesModel);
        },
      )
    ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<NotesModel>(
          builder: (BuildContext context, Widget child, NotesModel model) {
            _titleEditingController.text = model.noteBeingEdited?.title;
            _contentEditingController.text = model.noteBeingEdited?.content;
            return Scaffold(
              bottomNavigationBar: Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: _buildControlButtons(context, model)
              ),
              body: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildTitleListTile(),
                    _buildContentListTile(),
                    _buildColorListTile(context)
                  ]
                )
              )
            );
          }
      );
  }
}





