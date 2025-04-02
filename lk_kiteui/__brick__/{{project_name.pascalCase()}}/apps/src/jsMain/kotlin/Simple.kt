package {{package_id}}

import com.lightningkite.kiteui.*
import com.lightningkite.kiteui.navigation.PageNavigator
import {{package_id}}.counter.AutoRoutes
import kotlinx.browser.window

fun main() {
    window.onerror = { a, b, c, d, e ->
        println("ON ERROR HANDLER $a $b $c $d $e")
        if (e is Exception) e.printStackTrace2()
    }
    root(appTheme.value) {
        app(PageNavigator { AutoRoutes }, PageNavigator { AutoRoutes })
    }
}
