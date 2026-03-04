package com.treasurehunt.kvest.controller

import com.treasurehunt.kvest.service.AuthService
import org.springframework.http.HttpStatus
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*

// ── AuthController ────────────────────────────────────────
@RestController
@RequestMapping("/api/auth")
class AuthController(private val authService: AuthService) {

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    fun register(@RequestBody req: RegisterRequest) = authService.register(req)

    @PostMapping("/login")
    fun login(@RequestBody req: LoginRequest) = authService.login(req)
}


