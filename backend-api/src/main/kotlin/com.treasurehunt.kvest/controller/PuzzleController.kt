package com.treasurehunt.kvest.controller

import com.treasurehunt.kvest.service.PuzzleService
import org.springframework.http.HttpStatus
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*

// ── PuzzleController (Players) ────────────────────────────
@RestController
@RequestMapping("/api/puzzles")
class PuzzleController(private val puzzleService: PuzzleService) {

    @GetMapping
    fun listActive() = puzzleService.getAllActive()

    @GetMapping("/{id}")
    fun getOne(@PathVariable id: String) = puzzleService.getById(id)

    @GetMapping("/{id}/clues")
    fun getClues(@PathVariable id: String) = puzzleService.getCluesForPuzzle(id)
        .map { it.copy(answer = "***") }  // Hide answers from players
}