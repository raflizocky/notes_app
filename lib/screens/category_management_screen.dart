import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class CategoryManagementScreen extends StatefulWidget {
  final Function onCategoriesChanged;

  const CategoryManagementScreen(
      {super.key, required this.onCategoriesChanged});

  @override
  CategoryManagementScreenState createState() =>
      CategoryManagementScreenState();
}

class CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _supabaseService.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      _showErrorSnackBar('Error loading categories: $e');
    }
  }

  Future<void> _addCategory() async {
    final result = await _showCategoryDialog('Add Category');
    if (result != null && result.isNotEmpty) {
      try {
        await _supabaseService.addCategory(result);
        _loadCategories();
      } catch (e) {
        _showErrorSnackBar('Error adding category: $e');
      }
    }
  }

  Future<void> _editCategory(Category category) async {
    final result =
        await _showCategoryDialog('Edit Category', initialValue: category.name);
    if (result != null && result.isNotEmpty) {
      try {
        await _supabaseService.updateCategory(category.id, result);
        _loadCategories();
      } catch (e) {
        _showErrorSnackBar('Error updating category: $e');
      }
    }
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: Text(
              'Are you sure you want to delete "${category.name}"? Notes in this category will be kept but will no longer be associated with any category.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _supabaseService.deleteCategory(category.id);
        if (!mounted) return;
        await _loadCategories();
        widget.onCategoriesChanged();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Category "${category.name}" has been deleted. Associated notes have been kept without a category.')),
          );
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Error deleting category: $e');
        }
      }
    }
  }

  Future<String?> _showCategoryDialog(String title,
      {String? initialValue}) async {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter category name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(initialValue != null ? 'Update' : 'Add'),
              onPressed: () => Navigator.of(context).pop(controller.text),
            ),
          ],
        );
      },
    );
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
        title: const Text('Manage Categories'),
      ),
      body: ListView.separated(
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final category = _categories[index];
          return ListTile(
            title: Text(category.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                  onPressed: () => _editCategory(category),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCategory(category),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
