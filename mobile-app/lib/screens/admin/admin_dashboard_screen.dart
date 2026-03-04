// lib/screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../services/services.dart';

final adminPuzzlesProvider = FutureProvider<List<Puzzle>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final list = await api.getList('/admin/puzzles');
  return list.map((j) => Puzzle.fromJson(j)).toList();
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzlesAsync = ref.watch(adminPuzzlesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF0a0a1a),
        actions: [
          IconButton(icon: const Icon(Icons.map), onPressed: () => context.go('/puzzles'), tooltip: 'Player View'),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => ref.read(authProvider.notifier).logout()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/admin/puzzles/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Puzzle'),
        backgroundColor: const Color(0xFFD4A017),
        foregroundColor: Colors.black,
      ),
      body: puzzlesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (puzzles) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: puzzles.length,
          itemBuilder: (_, i) => _AdminPuzzleTile(puzzle: puzzles[i]),
        ),
      ),
    );
  }
}

class _AdminPuzzleTile extends StatelessWidget {
  final Puzzle puzzle;
  const _AdminPuzzleTile({required this.puzzle});

  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFF0d0d1a),
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      leading: const Icon(Icons.map, color: Color(0xFFD4A017)),
      title: Text(puzzle.title),
      subtitle: Text('${puzzle.difficulty} · ${puzzle.estimatedMinutes} min'),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          icon: const Icon(Icons.list_alt, color: Colors.blue),
          tooltip: 'Edit Clues',
          onPressed: () => context.go('/admin/puzzles/${puzzle.id}/clues'),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.orange),
          tooltip: 'Edit Puzzle',
          onPressed: () => context.go('/admin/puzzles/${puzzle.id}/edit'),
        ),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────
// lib/screens/admin/clue_editor_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClueEditorScreen extends ConsumerStatefulWidget {
  final String puzzleId;
  const ClueEditorScreen({super.key, required this.puzzleId});
  @override
  ConsumerState<ClueEditorScreen> createState() => _ClueEditorState();
}

class _ClueEditorState extends ConsumerState<ClueEditorScreen> {
  List<dynamic> _clues = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadClues();
  }

  Future<void> _loadClues() async {
    final api = ref.read(apiServiceProvider);
    final list = await api.getList('/admin/puzzles/${widget.puzzleId}/clues');
    setState(() { _clues = list; _loading = false; });
  }

  void _showAddClueDialog() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF0d0d1a),
    builder: (_) => _AddClueForm(
      puzzleId: widget.puzzleId,
      orderIndex: _clues.length,
      onSaved: () { Navigator.pop(context); _loadClues(); },
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Clues (${_clues.length})')),
    floatingActionButton: FloatingActionButton(
      onPressed: _showAddClueDialog,
      backgroundColor: const Color(0xFFD4A017),
      foregroundColor: Colors.black,
      child: const Icon(Icons.add),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _clues.length,
            onReorder: (_, __) {},
            itemBuilder: (_, i) {
              final clue = _clues[i];
              return Card(
                key: ValueKey(clue['id']),
                color: const Color(0xFF0d0d1a),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text(clue['content'] ?? '', maxLines: 2),
                  subtitle: Text(clue['type'] ?? ''),
                  trailing: const Icon(Icons.drag_handle),
                ),
              );
            },
          ),
  );
}

class _AddClueForm extends ConsumerStatefulWidget {
  final String puzzleId;
  final int orderIndex;
  final VoidCallback onSaved;
  const _AddClueForm({required this.puzzleId, required this.orderIndex, required this.onSaved});
  @override
  ConsumerState<_AddClueForm> createState() => _AddClueFormState();
}

class _AddClueFormState extends ConsumerState<_AddClueForm> {
  final _contentCtrl = TextEditingController();
  final _answerCtrl = TextEditingController();
  final _hintCtrl = TextEditingController();
  String _type = 'TEXT';

  Future<void> _save() async {
    final api = ref.read(apiServiceProvider);
    await api.post('/admin/puzzles/${widget.puzzleId}/clues', {
      'orderIndex': widget.orderIndex, 'type': _type,
      'content': _contentCtrl.text, 'answer': _answerCtrl.text,
      'hint': _hintCtrl.text.isEmpty ? null : _hintCtrl.text,
    });
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('Add Clue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: _type,
        items: ['TEXT', 'IMAGE', 'GPS', 'QR_CODE', 'RIDDLE']
            .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
        onChanged: (v) => setState(() => _type = v!),
        decoration: const InputDecoration(labelText: 'Clue Type', border: OutlineInputBorder()),
      ),
      const SizedBox(height: 12),
      TextField(controller: _contentCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Clue Content', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: _answerCtrl, decoration: const InputDecoration(labelText: 'Expected Answer', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: _hintCtrl, decoration: const InputDecoration(labelText: 'Hint (optional)', border: OutlineInputBorder())),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4A017), foregroundColor: Colors.black),
          child: const Text('Save Clue'),
        ),
      ),
    ]),
  );
}

// ─────────────────────────────────────────────────────────
// lib/screens/admin/puzzle_editor_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PuzzleEditorScreen extends ConsumerStatefulWidget {
  final String? puzzleId;
  const PuzzleEditorScreen({super.key, this.puzzleId});
  @override
  ConsumerState<PuzzleEditorScreen> createState() => _PuzzleEditorState();
}

class _PuzzleEditorState extends ConsumerState<PuzzleEditorScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _difficulty = 'MEDIUM';
  int _minutes = 30;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    final api = ref.read(apiServiceProvider);
    final data = {'title': _titleCtrl.text, 'description': _descCtrl.text, 'difficulty': _difficulty, 'estimatedMinutes': _minutes};
    if (widget.puzzleId != null) {
      await api.put('/admin/puzzles/${widget.puzzleId}', data);
    } else {
      await api.post('/admin/puzzles', data);
    }
    if (mounted) context.go('/admin');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.puzzleId == null ? 'New Puzzle' : 'Edit Puzzle')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())),
        const SizedBox(height: 16),
        TextField(controller: _descCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _difficulty,
          items: ['EASY', 'MEDIUM', 'HARD', 'EXPERT'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
          onChanged: (v) => setState(() => _difficulty = v!),
          decoration: const InputDecoration(labelText: 'Difficulty', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4A017), foregroundColor: Colors.black, padding: const EdgeInsets.all(16)),
            child: _saving ? const CircularProgressIndicator() : const Text('SAVE PUZZLE'),
          ),
        ),
      ]),
    ),
  );
}