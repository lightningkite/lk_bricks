
import {{package_id}}.counter.CounterVM
import kotlinx.coroutines.runBlocking
import kotlin.test.Test
import kotlin.test.assertEquals

class TestCounterViewModel {

    @Test
    fun testIncrement() = runBlocking {
        val counterVM = CounterVM()
        assertEquals(expected = 0, actual = counterVM.counterState.state.raw.count)
        counterVM.increment()
        assertEquals(expected = 1, actual = counterVM.counterState.state.raw.count)
    }

    @Test
    fun testDecrement()  = runBlocking {
        val counterVM = CounterVM()
        repeat(4) { counterVM.increment() }
        assertEquals(expected = 4, actual = counterVM.counterState.state.raw.count)
        repeat(10) { counterVM.decrement() }
        assertEquals(expected = 0, actual = counterVM.counterState.state.raw.count)
    }
}