import 'package:edu/notes/NotesModel.dart';

abstract class NotesDBWorker {

  static final NotesDBWorker db = _MemoryNotesDBWorker._();

  /// Create and add the given note in this database.
  Future<int> create(Note note);

  /// Update the given note of this database.
  Future<void> update(Note note);

  /// Delete the specified note.
  Future<void> delete(int id);

  /// Return the specified note, or null.
  Future<Note> get(int id);

  /// Return all the notes of this database.
  Future<List<Note>> getAll();
}

class _MemoryNotesDBWorker implements NotesDBWorker {

  var _notes = [];
  var _nextId = 1;

  _MemoryNotesDBWorker._();

  @override
  Future<int> create(Note note) async {
    note = _clone(note)..id = _nextId++;
    _notes.add(note);
    return note.id;
  }

  @override
  Future<void> update(Note note) async {
    var old = await get(note.id);
    if (old != null) {
      old..title = note.title
        ..content = note.content
        ..color = note.color;
    }
  }

  @override
  Future<void> delete(int id) async {
    _notes.removeWhere((n) => n.id == id);
  }

  @override
  Future<Note> get(int id) async {
    return _clone(_notes.firstWhere(
            (n) => n.id == id, orElse: () => null));
  }

  @override
  Future<List<Note>> getAll() async {
    return List.unmodifiable(_notes);
  }

  static Note _clone(Note note) {
    if (note != null) {
      return Note()
        ..id = note.id
        ..title = note.title
        ..content = note.content
        ..color = note.color;
    }
    return null;
  }
}


