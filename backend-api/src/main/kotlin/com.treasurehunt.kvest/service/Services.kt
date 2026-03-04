package com.treasurehunt.kvest.service

import com.treasurehunt.kvest.model.*
import com.treasurehunt.kvest.repository.*
import com.treasurehunt.kvest.security.JwtUtil
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import org.springframework.http.HttpStatus
import org.springframework.web.server.ResponseStatusException
import java.time.Instant

// ── DTOs ─────────────────────────────────────────────────
data class LoginRequest(val email: String, val password: String)
data class RegisterRequest(val email: String, val password: String, val displayName: String)
data class AuthResponse(val token: String, val userId: String, val role: String, val displayName: String)

data class PuzzleRequest(
    val title: String, val description: String,
    val difficulty: Difficulty = Difficulty.MEDIUM,
    val tags: List<String> = emptyList(),
    val estimatedMinutes: Int = 30,
    val coverImageUrl: String? = null
)

data class ClueRequest(
    val orderIndex: Int, val type: ClueType, val content: String,
    val hint: String? = null, val answer: String,
    val mediaUrl: String? = null,
    val gpsCoordinate: GpsCoordinate? = null,
    val metadata: Map<String, Any> = emptyMap()
)

data class AnswerRequest(val progressId: String, val answer: String)
data class GameStartResponse(val progressId: String, val clue: Clue, val totalClues: Int)
data class AnswerResponse(val correct: Boolean, val nextClue: Clue?, val completed: Boolean, val score: Int? = null)

// ── AuthService ───────────────────────────────────────────
@Service
class AuthService(
    private val userRepo: UserRepository,
    private val encoder: PasswordEncoder,
    private val jwtUtil: JwtUtil
) {
    fun register(req: RegisterRequest): AuthResponse {
        if (userRepo.existsByEmail(req.email))
            throw ResponseStatusException(HttpStatus.CONFLICT, "Email already registered")
        val user = userRepo.save(User(
            email = req.email,
            passwordHash = encoder.encode(req.password),
            displayName = req.displayName
        ))
        val token = jwtUtil.generateToken(user.id!!, user.email, user.role.name)
        return AuthResponse(token, user.id, user.role.name, user.displayName)
    }

    fun login(req: LoginRequest): AuthResponse {
        val user = userRepo.findByEmail(req.email)
            .orElseThrow { ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials") }
        if (!encoder.matches(req.password, user.passwordHash))
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials")
        val token = jwtUtil.generateToken(user.id!!, user.email, user.role.name)
        return AuthResponse(token, user.id, user.role.name, user.displayName)
    }
}



