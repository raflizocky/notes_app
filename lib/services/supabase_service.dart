import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:notes_app/config/app_config.dart';
import 'package:notes_app/models/note.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  late final SupabaseClient _client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  Future<List<Note>> getNotes() async {
    final response = await _client.from('notes').select().order('created_at');
    final List<dynamic> data = response;
    return data.map((json) => Note.fromJson(json)).toList();
  }

  Future<void> addNote(String title, String description) async {
    await _client.from('notes').insert({
      'title': title,
      'description': description,
    });
  }

  Future<void> updateNote(int id, String title, String description) async {
    await _client.from('notes').update({
      'title': title,
      'description': description,
    }).match({'id': id});
  }

  Future<void> deleteNote(int id) async {
    await _client.from('notes').delete().match({'id': id});
  }
}
