package edu.shanethompson.hackernewsreader

import com.lightningkite.kiteui.models.Angle
import com.lightningkite.kiteui.models.FontAndStyle
import com.lightningkite.kiteui.models.Theme
import com.lightningkite.kiteui.models.*
import com.lightningkite.kiteui.models.flat

val lkNavyBlue = "#0E2A32"
val lkYellow = "#FFB12E"
val white = Color(1f, 1f, 1f, 1f)

val todoTheme = Theme.flat("default", Angle(0.55f)).customize(
    "LK_TODO",
    font = FontAndStyle(),
    elevation = 4.dp,
    cornerRadii = CornerRadii.Constant(1.rem),
    spacing = 1.rem,
    padding = Edges(left = 1.rem, top = 1.rem, right = 1.rem, bottom = 1.rem),
    foreground = white,
    background = Color.fromHexString(lkNavyBlue),
)