import 'package:flutter/material.dart';
import 'package:notes_app/models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final String searchQuery;
  final String categoryName;

  const NoteCard({
    super.key,
    required this.note,
    required this.onDelete,
    required this.onEdit,
    this.searchQuery = '',
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(note.id.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm"),
              content: const Text("Are you sure you want to delete this note?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("CANCEL"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("DELETE"),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        onDelete();
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: ListTile(
          title: _highlightText(context, note.title, searchQuery),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _highlightText(context, note.description, searchQuery),
              const SizedBox(height: 4),
              Text(
                'Category: ${note.categoryName ?? 'Uncategorized'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
        ),
      ),
    );
  }

  Widget _highlightText(BuildContext context, String text, String query) {
    if (query.isEmpty) {
      return Text(text);
    }

    final matches = query.toLowerCase().allMatches(text.toLowerCase());
    final spans = <TextSpan>[];
    var start = 0;

    for (final match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: const TextStyle(
          backgroundColor: Colors.yellow,
          fontWeight: FontWeight.bold,
        ),
      ));
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: spans,
      ),
    );
  }
}
