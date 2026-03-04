package com.treasurehunt.kvest.service

import com.treasurehunt.kvest.model.*
import com.treasurehunt.kvest.repository.*
import com.treasurehunt.kvest.security.JwtUtil
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import org.springframework.http.HttpStatus
import org.springframework.web.server.ResponseStatusException
import java.time.Instant
// ── GameService ───────────────────────────────────────────
@Service
class GameService(
    private val progressRepo: GameProgressRepository,
    private val clueRepo: ClueRepository,
    private val puzzleRepo: PuzzleRepository
) {
    fun startGame(userId: String, puzzleId: String): GameStartResponse {
        puzzleRepo.findById(puzzleId)
            .orElseThrow { ResponseStatusException(HttpStatus.NOT_FOUND, "Puzzle not found") }

        // Resume if in-progress
        val existing = progressRepo.findByUserIdAndPuzzleId(userId, puzzleId)
        val progress = existing.filter { it.status == GameStatus.IN_PROGRESS }
            .orElseGet {
                progressRepo.save(GameProgress(userId = userId, puzzleId = puzzleId))
            }

        val firstClue = clueRepo.findByPuzzleIdAndOrderIndex(puzzleId, progress.currentClueIndex)
            .orElseThrow { ResponseStatusException(HttpStatus.NOT_FOUND, "No clues configured") }
        val totalClues = clueRepo.countByPuzzleId(puzzleId).toInt()

        return GameStartResponse(progress.id!!, firstClue, totalClues)
    }

    fun submitAnswer(userId: String, req: AnswerRequest): AnswerResponse {
        val progress = progressRepo.findById(req.progressId)
            .orElseThrow { ResponseStatusException(HttpStatus.NOT_FOUND, "Progress not found") }

        if (progress.userId != userId)
            throw ResponseStatusException(HttpStatus.FORBIDDEN, "Not your game")

        val currentClue = clueRepo.findByPuzzleIdAndOrderIndex(progress.puzzleId, progress.currentClueIndex)
            .orElseThrow { ResponseStatusException(HttpStatus.NOT_FOUND, "Clue not found") }

        val isCorrect = currentClue.answer.equals(req.answer.trim(), ignoreCase = true)
        if (!isCorrect) return AnswerResponse(correct = false, nextClue = null, completed = false)

        val answered = progress.answeredClues + AnsweredClue(clueId = currentClue.id!!)
        val nextIndex = progress.currentClueIndex + 1
        val nextClue = clueRepo.findByPuzzleIdAndOrderIndex(progress.puzzleId, nextIndex).orElse(null)

        return if (nextClue == null) {
            progressRepo.save(progress.copy(
                status = GameStatus.COMPLETED, completedAt = Instant.now(), answeredClues = answered
            ))
            val score = calculateScore(progress)
            AnswerResponse(correct = true, nextClue = null, completed = true, score = score)
        } else {
            progressRepo.save(progress.copy(currentClueIndex = nextIndex, answeredClues = answered))
            AnswerResponse(correct = true, nextClue = nextClue, completed = false)
        }
    }

    fun requestHint(progressId: String, userId: String): String? {
        val progress = progressRepo.findById(progressId)
            .orElseThrow { ResponseStatusException(HttpStatus.NOT_FOUND, "Progress not found") }
        val clue = clueRepo.findByPuzzleIdAndOrderIndex(progress.puzzleId, progress.currentClueIndex)
            .orElseThrow { ResponseStatusException(HttpStatus.NOT_FOUND, "Clue not found") }
        progressRepo.save(progress.copy(hintsUsed = progress.hintsUsed + 1))
        return clue.hint ?: "No hint available for this clue"
    }

    private fun calculateScore(progress: GameProgress): Int {
        val timeSecs = (Instant.now().epochSecond - progress.startedAt.epochSecond).toInt()
        val timeBonus = maxOf(0, 1000 - timeSecs)
        val hintPenalty = progress.hintsUsed * 50
        return maxOf(0, 500 + timeBonus - hintPenalty)
    }
}