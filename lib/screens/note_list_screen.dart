import 'package:flutter/material.dart';
import 'package:project_movil/provider/auth_provider.dart';
import 'package:project_movil/provider/notes_provider.dart';
import 'package:project_movil/screens/note_editor_screen.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import 'login_screen.dart';
import 'package:intl/intl.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  final List<Color> noteColors = [
    const Color(0xFFFFF9C4),
    const Color(0xFFFFECB3),
    const Color(0xFFFFE0B2),
    const Color(0xFFFFCCBC),
  ];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      await context.read<NotesProvider>().loadNotes(userId);
    }
    setState(() => _isLoading = false);
  }

  void _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  String _formatDate(String date) {
    final DateTime dateTime = DateTime.parse(date);
    return DateFormat('d MMM, yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFF8E1),
            Colors.white.withOpacity(0.9),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.edit_note,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 15),
              const Text(
                'Mis Notas',
                style: TextStyle(
                  color: Color(0xFF5D4037),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFF5D4037)),
              onPressed: _logout,
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar Notas...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFFFD700)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Color(0xFFFFD700)),
                    onPressed: () {
                      _searchController.clear();
                      final userId = context.read<AuthProvider>().currentUser?.id;
                      if (userId != null) {
                        context.read<NotesProvider>().searchNotes('', userId);
                      }
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                onChanged: (value) {
                  final userId = context.read<AuthProvider>().currentUser?.id;
                  if (userId != null) {
                    context.read<NotesProvider>().searchNotes(value, userId);
                  }
                },
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                      ),
                    )
                  : Consumer<NotesProvider>(
                      builder: (context, notesProvider, child) {
                        if (notesProvider.notes.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.note_add_outlined,
                                    size: 80,
                                    color: Colors.amber[700],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'No hay notas aún',
                                  style: TextStyle(
                                    color: Color(0xFF5D4037),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Pulsa el botón + para crear una nota',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ListView.builder(
                            itemCount: notesProvider.notes.length,
                            itemBuilder: (context, index) {
                              final note = notesProvider.notes[index];
                              return Dismissible(
                                key: Key(note.id.toString()),
                                background: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.red[400],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 30),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Eliminar',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) {
                                  notesProvider.deleteNote(note.id!);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Nota Eliminada'),
                                      backgroundColor: Colors.red[400],
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => NoteEditorScreen(note: note),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: noteColors[index % noteColors.length],
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                note.title,
                                                style: const TextStyle(
                                                  color: Color(0xFF5D4037),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.5),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.edit,
                                                color: Colors.amber[700],
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          note.content,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 16,
                                            height: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.5),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    color: Colors.grey[700],
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    _formatDate(note.dateCreated),
                                                    style: TextStyle(
                                                      color: Colors.grey[700],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.grey[600],
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: Container(
          height: 65,
          width: 65,
          margin: const EdgeInsets.only(bottom: 20, right: 20),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NoteEditorScreen(),
                ),
              );
            },
            backgroundColor: const Color(0xFFFFD700),
            elevation: 8,
            highlightElevation: 4,
            child: const Icon(
              Icons.add,
              size: 32,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}