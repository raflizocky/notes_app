import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';
import '../models/note.dart';
import '../config/app_config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;

  Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
      _client = Supabase.instance.client;
    } catch (e) {
      throw Exception('Failed to initialize Supabase: $e');
    }
  }

  Future<List<T>> _getAll<T>(
      String table, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final response = await _client.from(table).select();
      return (response as List).map((json) => fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error getting $table: $e');
    }
  }

  Future<List<Category>> getCategories() =>
      _getAll('categories', Category.fromJson);

  Future<List<Note>> getNotes() async {
    try {
      final response = await _client
          .from('notes')
          .select('*, categories(name)')
          .order('created_at');
      return (response as List).map((json) => Note.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error getting notes: $e');
    }
  }

  Future<List<Note>> getNotesByCategory(int categoryId) async {
    try {
      final response = await _client
          .from('notes')
          .select('*, categories(name)')
          .eq('category_id', categoryId)
          .order('created_at');
      return (response as List).map((json) => Note.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error getting notes by category: $e');
    }
  }

  Future<void> addNote(
      String title, String description, int? categoryId) async {
    try {
      await _client.from('notes').insert({
        'title': title,
        'description': description,
        'category_id': categoryId,
      });
    } catch (e) {
      throw Exception('Error adding note: $e');
    }
  }

  Future<void> updateNote(
      int id, String title, String description, int? categoryId) async {
    try {
      await _client.from('notes').update({
        'title': title,
        'description': description,
        'category_id': categoryId,
      }).match({'id': id});
    } catch (e) {
      throw Exception('Error updating note: $e');
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      await _client.from('notes').delete().match({'id': id});
    } catch (e) {
      throw Exception('Error deleting note: $e');
    }
  }

  Future<void> deleteNotesByCategory(int categoryId) async {
    try {
      await _client.from('notes').delete().eq('category_id', categoryId);
    } catch (e) {
      throw Exception('Error deleting notes by category: $e');
    }
  }

  Future<int> addCategory(String name) async {
    try {
      final response = await _client
          .from('categories')
          .insert({'name': name})
          .select()
          .single();
      return response['id'];
    } catch (e) {
      throw Exception('Error adding category: $e');
    }
  }

  Future<void> updateCategory(int id, String name) async {
    try {
      await _client.from('categories').update({'name': name}).match({'id': id});
    } catch (e) {
      throw Exception('Error updating category: $e');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await removeNotesCategory(id);
      await _client.from('categories').delete().match({'id': id});
    } catch (e) {
      throw Exception('Error deleting category: $e');
    }
  }

  Future<void> removeNotesCategory(int categoryId) async {
    try {
      await _client
          .from('notes')
          .update({'category_id': null}).eq('category_id', categoryId);
    } catch (e) {
      throw Exception('Error updating notes category: $e');
    }
  }

  Future<List<Note>> searchNotes(String query) async {
    try {
      final response = await _client
          .from('notes')
          .select('*, categories(name)')
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('created_at');

      return (response as List).map((json) {
        return Note.fromJson({
          ...json,
          'category_name':
              json['categories'] != null ? json['categories']['name'] : null,
        });
      }).toList();
    } catch (e) {
      throw Exception('Error searching notes: $e');
    }
  }
}
