# {{project_name}}

## Get Started

### Web

Web should be ready to run right out of the box, just run the gradle task apps:viteRun, and then apps:viteCompileDev with the --continuous flag.

### Android

Android should also run without any issues when first opening the project, select the apps Android build config, select an android device (Real or Emulator) and hit the run button.


### IOS

The first thing you will need is to have your iOS dev environment setup with cocoapods installed on your machine. You can find out more about cocoapods [here](https://guides.cocoapods.org/using/getting-started.html).

Open a terminal in the project directory and run `./gradlew apps:generateDummyFramework`Go into the ios directory via the command `cd apps/ios` and run `pod install`.  
Once that is complete open the workspace at `<project_directory>/apps/ios/app.xcworkspace` with Xcode, run the project in a simulator, and you should be good to go.

### Server Module

In IntelliJ go to File -> Project Structure and select a Java 17 JDK.  Run Gradle Sync and then go into server/src/main/kotlin and run the main function contained within Main.kt.

### Common Issues

If you get an exception such as java.lang.IllegalStateException: Symbol for <StandardLibraryClass> not found, for example, it might have trouble finding Any or Number.
Then most likely local kotlin libraries have been corrupted, if you get this problem, then go to ~/.m2/repository/org/ and remove the jetbrains folder and run again.