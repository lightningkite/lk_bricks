package edu.shanethompson.hackernewsreader.tasks

import edu.shanethompson.hackernewsreader.domain.TodoTask
import kotlinx.datetime.Instant
import kotlinx.datetime.LocalDate
import kotlinx.datetime.format
import kotlinx.datetime.format.DateTimeComponents

val customFormat = DateTimeComponents.Format {
    date(LocalDate.Formats.ISO)
}

data class TaskDisplay(val task: TodoTask) {
    val createdString: String = Instant.fromEpochMilliseconds(task.created)
        .format(customFormat)
}
