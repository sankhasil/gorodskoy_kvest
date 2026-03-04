package com.treasurehunt.kvest.controller

import com.treasurehunt.kvest.service.GameService
import org.springframework.http.HttpStatus
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
// ── GameController ────────────────────────────────────────
@RestController
@RequestMapping("/api/game")
class GameController(private val gameService: GameService) {

    @PostMapping("/start")
    fun start(@RequestParam puzzleId: String, auth: Authentication) =
        gameService.startGame(auth.name, puzzleId)

    @PostMapping("/answer")
    fun answer(@RequestBody req: AnswerRequest, auth: Authentication) =
        gameService.submitAnswer(auth.name, req)

    @GetMapping("/hint/{progressId}")
    fun hint(@PathVariable progressId: String, auth: Authentication) =
        mapOf("hint" to gameService.requestHint(progressId, auth.name))
}
