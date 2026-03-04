package com.treasurehunt.kvest.model

import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.mapping.Document
import org.springframework.data.mongodb.core.index.Indexed
import java.time.Instant

// ── User ──────────────────────────────────────────────────
@Document(collection = "users")
data class User(
    @Id val id: String? = null,
    @Indexed(unique = true) val email: String,
    val passwordHash: String,
    val displayName: String,
    val role: UserRole = UserRole.PLAYER,
    val createdAt: Instant = Instant.now(),
    val active: Boolean = true
)

enum class UserRole { PLAYER, ADMIN }

// ── Puzzle ────────────────────────────────────────────────
@Document(collection = "puzzles")
data class Puzzle(
    @Id val id: String? = null,
    val title: String,
    val description: String,
    val difficulty: Difficulty = Difficulty.MEDIUM,
    val active: Boolean = true,
    val createdBy: String,         // userId of admin
    val createdAt: Instant = Instant.now(),
    val updatedAt: Instant = Instant.now(),
    val tags: List<String> = emptyList(),
    val coverImageUrl: String? = null,
    val estimatedMinutes: Int = 30
)

enum class Difficulty { EASY, MEDIUM, HARD, EXPERT }

// ── Clue ─────────────────────────────────────────────────
@Document(collection = "clues")
data class Clue(
    @Id val id: String? = null,
    @Indexed val puzzleId: String,
    val orderIndex: Int,           // 0-based ordering within puzzle
    val type: ClueType,
    val content: String,           // The clue text / question
    val hint: String? = null,      // Optional hint shown on request
    val answer: String,            // Expected answer (case-insensitive check)
    val mediaUrl: String? = null,  // Optional image/audio clue
    val gpsCoordinate: GpsCoordinate? = null,
    val metadata: Map<String, Any> = emptyMap(),  // flexible extras
    val createdAt: Instant = Instant.now()
)

enum class ClueType { TEXT, IMAGE, GPS, QR_CODE, AUDIO, RIDDLE }

data class GpsCoordinate(
    val latitude: Double,
    val longitude: Double,
    val radiusMeters: Double = 20.0
)

// ── GameProgress ──────────────────────────────────────────
@Document(collection = "game_progress")
data class GameProgress(
    @Id val id: String? = null,
    @Indexed val userId: String,
    @Indexed val puzzleId: String,
    val status: GameStatus = GameStatus.IN_PROGRESS,
    val currentClueIndex: Int = 0,
    val hintsUsed: Int = 0,
    val startedAt: Instant = Instant.now(),
    val completedAt: Instant? = null,
    val answeredClues: List<AnsweredClue> = emptyList()
)

enum class GameStatus { IN_PROGRESS, COMPLETED, ABANDONED }

data class AnsweredClue(
    val clueId: String,
    val answeredAt: Instant = Instant.now(),
    val hintUsed: Boolean = false
)
