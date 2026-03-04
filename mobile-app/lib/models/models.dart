// lib/models/models.dart
class Puzzle {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final bool active;
  final List<String> tags;
  final String? coverImageUrl;
  final int estimatedMinutes;

  const Puzzle({
    required this.id, required this.title, required this.description,
    required this.difficulty, required this.active, required this.tags,
    this.coverImageUrl, required this.estimatedMinutes,
  });

  factory Puzzle.fromJson(Map<String, dynamic> j) => Puzzle(
    id: j['id'], title: j['title'], description: j['description'],
    difficulty: j['difficulty'], active: j['active'],
    tags: List<String>.from(j['tags'] ?? []),
    coverImageUrl: j['coverImageUrl'],
    estimatedMinutes: j['estimatedMinutes'] ?? 30,
  );

  Map<String, dynamic> toJson() => {
    'title': title, 'description': description, 'difficulty': difficulty,
    'tags': tags, 'estimatedMinutes': estimatedMinutes,
    if (coverImageUrl != null) 'coverImageUrl': coverImageUrl,
  };
}

class Clue {
  final String id;
  final String puzzleId;
  final int orderIndex;
  final String type;
  final String content;
  final String? hint;
  final String? mediaUrl;

  const Clue({
    required this.id, required this.puzzleId, required this.orderIndex,
    required this.type, required this.content, this.hint, this.mediaUrl,
  });

  factory Clue.fromJson(Map<String, dynamic> j) => Clue(
    id: j['id'], puzzleId: j['puzzleId'], orderIndex: j['orderIndex'],
    type: j['type'], content: j['content'],
    hint: j['hint'], mediaUrl: j['mediaUrl'],
  );

  Map<String, dynamic> toJson() => {
    'orderIndex': orderIndex, 'type': type, 'content': content,
    if (hint != null) 'hint': hint,
    if (mediaUrl != null) 'mediaUrl': mediaUrl,
  };
}

class GameProgress {
  final String progressId;
  final Clue clue;
  final int totalClues;

  const GameProgress({required this.progressId, required this.clue, required this.totalClues});

  factory GameProgress.fromJson(Map<String, dynamic> j) => GameProgress(
    progressId: j['progressId'],
    clue: Clue.fromJson(j['clue']),
    totalClues: j['totalClues'],
  );
}

class AnswerResponse {
  final bool correct;
  final Clue? nextClue;
  final bool completed;
  final int? score;

  const AnswerResponse({required this.correct, this.nextClue, required this.completed, this.score});

  factory AnswerResponse.fromJson(Map<String, dynamic> j) => AnswerResponse(
    correct: j['correct'], completed: j['completed'], score: j['score'],
    nextClue: j['nextClue'] != null ? Clue.fromJson(j['nextClue']) : null,
  );
}