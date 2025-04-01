package edu.shanethompson.hackernewsreader.counter

import com.lightningkite.readable.Property

class CounterVM {
    val counterProperty = Property<CounterState>(CounterState(0))

    fun increment() {
        counterProperty.value = CounterState(counterProperty.value.count + 1)
    }

    fun decrement() {
        if (counterProperty.value.count - 1 >= 0) {
            counterProperty.value = CounterState(counterProperty.value.count - 1)
        }
    }
}

val counterVM by lazy {
    CounterVM()
}

data class CounterState(val count: Int)