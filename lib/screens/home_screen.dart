import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/note.dart';
import '../services/supabase_service.dart';
import '../widgets/note_card.dart';
import 'add_edit_note_screen.dart';
import 'category_management_screen.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  List<Category> _categories = [];
  String _searchQuery = '';
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _loadCategories();
      await _loadNotes();
    } catch (e) {
      _showErrorSnackBar('Error loading data: $e');
    }
  }

  Future<void> _loadCategories() async {
    final categories = await _supabaseService.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _loadNotes() async {
    final notes = _selectedCategoryId == null
        ? await _supabaseService.getNotes()
        : await _supabaseService.getNotesByCategory(_selectedCategoryId!);
    setState(() {
      _notes = notes;
      _filteredNotes = notes;
    });
  }

  Future<void> _searchNotes(String query) async {
    setState(() {
      _searchQuery = query;
    });

    if (query.isEmpty) {
      setState(() {
        _filteredNotes = _notes;
      });
    } else {
      try {
        final searchResults = await _supabaseService.searchNotes(query);
        setState(() {
          _filteredNotes = searchResults;
        });
      } catch (e) {
        _showErrorSnackBar('Error searching notes: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes App', style: AppTheme.appBarTextStyle),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CategoryManagementScreen(onCategoriesChanged: () {
                          _loadData();
                        })),
              );
              _loadCategories();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search notes...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    onChanged: (value) {
                      _searchNotes(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<int?>(
                  value: _selectedCategoryId,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All'),
                    ),
                    ..._categories.map((category) {
                      return DropdownMenuItem<int?>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                    _loadNotes();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredNotes.length,
              itemBuilder: (context, index) => NoteCard(
                note: _filteredNotes[index],
                onDelete: () => _deleteNote(index),
                onEdit: () => _editNote(index),
                searchQuery: _searchQuery,
                categoryName:
                    _getCategoryName(_filteredNotes[index].categoryId),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getCategoryName(int? categoryId) {
    if (categoryId == null) {
      return 'Uncategorized';
    }
    final category = _categories.firstWhere((c) => c.id == categoryId,
        orElse: () => Category(id: -1, name: 'Unknown'));
    return category.name;
  }

  void _addNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditNoteScreen(categories: _categories),
      ),
    );
    if (result != null) {
      try {
        await _supabaseService.addNote(
          result['title'],
          result['description'],
          result['categoryId'],
        );
        await _loadNotes();
      } catch (e) {
        _showErrorSnackBar('Error adding note: $e');
      }
    }
  }

  void _editNote(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditNoteScreen(
          initialTitle: _filteredNotes[index].title,
          initialDescription: _filteredNotes[index].description,
          initialCategoryId: _filteredNotes[index].categoryId,
          categories: _categories,
        ),
      ),
    );
    if (result != null) {
      try {
        await _supabaseService.updateNote(
          _filteredNotes[index].id,
          result['title'],
          result['description'],
          result['categoryId'],
        );
        await _loadNotes();
      } catch (e) {
        _showErrorSnackBar('Error updating note: $e');
      }
    }
  }

  void _deleteNote(int index) async {
    try {
      await _supabaseService.deleteNote(_filteredNotes[index].id);
      _loadNotes();
    } catch (e) {
      _showErrorSnackBar('Error deleting note: $e');
    }
  }
}
