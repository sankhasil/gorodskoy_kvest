// lib/services/auth_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class AuthState {
  final String? token;
  final String? userId;
  final String? role;
  final String? displayName;

  const AuthState({this.token, this.userId, this.role, this.displayName});

  bool get isLoggedIn => token != null;
  bool get isAdmin => role == 'ADMIN';
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthNotifier(this._api) : super(const AuthState()) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final token = await _storage.read(key: 'token');
    final userId = await _storage.read(key: 'userId');
    final role = await _storage.read(key: 'role');
    final displayName = await _storage.read(key: 'displayName');
    if (token != null) {
      state = AuthState(token: token, userId: userId, role: role, displayName: displayName);
    }
  }

  Future<void> login(String email, String password) async {
    final res = await _api.post('/auth/login', {'email': email, 'password': password});
    await _persist(res);
  }

  Future<void> register(String email, String password, String displayName) async {
    final res = await _api.post('/auth/register', {
      'email': email, 'password': password, 'displayName': displayName,
    });
    await _persist(res);
  }

  Future<void> _persist(Map<String, dynamic> res) async {
    await _storage.write(key: 'token', value: res['token']);
    await _storage.write(key: 'userId', value: res['userId']);
    await _storage.write(key: 'role', value: res['role']);
    await _storage.write(key: 'displayName', value: res['displayName']);
    state = AuthState(
      token: res['token'], userId: res['userId'],
      role: res['role'], displayName: res['displayName'],
    );
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(apiServiceProvider)),
);

// ─────────────────────────────────────────────────────────
// lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String baseUrl = 'http://localhost:8080/api';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 10)));
  }

  void setToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  Future<Map<String, dynamic>> get(String path) async {
    final res = await _dio.get(path);
    return res.data;
  }

  Future<List<dynamic>> getList(String path) async {
    final res = await _dio.get(path);
    return res.data as List;
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> data) async {
    final res = await _dio.post(path, data: data);
    return res.data;
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> data) async {
    final res = await _dio.put(path, data: data);
    return res.data;
  }

  Future<void> delete(String path) async => await _dio.delete(path);
}

final apiServiceProvider = Provider((ref) {
  final service = ApiService();
  ref.listen(authProvider, (_, next) => service.setToken(next.token));
  return service;
});

// ─────────────────────────────────────────────────────────
// lib/services/puzzle_service.dart
import '../models/models.dart';

class PuzzleService {
  final ApiService _api;
  PuzzleService(this._api);

  Future<List<Puzzle>> getPuzzles() async {
    final list = await _api.getList('/puzzles');
    return list.map((j) => Puzzle.fromJson(j)).toList();
  }

  Future<GameProgress> startGame(String puzzleId) async {
    final res = await _api.post('/game/start', {'puzzleId': puzzleId});
    return GameProgress.fromJson(res);
  }

  Future<AnswerResponse> submitAnswer(String progressId, String answer) async {
    final res = await _api.post('/game/answer', {'progressId': progressId, 'answer': answer});
    return AnswerResponse.fromJson(res);
  }

  Future<String> getHint(String progressId) async {
    final res = await _api.get('/game/hint/$progressId');
    return res['hint'] ?? 'No hint available';
  }
}

final puzzleServiceProvider = Provider((ref) => PuzzleService(ref.read(apiServiceProvider)));