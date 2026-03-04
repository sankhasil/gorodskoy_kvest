package com.treasurehunt.kvest

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class TreasureHuntApplication

fun main(args: Array<String>) {
    runApplication<TreasureHuntApplication>(*args)
}