import 'dart:io';
import 'package:mason/mason.dart';

void run(HookContext context) {
  context.vars.keys.forEach((key) {
    print("$key: ${context.vars[key]}");
  });
  final projectPath = context.vars['projectPath'];
  final String packageId = context.vars['package_id'];
  final packageDirectories = packageId.replaceAll(".", "/");
  final commonDirectory =
      Directory("$projectPath/apps/src/commonMain/kotlin/$packageDirectories");
  final androidDirectory =
      Directory("$projectPath/apps/src/androidMain/kotlin/$packageDirectories");
  final counterDir = Directory("${commonDirectory.path}/counter");
  counterDir.createSync(recursive: true);
  androidDirectory.createSync(recursive: true);
  final mainActivityFile = File("${androidDirectory.path}/MainActivity.kt");
  mainActivityFile.createSync(recursive: true);

  final appFiles = ["App.kt", "AppTheme.kt", "Styles.kt"]
      .map((fileName) => File("${commonDirectory.path}/$fileName"));
  final counterFiles = ["CounterView.kt", "CounterVM.kt"]
      .map((fileName) => File("${counterDir.path}/$fileName"));
  ;
  final fileContentsMap = fileContents(packageId);
  mainActivityFile.writeAsStringSync(fileContentsMap["MainActivity"]!);

  appFiles.forEach((file) {
    file.createSync(recursive: true);
    final contents = fileContentsMap[file.path.split("/").last];
    file.writeAsStringSync(contents!);
  });

  counterFiles.forEach((file) {
    file.createSync(recursive: true);
    final contents = fileContentsMap[file.path.split("/").last];
    file.writeAsStringSync(contents!);
  });
}

Map<String, String> fileContents(String packageId) {
  return {
    "App.kt": appContents(packageId),
    "AppTheme.kt": appThemeContents(packageId),
    "Styles.kt": stylesContents(packageId),
    "CounterView.kt": counterViewContents(packageId),
    "CounterVM.kt": counterVMContents(packageId),
    "MainActivity": mainActivityContents(packageId)
  };
}

String appContents(String packageId) {
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
import com.lightningkite.prepareModelsShared

val defaultTheme = todoTheme
val appTheme = Property(defaultTheme)

fun ViewWriter.app(navigator: PageNavigator, dialog: PageNavigator) {
    prepareModelsClient()
    prepareModelsShared()

    DefaultSerializersModule = ClientModule

    appNavFactory.value = ViewWriter::counterNav

    appNav(navigator, dialog) {
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
