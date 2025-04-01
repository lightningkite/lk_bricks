package edu.shanethompson.hackernewsreader

import com.lightningkite.kiteui.models.Color
import com.lightningkite.kiteui.models.Semantic
import com.lightningkite.kiteui.models.Theme
import com.lightningkite.kiteui.models.ThemeAndBack
import com.lightningkite.kiteui.models.dp

data object ButtonStarter : Semantic("Button") {
    override fun default(theme: Theme): ThemeAndBack {
        return theme.withBack(outline = Color.fromHexString(lkYellow), outlineWidth = 2.dp)
    }
}