package com.treasurehunt.kvest.repository

import com.treasurehunt.kvest.model.*
import org.springframework.data.mongodb.repository.MongoRepository
import org.springframework.stereotype.Repository
import java.util.Optional

@Repository
interface UserRepository : MongoRepository<User, String> {
    fun findByEmail(email: String): Optional<User>
    fun existsByEmail(email: String): Boolean
}

@Repository
interface PuzzleRepository : MongoRepository<Puzzle, String> {
    fun findAllByActiveTrue(): List<Puzzle>
    fun findAllByActiveTrueAndDifficulty(difficulty: Difficulty): List<Puzzle>
    fun findAllByCreatedBy(adminId: String): List<Puzzle>
}

@Repository
interface ClueRepository : MongoRepository<Clue, String> {
    fun findAllByPuzzleIdOrderByOrderIndexAsc(puzzleId: String): List<Clue>
    fun findByPuzzleIdAndOrderIndex(puzzleId: String, orderIndex: Int): Optional<Clue>
    fun countByPuzzleId(puzzleId: String): Long
    fun deleteAllByPuzzleId(puzzleId: String)
}

@Repository
interface GameProgressRepository : MongoRepository<GameProgress, String> {
    fun findByUserIdAndPuzzleId(userId: String, puzzleId: String): Optional<GameProgress>
    fun findAllByUserId(userId: String): List<GameProgress>
    fun findAllByPuzzleId(puzzleId: String): List<GameProgress>
}