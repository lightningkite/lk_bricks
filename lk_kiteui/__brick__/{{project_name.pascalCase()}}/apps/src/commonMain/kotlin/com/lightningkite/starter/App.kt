package com.lightningkite.starter

import com.lightningkite.kiteui.forms.prepareModelsClient
import com.lightningkite.kiteui.views.ViewWriter
import com.lightningkite.kiteui.models.*
import com.lightningkite.kiteui.navigation.DefaultSerializersModule
import com.lightningkite.kiteui.navigation.PageNavigator
import com.lightningkite.kiteui.navigation.pageNavigator
import com.lightningkite.kiteui.views.ViewModifiable
import com.lightningkite.kiteui.views.direct.col
import com.lightningkite.kiteui.views.expanding
import com.lightningkite.kiteui.views.l2.*
import com.lightningkite.readable.Property
import com.lightningkite.serialization.ClientModule
import com.lightningkite.starter.counter.CounterView
import com.lightningkite.prepareModelsShared

val defaultTheme = todoTheme
val appTheme = Property(defaultTheme)

fun ViewWriter.app(navigator: PageNavigator, dialog: PageNavigator) {
    prepareModelsClient()
    prepareModelsShared()

    DefaultSerializersModule = ClientModule

    appNavFactory.value = ViewWriter::tasksNav

    appNav(navigator, dialog) {
        appName = "Kite UI Starter"
        ::navItems {
            listOf(NavLink(title = { "Reactive Counter" }, icon = { Icon.home }) { { CounterView() } },)
        }

        ::exists {
            navigator.currentPage() !is UseFullScreen
        }
    }
}

fun ViewWriter.tasksNav(setup: AppNav.() -> Unit): ViewModifiable {
    return OuterSemantic.onNext - col {
        expanding - navigatorView(pageNavigator)
    }
}


interface UseFullScreen
