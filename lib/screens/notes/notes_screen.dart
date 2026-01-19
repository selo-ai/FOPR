import 'package:flutter/material.dart';
import '../../models/note.dart';
import '../../services/database_service.dart';
import 'add_edit_note_screen.dart';
import 'package:intl/intl.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    setState(() {
      _notes = DatabaseService.getAllNotes();
    });
  }

  Future<void> _addNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditNoteScreen()),
    );

    if (result == true) {
      _loadNotes();
    }
  }

  Future<void> _editNote(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditNoteScreen(note: note)),
    );

    if (result == true) {
      _loadNotes();
    }
  }

  Future<void> _deleteNote(Note note) async {
    // Show confirmation dialog before deleting from swipe?
    // User requested consistency with other modules. Usually swipe delete has confirmation or undo.
    // Let's verify with confirmation dialog to be safe.
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

    if (confirmed == true) {
      await DatabaseService.deleteNote(note.id);
      _loadNotes();
    } else {
      // Rebuild to close the dismissible if cancelled (trick to reset state)
      setState(() {}); 
    }
  }

  Future<void> _toggleStar(Note note) async {
    note.isStarred = !note.isStarred;
    await DatabaseService.updateNote(note);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notlar'),
      ),
      body: _notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz not eklenmemiş',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Dismissible(
                  key: Key(note.id),
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      // Right swipe (Edit)
                      _editNote(note);
                      return false; // Don't dismiss
                    } else {
                      // Left swipe (Delete)
                      await _deleteNote(note);
                      return false; // Don't dismiss automatically, let _deleteNote handle removal + rebuild
                    }
                  },
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () => _editNote(note),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    note.title.isNotEmpty ? note.title : '(Başlıksız)',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    note.isStarred ? Icons.star : Icons.star_border,
                                    color: note.isStarred ? Colors.amber : Colors.grey.shade400,
                                  ),
                                  onPressed: () => _toggleStar(note),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            if (note.content.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                note.content,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  height: 1.4,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('d MMM yyyy HH:mm', 'tr_TR').format(note.updatedAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}
