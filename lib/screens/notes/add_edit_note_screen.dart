import 'package:flutter/material.dart';
import '../../models/note.dart';
import '../../services/database_service.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isStarred = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _isStarred = widget.note?.isStarred ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      return;
    }

    if (widget.note != null) {
      widget.note!.title = title;
      widget.note!.content = content;
      widget.note!.isStarred = _isStarred;
      await DatabaseService.updateNote(widget.note!);
    } else {
      final newNote = Note.create(
        title: title,
        content: content,
        isStarred: _isStarred,
      );
      await DatabaseService.addNote(newNote);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteNote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notu Sil'),
        content: const Text('Bu notu silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.note != null) {
      await DatabaseService.deleteNote(widget.note!.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note != null ? 'Notu Düzenle' : 'Not Ekle'),
        actions: [
          IconButton(
            icon: Icon(_isStarred ? Icons.star : Icons.star_border),
            color: _isStarred ? Colors.amber : null,
            onPressed: () {
              setState(() {
                _isStarred = !_isStarred;
              });
            },
          ),
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteNote,
            ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Başlık',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Notunuzu buraya yazın...',
                  border: InputBorder.none,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
