package com.lightningkite.starter.counter

import com.lightningkite.readable.Property
import com.lightningkite.readable.Readable

class CounterVM {
    private val counterProperty = Property<CounterState>(CounterState(0))
    val counterState: Readable<CounterState> = counterProperty

    fun increment() {
        counterProperty.value = CounterState(counterProperty.value.count + 1)
    }

    fun decrement() {
        if (counterProperty.value.count - 1 >= 0) {
            counterProperty.value = CounterState(counterProperty.value.count - 1)
        }
    }
}

data class CounterState(val count: Int)