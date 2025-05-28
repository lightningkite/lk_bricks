Map<String, String> appsFileContents(String packageId) {
  return {
    "App.kt": appContent(packageId),
    "AppTheme.kt": appThemeContents(packageId),
    "Styles.kt": stylesContents(packageId),
    "CounterView.kt": counterViewContents(packageId),
    "CounterVM.kt": counterVMContents(packageId),
    "CheatSheet.kt": cheatSheetContents(packageId),
    "MainActivity": mainActivityContents(packageId),
  };
}

String iosAppFileContents(String packageId) {
  return '''
package $packageId

import com.lightningkite.kiteui.navigation.PageNavigator
import com.lightningkite.kiteui.views.direct.TextInput
import com.lightningkite.kiteui.views.setup
import $packageId.counter.AutoRoutes
import platform.UIKit.UIViewController


fun root(viewController: UIViewController) {
    viewController.setup(appTheme) { app(PageNavigator { AutoRoutes }, PageNavigator { AutoRoutes }) }
}
'''
      .trim();
}

String appContent(String packageId) {
  return '''
package $packageId

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
import $packageId.counter.CounterView
import $packageId.prepareModelsShared

val defaultTheme = todoTheme
val appTheme = Property(defaultTheme)

fun ViewWriter.app(navigator: PageNavigator, dialog: PageNavigator): ViewModifiable {
    prepareModelsClient()
    prepareModelsShared()

    DefaultSerializersModule = ClientModule

    appNavFactory.value = ViewWriter::counterNav

    return appNav(navigator, dialog) {
        appName = "Kite UI Starter"
        ::navItems {
            listOf(NavLink(title = { "Reactive Counter" }, icon = { Icon.home }) { { CounterView() } },)
        }

        ::exists {
            navigator.currentPage() !is UseFullPage
        }
    }
}

interface UseFullPage

fun ViewWriter.counterNav(setup: AppNav.() -> Unit): ViewModifiable {
    return OuterSemantic.onNext - col {
        expanding - navigatorView(pageNavigator)
    }
}
'''
      .trim();
}

String mainActivityContents(String packageId) {
  return '''
package $packageId

import android.os.Bundle
import com.lightningkite.kiteui.KiteUiActivity
import com.lightningkite.kiteui.Throwable_report
import com.lightningkite.kiteui.models.Theme
import com.lightningkite.kiteui.navigation.ScreenNavigator
import com.lightningkite.kiteui.printStackTrace2
import com.lightningkite.readable.ReactiveContext
import $packageId.counter.AutoRoutes
// import io.sentry.Sentry

class MainActivity : KiteUiActivity() {
    companion object {
        val main = ScreenNavigator { AutoRoutes }
        val dialog = ScreenNavigator { AutoRoutes }
    }

    override val theme: ReactiveContext.() -> Theme
        get() = { appTheme() }

    override val mainNavigator: ScreenNavigator get() = main

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        codeCacheDir.setReadOnly()

        // Throwable_report = { ex, ctx ->
        //     ex.printStackTrace2()
        //     Sentry.captureException(ex)
        // }

        with(viewWriter) {
            app(main, dialog)
        }
    }
}'''
      .trim();
}

String appThemeContents(String packageId) {
  return '''
package $packageId

import com.lightningkite.kiteui.models.Angle
import com.lightningkite.kiteui.models.FontAndStyle
import com.lightningkite.kiteui.models.Theme
import com.lightningkite.kiteui.models.*
import com.lightningkite.kiteui.models.flat

const val lkNavyBlue = "#0E2A32"
const val lkYellow = "#FFB12E"
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
'''
      .trim();
}

String stylesContents(String packageId) {
  return '''
package $packageId

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
  '''
      .trim();
}

String counterViewContents(String packageId) {
  return '''
package $packageId.counter

import $packageId.ButtonStarter
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
                        "The counters value is \$\{counterVM.counterState().count\}"
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
  '''
      .trim();
}

String counterVMContents(String packageId) {
  return '''
package $packageId.counter

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
  '''
      .trim();
}

cheatSheetContents(String packageId) {
  return '''
package comm.lightningkite.brickupdates.cheatsheet

import com.lightningkite.kiteui.Routable
import com.lightningkite.kiteui.locale.RenderSize
import com.lightningkite.kiteui.locale.renderToString
import com.lightningkite.kiteui.models.Align
import com.lightningkite.kiteui.models.Angle
import com.lightningkite.kiteui.models.Color
import com.lightningkite.kiteui.models.HoverSemantic
import com.lightningkite.kiteui.models.Icon
import com.lightningkite.kiteui.models.ImageRemote
import com.lightningkite.kiteui.models.ImportantSemantic
import com.lightningkite.kiteui.models.InsetSemantic
import com.lightningkite.kiteui.models.PopoverPreferredDirection
import com.lightningkite.kiteui.models.Semantic
import com.lightningkite.kiteui.models.SizeConstraints
import com.lightningkite.kiteui.models.Theme
import com.lightningkite.kiteui.models.ThemeAndBack
import com.lightningkite.kiteui.models.VideoRemote
import com.lightningkite.kiteui.models.dp
import com.lightningkite.kiteui.models.rem
import com.lightningkite.kiteui.navigation.Page
import com.lightningkite.kiteui.reactive.Action
import com.lightningkite.kiteui.views.ViewDsl
import com.lightningkite.kiteui.views.ViewModifiable
import com.lightningkite.kiteui.views.ViewWriter
import com.lightningkite.kiteui.views.affirmative
import com.lightningkite.kiteui.views.atBottom
import com.lightningkite.kiteui.views.atBottomEnd
import com.lightningkite.kiteui.views.atEnd
import com.lightningkite.kiteui.views.atStart
import com.lightningkite.kiteui.views.atTop
import com.lightningkite.kiteui.views.atTopEnd
import com.lightningkite.kiteui.views.atTopStart
import com.lightningkite.kiteui.views.bar
import com.lightningkite.kiteui.views.canvas.DrawingContext2D
import com.lightningkite.kiteui.views.canvas.appendArc
import com.lightningkite.kiteui.views.canvas.fill
import com.lightningkite.kiteui.views.canvas.fillPaint
import com.lightningkite.kiteui.views.canvas.strokePaint
import com.lightningkite.kiteui.views.card
import com.lightningkite.kiteui.views.centered
import com.lightningkite.kiteui.views.compact
import com.lightningkite.kiteui.views.critical
import com.lightningkite.kiteui.views.danger
import com.lightningkite.kiteui.views.direct.CanvasDelegate
import com.lightningkite.kiteui.views.direct.ContainingView
import com.lightningkite.kiteui.views.direct.PhoneNumberFormat
import com.lightningkite.kiteui.views.direct.RowOrCol
import com.lightningkite.kiteui.views.direct.TextView
import com.lightningkite.kiteui.views.direct.activityIndicator
import com.lightningkite.kiteui.views.direct.alert
import com.lightningkite.kiteui.views.direct.align
import com.lightningkite.kiteui.views.direct.button
import com.lightningkite.kiteui.views.direct.canvas
import com.lightningkite.kiteui.views.direct.checkbox
import com.lightningkite.kiteui.views.direct.circularProgress
import com.lightningkite.kiteui.views.direct.col
import com.lightningkite.kiteui.views.direct.confirmDanger
import com.lightningkite.kiteui.views.direct.dismissBackground
import com.lightningkite.kiteui.views.direct.externalLink
import com.lightningkite.kiteui.views.direct.formattedTextInput
import com.lightningkite.kiteui.views.direct.frame
import com.lightningkite.kiteui.views.direct.h1
import com.lightningkite.kiteui.views.direct.h2
import com.lightningkite.kiteui.views.direct.h3
import com.lightningkite.kiteui.views.direct.h4
import com.lightningkite.kiteui.views.direct.h5
import com.lightningkite.kiteui.views.direct.h6
import com.lightningkite.kiteui.views.direct.hintPopover
import com.lightningkite.kiteui.views.direct.icon
import com.lightningkite.kiteui.views.direct.image
import com.lightningkite.kiteui.views.direct.label
import com.lightningkite.kiteui.views.direct.link
import com.lightningkite.kiteui.views.direct.localDateField
import com.lightningkite.kiteui.views.direct.localDateTimeField
import com.lightningkite.kiteui.views.direct.localTimeField
import com.lightningkite.kiteui.views.direct.menuButton
import com.lightningkite.kiteui.views.direct.numberInput
import com.lightningkite.kiteui.views.direct.onClick
import com.lightningkite.kiteui.views.direct.padded
import com.lightningkite.kiteui.views.direct.phoneNumberInput
import com.lightningkite.kiteui.views.direct.progressBar
import com.lightningkite.kiteui.views.direct.radioButton
import com.lightningkite.kiteui.views.direct.recyclerView
import com.lightningkite.kiteui.views.direct.row
import com.lightningkite.kiteui.views.direct.rowCollapsingToColumn
import com.lightningkite.kiteui.views.direct.scrolling
import com.lightningkite.kiteui.views.direct.scrollingBoth
import com.lightningkite.kiteui.views.direct.scrollingHorizontally
import com.lightningkite.kiteui.views.direct.select
import com.lightningkite.kiteui.views.direct.separator
import com.lightningkite.kiteui.views.direct.shownWhen
import com.lightningkite.kiteui.views.direct.sizeConstraints
import com.lightningkite.kiteui.views.direct.sizedBox
import com.lightningkite.kiteui.views.direct.space
import com.lightningkite.kiteui.views.direct.subtext
import com.lightningkite.kiteui.views.direct.switch
import com.lightningkite.kiteui.views.direct.text
import com.lightningkite.kiteui.views.direct.textArea
import com.lightningkite.kiteui.views.direct.textInput
import com.lightningkite.kiteui.views.direct.textPopover
import com.lightningkite.kiteui.views.direct.toggleButton
import com.lightningkite.kiteui.views.direct.unpadded
import com.lightningkite.kiteui.views.direct.video
import com.lightningkite.kiteui.views.direct.weight
import com.lightningkite.kiteui.views.dynamicTheme
import com.lightningkite.kiteui.views.emphasized
import com.lightningkite.kiteui.views.expanding
import com.lightningkite.kiteui.views.fieldTheme
import com.lightningkite.kiteui.views.forEach
import com.lightningkite.kiteui.views.important
import com.lightningkite.kiteui.views.l2.RecyclerViewPlacerVerticalGrid
import com.lightningkite.kiteui.views.l2.children
import com.lightningkite.kiteui.views.l2.field
import com.lightningkite.kiteui.views.l2.icon
import com.lightningkite.kiteui.views.l2.titledSection
import com.lightningkite.kiteui.views.l2.toast
import com.lightningkite.kiteui.views.nav
import com.lightningkite.kiteui.views.warning
import com.lightningkite.readable.Constant
import com.lightningkite.readable.Property
import com.lightningkite.readable.contains
import com.lightningkite.readable.equalTo
import com.lightningkite.readable.reactive
import com.lightningkite.readable.shared
import comm.lightningkite.brickupdates.counter.CounterView
import kotlinx.coroutines.delay
import kotlinx.datetime.LocalDate
import kotlinx.datetime.LocalDateTime
import kotlinx.datetime.LocalTime
import kotlin.contracts.ExperimentalContracts
import kotlin.contracts.InvocationKind
import kotlin.contracts.contract
import kotlin.math.PI
import kotlin.time.Duration.Companion.seconds
import kotlin.uuid.ExperimentalUuidApi

@Routable("docs/cheat-sheet")
object CheatSheet : DocPage {
    override val covers: List<String>
        get() = listOf("Cheat Sheet")

    data class ExampleEntry(
        val name: String,
        val tags: Set<String> = setOf()
    )

    data object LinkSemantic : Semantic("link") {
        override fun default(theme: Theme): ThemeAndBack = theme.withoutBack(
            derivations = mapOf(
                HoverSemantic to {
                    it.withoutBack(
                        font = it.font.copy(underline = true)
                    )
                }
            )
        )
    }

    val known = HashSet<ExampleEntry>()
    val jump = Property<ExampleEntry?>(null)
    fun ViewWriter.example(
        name: String,
        code: String,
        description: String,
        references: Set<ExampleEntry> = emptySet(),
        result: RowOrCol.() -> Unit
    ): ViewModifiable {
        val e = ExampleEntry(name)
        known += e
        return card - rowCollapsingToColumn(79.rem) {
            dynamicTheme {
                if (jump() == e) ImportantSemantic
                else null
            }
            reactive {
                if (jump() == e) scrollIntoView(null, Align.Center, true)
            }
            weight(1f) - col {
                gap = 0.25.rem
                text(name)
                subtext { setBasicHtmlContent(description) }

                if (references.isNotEmpty()) {
                    space()
                    label {
                        content = "See Also:"
                        for (reference in references) {
                            LinkSemantic.onNext - button {
                                subtext("- \${reference.name}")
                                onClick {
                                    jump.value = reference
                                    delay(1000)
                                    jump.value = null
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    fun ViewWriter.itemHeader(text: String): ViewModifiable = important - card - h3(text)

    @OptIn(ExperimentalUuidApi::class)
    override fun ViewWriter.render(): ViewModifiable = frame {
        article {
            titledSection("Cheat Sheet") {

                h3("Condensed cheat sheet, mostly here to provide extra context for AI.  Visit the following link for more complete and readable cheat sheet.")
                externalLink {
                    text("KiteUI Docs Cheat Sheet")
                    to = "https://kiteui.cs.lightningkite.com/docs/available-views"
                    newTab = true
                }

                titledSection("Containers") {
                    itemHeader("row")
                    row {
                        card - text("A")
                        weight(1f) - card - text("B")
                        card - text("C")
                    }
                    itemHeader("column")
                    sizeConstraints(height = 10.rem) - col {
                        card - text("A")
                        weight(1f) - card - text("B")
                        card - text("C")
                    }
                    itemHeader("rowCollapsingToColumn")
                    rowCollapsingToColumn(70.rem) {
                        card - text("A")
                        weight(1f) - card - text("B")
                        card - text("C")
                    }

                    itemHeader("frame")
                    sizeConstraints(height = 10.rem) - card - frame {
                        atTopStart - text("A")
                        centered - text("B")
                        atBottomEnd - text("C")
                    }
                }

                titledSection("Display Only") {
                    itemHeader("activityIndicator")
                    activityIndicator()

                    itemHeader("progressBar")
                    progressBar { ratio = 0.4f }
                    progressBar { ratio = 0.6f }
                    progressBar { ratio = 0.8f }
                    progressBar { ratio = 1f }

                    itemHeader("circularProgress")
                    row {
                        sizeConstraints(width = 3.rem) - circularProgress { ratio = 0.4f }
                        sizeConstraints(width = 3.rem) - circularProgress { ratio = 0.6f }
                        sizeConstraints(width = 3.rem) - circularProgress { ratio = 0.8f }
                        sizeConstraints(width = 3.rem) - circularProgress { ratio = 1f }
                    }

                    itemHeader("icon")
                    icon(Icon.help, "Help")
                    icon {
                        source = Icon.notification
                        description = "Notification"
                    }

                    itemHeader("image")
                    sizeConstraints(height = 8.rem) - image {
                        source = ImageRemote(url = "https://picsum.photos/200/200")
                    }

                    h3("video")
                    sizeConstraints(height = 10.rem) - video {
                        source = VideoRemote("https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
                        showControls = true
                    }

                    itemHeader("separator")
                    text("ONE")
                    separator {}
                    text("TWO")

                    itemHeader("space")
                    text("ONE")
                    space()
                    text("TWO")
                    text("THREE")

                    itemHeader("text")
                    text("Hello world!")
                    text { content = "Also, hello world." }
                    text {
                        setBasicHtmlContent("Supported tags can be found &lt;a href=\"https://stackoverflow.com/questions/9754076/which-html-tags-are-supported-by-android-textview\">here</a>.")
                    }

                    itemHeader("subtext")
                    subtext("Hello world!")
                    subtext { content = "Also, hello world." }

                    itemHeader("Headers h1 - h6")
                    h1("Header 1")
                    h2("Header 2")
                    h3("Header 3")
                    h4("Header 4")
                    h5("Header 5")
                    h6("Header 6")
                }
                titledSection("Interactive Elements") {
                    itemHeader("button")
                    button {
                        text("A dangerous button")
                        action = Action("Explode") {
                            delay(1.seconds)
                            toast("KABOOM!!!")
                        }
                    }

                    itemHeader("menuButton")
                    menuButton {
                        requireClick = true
                        preferredDirection = PopoverPreferredDirection.aboveCenter

                        text("Click me")
                        opensMenu {
                            col {
                                centered - text("Menu")
                                button { text("I am a button") }
                            }
                        }
                    }
                    itemHeader("link")
                    link {
                        text { content = "Home page" }
                        to = { CounterView() }
                        newTab = true
                    }
                    itemHeader("externalLink")
                    externalLink {
                        text { content = "Link to Stack Overflow" }
                        to = "https://stackoverflow.com/questions/9754076/which-html-tags-are-supported-by-android-textview"
                        newTab = true
                    }
                }
                titledSection("Form Controls") {
                    itemHeader("checkbox")
                    col {
                        val selected = Property<Set<String>>(setOf("Ketchup"))
                        for(option in listOf("Ketchup", "Mustard", "Mayo")) {
                            row {
                                centered - checkbox {
                                    checked bind selected.contains(option)
                                }
                                centered - expanding - text(option)
                            }
                        }
                        centered - text {
                            ::content { "Include " + selected().joinToString(", ") }
                        }
                    }
                    itemHeader("radioButton")
                    col {
                        val selected = Property<String>("Chicken")
                        centered - text("Pick one")
                        for(option in listOf("Chicken", "Steak", "Shrimp")) {
                            row {
                                centered - radioButton {
                                    checked bind selected.equalTo(option)
                                }
                                centered - expanding - text(option)
                            }
                        }
                        centered - text {
                            ::content { "Meat selected: " + selected() }
                        }
                    }

                    itemHeader("toggleButton")
                    val toggled = Property<Boolean>(false)
                    toggleButton {
                        centered - text {
                            ::content { if (toggled()) "Toggled ON" else "Toggled OFF" }
                        }
                        checked bind toggled
                    }

                    itemHeader("field")
                    val name = Property("")
                    field(label = "First Name") {
                        textInput { content bind name }
                    }
                    text { ::content { "Name is \${name()}" } }

                    itemHeader("localDateField")
                    val date = Property<LocalDate?>(null)
                    localDateField {
                        range = LocalDate(1970, 1, 1)..LocalDate(year = 1971, 12, 31)
                        content bind date
                    }
                    text { ::content { "Date Selected: \${date()?.renderToString(RenderSize.Full) ?: "N/A"}" } }

                    itemHeader("localTimeField")
                    val time = Property<LocalTime?>(null)
                    localTimeField {
                        content bind time
                    }

                    itemHeader("localDateTimeField")
                    text { ::content { "Time Selected: \${time()?.renderToString(RenderSize.Full) ?: "N/A"}" } }
                    val dateTime = Property<LocalDateTime?>(null)
                    localDateTimeField {
                        content bind dateTime
                    }
                    text { ::content { "Date Selected: \${dateTime()?.renderToString(RenderSize.Full) ?: "N/A"}" } }

                    itemHeader("select")
                    text { content = "LOTR Characters" }
                    val characters = Constant(listOf("Bilbo", "Frodo", "Gandalf", "Thorin"))
                    val valueChanged = Property(characters.value.first())
                    select {
                        bind(edits = valueChanged, data = characters) { character -> character }
                    }
                    text { ::content { "Character Selected \${valueChanged()}" } }

                    itemHeader("switch")
                    val switchValue = Property(false)
                    row {
                        expanding - text("My switch")
                        switch { checked bind switchValue } 
                    }
                    text { ::content { "Switch is \${ if(switchValue()) "ON" else "OFF" }" } }

                    h3 ("textArea")
                    val longText = Property("")
                    sizeConstraints(height = 120.dp) - scrolling - textArea { 
                        content bind longText
                        hint = "Some hint"
                    }
                    sizeConstraints(height = 120.dp) - scrolling - text { ::content { "Entered Input: \${longText()}" } }

                    itemHeader("textInput")
                    val inputText = Property("")
                    textInput { 
                        content bind inputText
                        hint = "Some hint"
                    }
                    text { ::content { "Entered Input: \${inputText()}" } }

                    itemHeader("numberInput")
                    val number = Property<Double?>(null)
                    numberInput {
                        content bind number
                        hint = "A number"
                    }
                    text { ::content { "Entered Number: \${number()}" } }

                    itemHeader("phoneNumberInput")
                    val phoneNumber = Property<String>("")
                    field("Phone Number") {
                        phoneNumberInput {
                            format = PhoneNumberFormat.USA

                            content bind phoneNumber
                            hint = "A phone number"
                        }
                    }
                    text { ::content { "Entered Phone Number: \${phoneNumber()}" } }

                }

                titledSection("View Modifiers") {
                    itemHeader("scrolling")
                    sizeConstraints(height = 100.dp) - scrolling - col {
                        for(it in 0..10) {
                            text { content = "Element \$it" }
                        }
                    }

                    itemHeader("scrollingHorizontally")
                    col {
                        scrollingHorizontally - row {
                            for(it in 0..10) {
                                text { content = "Element \$it" }
                            }
                        }
                    }

                    itemHeader("scrollingBoth")
                    sizeConstraints(height = 150.dp) - scrollingBoth {} - col {
                        for(y in 0..10) {
                            row {
                                for(x in 0..10) {
                                    text { content = "(\$x, \$y)" }
                                }
                            }
                        }
                    }

                    itemHeader("hintPopover")
                    hintPopover {
                        row {
                            icon(Icon.help, "")
                            text("Some rich information")
                        }
                    } - card - text("Hover over me!")

                    itemHeader("textPopover")
                    textPopover("Some info!") - card - text("Hover over me!")

                    itemHeader("card")
                    row {
                        weight(1f) - card - text("A")
                        weight(2f) - card - text("B")
                        card - text("C")
                    }
                    row {
                        expanding - card - text("A")
                        card - text("B")
                    }

                    itemHeader("centered")
                    sizeConstraints(height = 8.rem) - card - row {
                        card - expanding - text("I am not centered")
                        centered - card - expanding - text("I am centered")
                    }
                    card - col {
                        card - text("I am not centered")
                        centered - card - text("I am centered")
                    }

                    itemHeader("atTop, centered, atBottom, align")
                    sizeConstraints(height = 7.rem) - card - row {
                        atTop - card - text("T")
                        centered - card - text("C")
                        atBottom - card - text("B")
                        align(Align.Stretch, Align.Stretch) - card - text("S")
                    }

                    itemHeader("atStart, centered, atEnd, align")
                    card - col {
                        atStart - card - text("Start")
                        centered - card - text("Centered")
                        atEnd - card - text("End")
                        align(Align.Stretch, Align.Stretch) - card - text("Stretch")
                    }

                    itemHeader("atTopStart, align, atEnd")
                    sizeConstraints(height = 12.rem) - card - frame {
                        atTopStart - card - text("Top Start")
                        align(Align.Stretch, Align.Center) - card - text("Stretch/Center")
                        atEnd - card - text("End")
                    }

                    itemHeader("sizeConstraints")
                    sizeConstraints(height = 3.rem) - card - text("Sized")
                    atStart - sizeConstraints(width = 5.rem) - card - text("Very Short")
                    atStart - sizeConstraints(width = 200.rem) - card - text("Try for 200")

                    itemHeader("padded")
                    card - text("Naturally has padding")
                    padded - text("Has virtual padding")

                    itemHeader("unpadded")
                    text("Naturally no padding")
                    unpadded - card - text("Forced no padding")

                    itemHeader("compact")
                    card - text("Regular card")
                    compact - card - text("Compact card")

                    itemHeader("shownWhen")
                    val visible = Property(true)
                    row {
                        expanding - text("Visible")
                        switch { checked bind visible }
                    }
                    shownWhen { visible() } - text("Only visible when on")

                    itemHeader("Theme Modifiers")
                    text("None")
                    card - text("card")
                    fieldTheme - text("fieldTheme")
                    bar - text("bar")
                    nav - text("nav")
                    important - text("important")
                    critical - text("critical")
                    warning - text("warning")
                    danger - text("danger")
                    affirmative - text("affirmative")
                    emphasized - text("emphasized")
                    InsetSemantic.onNext - text("InsetSemantic.onNext")
                }

                titledSection("Advanced Components") {
                    itemHeader("canvas")
                    canvas {
                        delegate = object : CanvasDelegate() {
                            override fun draw(context: DrawingContext2D) = with(context) {
                                super.draw(context)
                                context.fillPaint = Color.white
                                context.strokePaint = Color.white
                                repeat(5) { i ->
                                    repeat(4) { j ->
                                        context.beginPath()
                                        val x = 25.0 + j * 50.0 // x coordinate
                                        val y = 25.0 + i * 50.0 // y coordinate
                                        val radius = 20.0 // Arc radius
                                        val startAngle = Angle(0.0) // Starting point on circle
                                        val endAngle = Angle(PI + (PI * j) / 2) // End point on circle
                                        val counterclockwise = i % 2 != 0 // clockwise or counterclockwise

                                        context.appendArc(x, y, radius, startAngle, endAngle, counterclockwise)

                                        if (i > 1) {
                                            context.fill()
                                        } else {
                                            context.stroke()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    itemHeader("dismissBackground")
                    dismissBackground {
                        centered - card - text("I'm like a dialog")
                        onClick {
                            println("Put logic to dismiss here")
                        }
                    }

                    itemHeader("recyclerView")
                    expanding - recyclerView {
                        //Determines the layout of the data.
                        placer = RecyclerViewPlacerVerticalGrid(1)

                        children(Constant((1..10000).toList()), id = { it }, render = { item ->
                            card - text { ::content { "Item \${item()}" } }
                        })
                    }

                    itemHeader("formattedTextInput")
                    val input = Property("")
                    field("Enter Hex Color") {
                        formattedTextInput {
                            content bind input

                            // Hexadecimal format
                            val hexCharacters = ('0'..'9') + ('a'..'f') + ('A'..'F')
                            format(
                                isRawData = { it in hexCharacters.toSet() },
                                formatter = { if (it.isBlank()) "" else "#\${it.take(6)}" }
                            )
                        }
                    }
                    text {
                        // theme code not shown
                        ::content { "Filtered input: \${input()}" }
                    }
                }
                titledSection("Dialogs") {
                    itemHeader("toast")
                    button {
                        text("Click Me")
                        action = Action("Show toast") {
                            toast("I am a toast!")
                        }
                    }

                    itemHeader("confirmDanger")
                    button {
                        text("Do a dangerous thing")
                        onClick {
                            confirmDanger(
                                "Danger",
                                "Are you sure you wish to do this dangerous thing?"
                            ) {
                                println("Did a dangerous thing!")
                            }
                        }
                    }
                    itemHeader("alert")
                    button {
                        text("Alert Me")
                        onClick {
                            alert("Alert", "This is an alert")
                        }
                    }
                }
                titledSection("Other (not yet categorized)") {
                    itemHeader("forEach")
                    val fruits = listOf("Apples", "Oranges", "Plums", "Bananas", "Cherries")

                    padded - col {
                        forEach(shared { fruits }) { fruit ->
                            text("* \$fruit")
                        }
                    }
                }
            }
        }
        atTopEnd - col {
            fieldTheme - row {
                textInput {
                    hint = "Quick jump..."
                    action = Action("Quick jump") {
                        val match = known.filter() { it.name.contains(content.value, ignoreCase = true) }
                            .minByOrNull { it.name.length }
                            ?: known.filter { it.tags.any { it.contains(content.value, ignoreCase = true) } }
                                .minByOrNull { it.name.length }
                        if (match != null) {
                            jump.value = match
                            delay(1.seconds)
                            jump.value = null
                        }
                    }
                }
            }
        }
    }
}

@OptIn(ExperimentalContracts::class)
@ViewDsl
inline fun ViewWriter.code(setup: TextView.() -> Unit = {}): TextView {
    contract { callsInPlace(setup, InvocationKind.EXACTLY_ONCE) }
    return write(TextView(context) , setup)
//    return write(Code(context) , setup)
}

fun ViewWriter.example(
    codeText: String,
    action: ViewWriter.()->ViewModifiable
): ViewModifiable {
    return card - rowCollapsingToColumn(40.rem) {
        expanding - scrollingHorizontally
        separator()
        expanding - action()
    }
}

fun ViewWriter.article(
    setup: ContainingView.()->Unit
): ViewModifiable = scrolling - frame {
    align(Align.Center, Align.Stretch) - sizedBox(SizeConstraints(width = 80.rem)) - col {
        setup()
    }
}


typealias StringID = String

private data class SetForeground(val color: Color) : Semantic("frgrnd-\${color.toInt()}") {
    override fun default(theme: Theme): ThemeAndBack = theme.withBack(
        foreground = color,
        background = if (color.perceivedBrightness > 0.5f) Color.black else Color.gray(0.9f)
    )
}

interface DocPage: Page {
    val covers: List<String>
}
'''
      .trim();
}
