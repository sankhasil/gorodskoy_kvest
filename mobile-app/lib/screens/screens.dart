// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/services.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authProvider.notifier).login(_emailCtrl.text, _passCtrl.text);
      final auth = ref.read(authProvider);
      if (mounted) context.go(auth.isAdmin ? '/admin' : '/puzzles');
    } catch (e) {
      setState(() => _error = 'Invalid credentials');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1a0a00), Color(0xFF2d1b00)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          color: Colors.black54,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.explore, size: 64, color: Color(0xFFD4A017)),
              const SizedBox(height: 16),
              const Text('TREASURE HUNT', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFD4A017), letterSpacing: 4)),
              const SizedBox(height: 32),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl, obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4A017), padding: const EdgeInsets.all(16)),
                  child: _loading ? const CircularProgressIndicator() : const Text('BEGIN ADVENTURE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ),
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────
// lib/screens/puzzle_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../services/services.dart';

final puzzlesProvider = FutureProvider<List<Puzzle>>((ref) {
  return ref.read(puzzleServiceProvider).getPuzzles();
});

class PuzzleListScreen extends ConsumerWidget {
  const PuzzleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final puzzlesAsync = ref.watch(puzzlesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Adventure'),
        backgroundColor: const Color(0xFF1a0a00),
        actions: [
          if (auth.isAdmin)
            IconButton(icon: const Icon(Icons.admin_panel_settings), onPressed: () => context.go('/admin')),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => ref.read(authProvider.notifier).logout()),
        ],
      ),
      body: puzzlesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (puzzles) => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 12, mainAxisSpacing: 12,
          ),
          itemCount: puzzles.length,
          itemBuilder: (_, i) => _PuzzleCard(puzzle: puzzles[i]),
        ),
      ),
    );
  }
}

class _PuzzleCard extends StatelessWidget {
  final Puzzle puzzle;
  const _PuzzleCard({required this.puzzle});

  Color get _difficultyColor => switch (puzzle.difficulty) {
    'EASY' => Colors.green, 'MEDIUM' => Colors.orange,
    'HARD' => Colors.red, _ => Colors.purple,
  };

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.go('/puzzles/${puzzle.id}/play'),
    child: Card(
      color: const Color(0xFF1e1200),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            color: const Color(0xFF2d1b00),
            image: puzzle.coverImageUrl != null
                ? DecorationImage(image: NetworkImage(puzzle.coverImageUrl!), fit: BoxFit.cover)
                : null,
          ),
          child: puzzle.coverImageUrl == null
              ? const Center(child: Icon(Icons.map, size: 48, color: Color(0xFFD4A017)))
              : null,
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(puzzle.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: _difficultyColor.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
              child: Text(puzzle.difficulty, style: TextStyle(color: _difficultyColor, fontSize: 10)),
            ),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.timer_outlined, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text('${puzzle.estimatedMinutes} min', style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ]),
          ]),
        ),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────
// lib/screens/puzzle_game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../services/services.dart';

class PuzzleGameScreen extends ConsumerStatefulWidget {
  final String puzzleId;
  const PuzzleGameScreen({super.key, required this.puzzleId});
  @override
  ConsumerState<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends ConsumerState<PuzzleGameScreen> {
  GameProgress? _progress;
  Clue? _currentClue;
  final _answerCtrl = TextEditingController();
  bool _loading = true;
  bool _wrong = false;
  String? _hint;
  int _totalClues = 0;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  Future<void> _startGame() async {
    final svc = ref.read(puzzleServiceProvider);
    final prog = await svc.startGame(widget.puzzleId);
    setState(() {
      _progress = prog; _currentClue = prog.clue;
      _totalClues = prog.totalClues; _loading = false;
    });
  }

  Future<void> _submitAnswer() async {
    final svc = ref.read(puzzleServiceProvider);
    final res = await svc.submitAnswer(_progress!.progressId, _answerCtrl.text);
    if (res.completed) {
      if (mounted) _showComplete(res.score ?? 0);
    } else if (res.correct && res.nextClue != null) {
      setState(() { _currentClue = res.nextClue; _wrong = false; _hint = null; _answerCtrl.clear(); });
    } else {
      setState(() => _wrong = true);
    }
  }

  Future<void> _getHint() async {
    final hint = await ref.read(puzzleServiceProvider).getHint(_progress!.progressId);
    setState(() => _hint = hint);
  }

  void _showComplete(int score) => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1a0a00),
      title: const Text('🎉 Puzzle Complete!', textAlign: TextAlign.center),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.emoji_events, size: 64, color: Color(0xFFD4A017)),
        Text('Score: $score', style: const TextStyle(fontSize: 24, color: Color(0xFFD4A017))),
      ]),
      actions: [
        TextButton(onPressed: () => context.go('/puzzles'), child: const Text('Back to Puzzles')),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final clue = _currentClue!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Clue ${clue.orderIndex + 1} of $_totalClues'),
        backgroundColor: const Color(0xFF1a0a00),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          LinearProgressIndicator(
            value: (clue.orderIndex + 1) / _totalClues,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation(Color(0xFFD4A017)),
          ),
          const SizedBox(height: 32),
          Card(
            color: const Color(0xFF1e1200),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                Icon(_clueIcon(clue.type), size: 40, color: const Color(0xFFD4A017)),
                const SizedBox(height: 16),
                Text(clue.content, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
                if (clue.mediaUrl != null) ...[
                  const SizedBox(height: 16),
                  Image.network(clue.mediaUrl!, height: 150),
                ],
                if (_hint != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('💡 $_hint', style: const TextStyle(color: Colors.amber)),
                  ),
                ],
              ]),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _answerCtrl,
            decoration: InputDecoration(
              labelText: 'Your Answer',
              errorText: _wrong ? 'Wrong answer, try again!' : null,
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submitAnswer(),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _submitAnswer,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4A017), padding: const EdgeInsets.all(16)),
                child: const Text('SUBMIT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _getHint,
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('Hint'),
            ),
          ]),
        ]),
      ),
    );
  }

  IconData _clueIcon(String type) => switch (type) {
    'GPS' => Icons.location_on, 'IMAGE' => Icons.image,
    'QR_CODE' => Icons.qr_code, 'AUDIO' => Icons.mic,
    _ => Icons.help_outline,
  };
}
