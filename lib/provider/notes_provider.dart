import 'package:flutter/material.dart';
import 'package:project_movil/helper/db_helper.dart';
import '../models/note.dart';
import 'package:intl/intl.dart';

class NotesProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<Note> _notes = [];
  String _searchQuery = '';

  List<Note> get notes => _notes;
  String get searchQuery => _searchQuery;

  Future<void> loadNotes(int userId) async {
    final notesData = await _db.getNotes(userId);
    _notes = notesData.map((note) => Note.fromMap(note)).toList();
    notifyListeners();
  }

  Future<bool> addNote(String title, String content, int userId) async {
    final now = DateTime.now();
    final dateCreated = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    final note = Note(
      title: title,
      content: content,
      dateCreated: dateCreated,
      userId: userId,
    );

    final id = await _db.insertNote(note.toMap());
    if (id > 0) {
      final newNote = Note(
        id: id,
        title: title,
        content: content,
        dateCreated: dateCreated,
        userId: userId,
      );
      _notes.insert(0, newNote);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateNote(Note note) async {
    final result = await _db.updateNote(note.toMap());
    if (result > 0) {
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = note;
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  Future<bool> deleteNote(int id) async {
    final result = await _db.deleteNote(id);
    if (result > 0) {
      _notes.removeWhere((note) => note.id == id);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> searchNotes(String query, int userId) async {
    _searchQuery = query;
    if (query.isEmpty) {
      await loadNotes(userId);
    } else {
      final notesData = await _db.searchNotes(query, userId);
      _notes = notesData.map((note) => Note.fromMap(note)).toList();
      notifyListeners();
    }
  }
}