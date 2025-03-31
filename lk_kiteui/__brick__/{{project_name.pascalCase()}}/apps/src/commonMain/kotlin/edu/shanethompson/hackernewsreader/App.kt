package edu.shanethompson.hackernewsreader

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
import edu.shanethompson.hackernewsreader.domain.MockTasksRepo
import edu.shanethompson.hackernewsreader.tasks.TasksView
import edu.shanethompson.hackernewsreader.tasks.TasksViewModel

val defaultTheme = todoTheme
val appTheme = Property(defaultTheme)

val tasksVM = TasksViewModel(MockTasksRepo())

fun ViewWriter.app(navigator: PageNavigator, dialog: PageNavigator) {
    prepareModelsClient()
    com.lightningkite.prepareModelsShared()

    DefaultSerializersModule = ClientModule

    appNavFactory.value = ViewWriter::tasksNav

    appNav(navigator, dialog) {
        appName = "Hacker News Reader"
        ::navItems {
            listOf(NavLink(title = { "Tasks" }, icon = { Icon.home }) { { TasksView() } },)
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
