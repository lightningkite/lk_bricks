package edu.shanethompson.hackernewsreader.domain

import kotlinx.datetime.Clock
import kotlinx.serialization.Serializable

@Serializable
data class TodoTask(
    override val id: Long = 1L,
    val title: String = "",
    val description: String = "",
    val created: Long = Clock.System.now().toEpochMilliseconds(),
    val completed: Boolean = false): HasId<Long>