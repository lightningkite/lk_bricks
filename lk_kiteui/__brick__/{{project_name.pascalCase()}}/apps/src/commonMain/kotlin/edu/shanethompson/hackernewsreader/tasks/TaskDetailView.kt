package edu.shanethompson.hackernewsreader.tasks

import com.lightningkite.kiteui.Routable
import com.lightningkite.kiteui.navigation.Page
import com.lightningkite.kiteui.views.ViewModifiable
import com.lightningkite.kiteui.views.ViewWriter
import com.lightningkite.kiteui.views.direct.col

@Routable("story/{id}")
class TaskDetailView(val id: Long) : Page {

    override fun ViewWriter.render(): ViewModifiable {
        return col {}
    }
}