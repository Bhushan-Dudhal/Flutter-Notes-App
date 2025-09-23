import 'package:flutter/material.dart';
import 'package:notes_app/database/notes_database.dart';
import 'package:notes_app/screen/note_dialog.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MaterialApp(home: NotesScreen()));
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> notes = [];

  final List<Color> noteColors = [
    const Color(0xFFF3E5F5),
    const Color(0xFFFFF3E0),
    const Color(0xFFE1F5FE),
    const Color(0xFFFCE4EC),
    const Color(0xFF89CFF0),
    const Color(0xFFFFABAB),
    const Color(0xFFB2F9FC),
    const Color(0xFFFFD59A),
    const Color(0xFFFFE4B5),
    const Color(0xFF98FB98),
    const Color(0xFFFFFF00),
    const Color(0xFFAFEEEE),
    const Color(0xFFFFB6C1),
    const Color(0xFFFFAD23),
    const Color(0xFF3D3D3D),
  ];

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    final fetchNotes = await NotesDatabase.instance.getNotes();
    setState(() {
      notes = fetchNotes;
    });
  }

  void showNoteDialog({
    int? id,
    String? title,
    String? content,
    int colorIndex = 0,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return NoteDialog(
          colorIndex: colorIndex,
          noteColors: noteColors,
          noteId: id,
          title: title,
          content: content,
          onNoteSaved: (newTitle, newDescription, newColorIndex, newDate) async {
            if (id == null) {
              await NotesDatabase.instance.addNote(
                newTitle,
                newDescription,
                newDate,
                newColorIndex,
              );
            } else {
              await NotesDatabase.instance.updateNote(
                id,
                newTitle,
                newDescription,
                newDate,
                newColorIndex,
              );
            }
            fetchNotes();
          },
        );
      },
    );
  }

  void deleteNote(int id) async {
    await NotesDatabase.instance.deleteNote(id);
    fetchNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notes',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 28,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showNoteDialog();
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black87),
      ),
      body: notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notes_outlined, size: 80, color: Colors.grey[600]),
                  const SizedBox(height: 20),
                  Text(
                    "No Notes Found",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[400],  
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];

                  DateTime date =
                      DateTime.fromMillisecondsSinceEpoch(note['date']);
                  String formattedDate =
                      DateFormat('dd MMM yyyy').format(date);

                  Color boxColor = noteColors[(note['color'] ?? 0)
                      .clamp(0, noteColors.length - 1)];

                  return GestureDetector(
                    onTap: () {
                      showNoteDialog(
                        id: note['id'],
                        title: note['title'],
                        content: note['description'],
                        colorIndex: note['color'],
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: boxColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note['title'] ?? "",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            note['description'] ?? "",
                            style: const TextStyle(fontSize: 14),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: boxColor, // same as note
                                foregroundColor: Colors.black54,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                deleteNote(note['id']);
                              },
                              icon: const Icon(Icons.delete, size: 18),
                              label: const Text("Delete", style:  TextStyle(color:Colors.black87)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
