package edu.shanethompson.hackernewsreader.tasks
import com.lightningkite.readable.Property
import com.lightningkite.readable.Readable
import com.lightningkite.readable.invoke
import com.lightningkite.readable.sharedSuspending
import edu.shanethompson.hackernewsreader.domain.TodoTask
import edu.shanethompson.hackernewsreader.domain.TasksRepository

class TasksViewModel(private val repo: TasksRepository) {

    private val filter = Property(false)
    private val refreshList = Property(true)

    val tasks: Readable<List<TaskDisplay>> = sharedSuspending {
        refreshList()
        repo.get().map { TaskDisplay(it) }
    }

    fun toggleFilter() {
        filter.value = !filter.value
    }

    suspend fun taskDetail(id: Long): Readable<TaskDisplay> = sharedSuspending {
        TaskDisplay(repo.detail(id))
    }

    suspend fun addTask(title: String, description: String) {
        repo.create(TodoTask(id = tasks.state.raw.size + 1L, title = title, description = description))
        refreshList.value = !refreshList.value
    }

    suspend fun editTask(id: Long, title: String, description: String) {
        val modifiedTask = tasks.state.raw.map { it.task }.firstOrNull { it.id == id }
            ?.copy(title = title, description = description ) ?: throw RuntimeException("Task with $id ")
        repo.update(id, modifiedTask)
        refreshList()
    }

    suspend fun toggleComplete(id: Long) {
        println("TOGGLE COMPLETE FOR $id")
        repo.toggleCompleted(id)
        refreshList()
    }
}
