package com.lightningkite.template

import com.lightningkite.kiteui.QueryParameter
import com.lightningkite.kiteui.Routable
import com.lightningkite.kiteui.models.Icon
import com.lightningkite.kiteui.navigation.Page
import com.lightningkite.kiteui.reactive.Action
import com.lightningkite.kiteui.reactive.Property
import com.lightningkite.kiteui.reactive.Readable
import com.lightningkite.kiteui.reactive.invoke
import com.lightningkite.kiteui.reactive.reactive
import com.lightningkite.kiteui.views.ViewModifiable
import com.lightningkite.kiteui.views.ViewWriter
import com.lightningkite.kiteui.views.centered
import com.lightningkite.kiteui.views.direct.button
import com.lightningkite.kiteui.views.direct.col
import com.lightningkite.kiteui.views.direct.icon
import com.lightningkite.kiteui.views.direct.stack
import com.lightningkite.kiteui.views.direct.text

object CounterState {
    private val counterProperty = Property<Int>(0)
    val counterState: Readable<Int> = counterProperty

    val increment = Action("Increment", Icon.add, frequencyCap = null) { counterProperty.value++ }
}

@Routable("")
class CounterPage : Page {

    override fun ViewWriter.render2(): ViewModifiable {
        return stack {
            centered - col {
                text {
                    ::content { "${CounterState.counterState()} Button clicks" }
                }

                centered - button {
                    icon {
                        source = Icon.add
                        description = "Add Button"
                    }
                    action = CounterState.increment
                }
            }
        }
    }
}