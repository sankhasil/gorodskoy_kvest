package com.treasurehunt.kvest.controller

import com.treasurehunt.kvest.service.PuzzleService
import org.springframework.http.HttpStatus
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
// ── AdminController ────────────────────────────────────────
@RestController
@RequestMapping("/api/admin")
class AdminController(private val puzzleService: PuzzleService) {

    @GetMapping("/puzzles")
    fun listAll() = puzzleService.getAllActive()

    @PostMapping("/puzzles")
    @ResponseStatus(HttpStatus.CREATED)
    fun createPuzzle(@RequestBody req: PuzzleRequest, auth: Authentication) =
        puzzleService.createPuzzle(req, auth.name)

    @PutMapping("/puzzles/{id}")
    fun updatePuzzle(@PathVariable id: String, @RequestBody req: PuzzleRequest) =
        puzzleService.updatePuzzle(id, req)

    @DeleteMapping("/puzzles/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    fun deletePuzzle(@PathVariable id: String) = puzzleService.deletePuzzle(id)

    @PostMapping("/puzzles/{puzzleId}/clues")
    @ResponseStatus(HttpStatus.CREATED)
    fun addClue(@PathVariable puzzleId: String, @RequestBody req: ClueRequest) =
        puzzleService.addClue(puzzleId, req)

    @GetMapping("/puzzles/{puzzleId}/clues")
    fun getClues(@PathVariable puzzleId: String) =
        puzzleService.getCluesForPuzzle(puzzleId)

    @PutMapping("/clues/{clueId}")
    fun updateClue(@PathVariable clueId: String, @RequestBody req: ClueRequest) =
        puzzleService.updateClue(clueId, req)

    @DeleteMapping("/clues/{clueId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    fun deleteClue(@PathVariable clueId: String) = puzzleService.deleteClue(clueId)
}
