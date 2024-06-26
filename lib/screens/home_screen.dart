import 'package:flutter/material.dart';
import 'package:notes_app/services/supabase_service.dart';
import 'package:notes_app/screens/add_edit_note_screen.dart';
import 'package:notes_app/widgets/note_card.dart';
import 'package:notes_app/models/note.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await _supabaseService.getNotes();
    setState(() {
      _notes = notes;
      _filteredNotes = notes;
    });
  }

  void _filterNotes(String query) {
    setState(() {
      _filteredNotes = _notes
          .where((note) =>
              note.title.toLowerCase().contains(query.toLowerCase()) ||
              note.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes App'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              onChanged: _filterNotes,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _filteredNotes.length,
        itemBuilder: (context, index) => NoteCard(
          note: _filteredNotes[index],
          onDelete: () => _deleteNote(index),
          onEdit: () => _editNote(index),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditNoteScreen()),
    );
    if (result != null) {
      await _supabaseService.addNote(
        result['title'],
        result['description'],
      );
      _loadNotes();
    }
  }

  void _editNote(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditNoteScreen(
          initialTitle: _filteredNotes[index].title,
          initialDescription: _filteredNotes[index].description,
        ),
      ),
    );
    if (result != null) {
      await _supabaseService.updateNote(
        _filteredNotes[index].id,
        result['title'],
        result['description'],
      );
      _loadNotes();
    }
  }

  void _deleteNote(int index) async {
    await _supabaseService.deleteNote(_filteredNotes[index].id);
    _loadNotes();
  }
}
