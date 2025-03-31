import com.lightningkite.uuid
import edu.shanethompson.hackernewsreader.domain.MockTasksRepo
import edu.shanethompson.hackernewsreader.domain.TodoTask
import edu.shanethompson.hackernewsreader.tasks.TasksViewModel
import junit.framework.TestCase.assertEquals
import kotlinx.coroutines.runBlocking
import kotlin.test.Test

class TestTaskViewModel {

    @Test
    fun testTasksUpdatedOnAdd() = runBlocking {
        val repo = MockTasksRepo()
        val tasksViewModel = TasksViewModel(repo)
        assertEquals(1, repo.get().size)
        Unit
    }
}