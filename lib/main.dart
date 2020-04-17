import 'package:edu/voice/Voice.dart';
import 'package:edu/voice/VoiceNote.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'appointments/Appointments.dart';
import 'contacts/Avatar.dart';
import 'contacts/Contacts.dart';
import 'notes/Notes.dart';
import 'tasks/Tasks.dart';

void main() {
  startMeUp() async {
    WidgetsFlutterBinding.ensureInitialized();
    Avatar.docsDir = await getApplicationDocumentsDirectory();
    VoiceNote.tempDir = await getApplicationDocumentsDirectory();
    runApp(FlutterBook());
  }
  startMeUp();
}

class FlutterBook extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Book',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: DefaultTabController(
            length: 5,
            child: Scaffold(
                appBar: AppBar(
                    title: Text('FlutterBook Alexis Holguin'),
                    bottom: TabBar(
                        tabs: [
                          Tab(icon: Icon(Icons.date_range), text: 'Appointments'),
                          Tab(icon: Icon(Icons.contacts), text: 'Contacts'),
                          Tab(icon: Icon(Icons.note), text: 'Notes'),
                          Tab(icon: Icon(Icons.assignment_turned_in), text: 'Tasks'),
                          Tab(icon: Icon(Icons.keyboard_voice), text: 'Voice',)
                        ]
                    )
                ),
                body: TabBarView(
                    children: [
                      Appointments(),
                      Contacts(),
                      Notes(),
                      Tasks(),
                      Voice()
                    ]
                )
            )
        )
    );
  }
}