package com.lightningkite.starter.counter

import com.lightningkite.starter.ButtonStarter
import com.lightningkite.kiteui.Routable
import com.lightningkite.kiteui.models.Icon
import com.lightningkite.kiteui.models.dp
import com.lightningkite.kiteui.navigation.Page
import com.lightningkite.kiteui.reactive.Action
import com.lightningkite.kiteui.views.ViewModifiable
import com.lightningkite.kiteui.views.ViewWriter
import com.lightningkite.kiteui.views.centered
import com.lightningkite.kiteui.views.direct.button
import com.lightningkite.kiteui.views.direct.col
import com.lightningkite.kiteui.views.direct.frame
import com.lightningkite.kiteui.views.direct.h3
import com.lightningkite.kiteui.views.direct.icon
import com.lightningkite.kiteui.views.direct.row
import com.lightningkite.kiteui.views.direct.sizeConstraints
import com.lightningkite.kiteui.views.direct.text
import kotlin.time.Duration.Companion.milliseconds

@Routable("/")
class CounterView : Page {
    val counterVM = CounterVM()
    override fun ViewWriter.render(): ViewModifiable {
        return frame {
            centered - col {
                centered - h3 {
                    ::content {
                        "The counters value is ${counterVM.counterState().count}"
                    }
                }

                row {
                    sizeConstraints(width = 160.dp) - ButtonStarter.onNext - button {
                        row {
                            text { content = "Decrement" }
                            icon { source = Icon.remove }
                            action = Action(
                                title = "Decrement -",
                                action = counterVM::decrement,
                                frequencyCap = 0.milliseconds)
                        }
                    }

                    sizeConstraints(width = 160.dp) - ButtonStarter.onNext - button {
                        row {
                            text { content = "Increment" }
                            icon { source = Icon.add }
                            action = Action(
                                title = "Increment",
                                icon = Icon.add,
                                action = counterVM::increment,
                                frequencyCap = 0.milliseconds)
                        }
                    }
                }
            }
        }
    }
}