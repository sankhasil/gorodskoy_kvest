package com.treasurehunt.kvest.service

import com.treasurehunt.kvest.model.*
import com.treasurehunt.kvest.repository.*
import com.treasurehunt.kvest.security.JwtUtil
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import org.springframework.http.HttpStatus
import org.springframework.web.server.ResponseStatusException
import java.time.Instant
// ── PuzzleService ─────────────────────────────────────────
@Service
class PuzzleService(
    private val puzzleRepo: PuzzleRepository,
    private val clueRepo: ClueRepository
) {
    fun getAllActive(): List<Puzzle> = puzzleRepo.findAllByActiveTrue()

    fun getById(id: String): Puzzle = puzzleRepo.findById(id)
        .orElseThrow { ResponseStatusException(HttpStatus.NOT_FOUND, "Puzzle not found") }

    fun createPuzzle(req: PuzzleRequest, adminId: String): Puzzle = puzzleRepo.save(
        Puzzle(
            title = req.title, description = req.description,
            difficulty = req.difficulty, tags = req.tags,
            estimatedMinutes = req.estimatedMinutes,
            coverImageUrl = req.coverImageUrl,
            createdBy = adminId
        )
    )

    fun updatePuzzle(id: String, req: PuzzleRequest): Puzzle {
        val existing = getById(id)
        return puzzleRepo.save(existing.copy(
            title = req.title, description = req.description,
            difficulty = req.difficulty, tags = req.tags,
            updatedAt = Instant.now()
        ))
    }

    fun deletePuzzle(id: String) {
        clueRepo.deleteAllByPuzzleId(id)
        puzzleRepo.deleteById(id)
    }

    fun addClue(puzzleId: String, req: ClueRequest): Clue {
        getById(puzzleId) // verify puzzle exists
        return clueRepo.save(Clue(
            puzzleId = puzzleId, orderIndex = req.orderIndex, type = req.type,
            content = req.content, hint = req.hint, answer = req.answer,
            mediaUrl = req.mediaUrl, gpsCoordinate = req.gpsCoordinate,
            metadata = req.metadata
        ))
    }

    fun getCluesForPuzzle(puzzleId: String): List<Clue> =
        clueRepo.findAllByPuzzleIdOrderByOrderIndexAsc(puzzleId)

    fun updateClue(clueId: String, req: ClueRequest): Clue {
        val existing = clueRepo.findById(clueId)
            .orElseThrow { ResponseStatusException(HttpStatus.NOT_FOUND, "Clue not found") }
        return clueRepo.save(existing.copy(
            orderIndex = req.orderIndex, type = req.type,
            content = req.content, hint = req.hint, answer = req.answer,
            mediaUrl = req.mediaUrl, metadata = req.metadata
        ))
    }

    fun deleteClue(clueId: String) = clueRepo.deleteById(clueId)
}
