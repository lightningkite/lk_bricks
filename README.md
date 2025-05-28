## Welcome To LK Bricks.

Lk Bricks is the home for any Lightning Kite bricks we wish to create and use.  What is a brick?  They are templates to be used with [mason cli](https://github.com/felangel/mason)

`mason cli` is a templating tool built with Dart, it is however very useful for any text based project.

### Getting Started

First you will need to install `dart`.  Information on how to do so can be found [here](https://dart.dev/get-dart).

Install `mason cli` globally using the command 

`dart pub global activate mason_cli`

Create a directory where you wish to add the desired brick, and run the command `mason init`, this will generate a `mason.yaml` file in the current directory.  to use the lk_kiteui brick you would modifiy the `mason.yaml` file adding the following to the `bricks:` block. 

```
lk_kiteui:
  git:
    url: https://github.com/lightningkite/lk_bricks.git
    path: lk_kiteui
```

Now run `mason get`, followed by `mason make lk_kiteui` it will prompt for some input, and then generate the brick in the current directory.  add the `-o` parameter to the `mason make` command to output your brick to another directory.

Once you have the project generated, open it with Intellij

## Running Your Project

### Web
Web should be ready to run right out of the box, just run the gradle task apps:viteRun, and then apps:viteCompileDev with the --continuous flag.  

If you get an exception such as java.lang.IllegalStateException: Symbol for <StandardLibraryClass> not found, for example it might have trouble finding Any or Number.
Then most likely local kotlin libraries have been corrupted, if you get this problem then go to ~/.m2/repository/org/  and remove the jetbrains folder and run again.

### Android

As long as your IntelliJ android dev environment is all configured and ready then Android should also run without any issues when first opening the project just select the apps Android build config, select an android device (Real or Emulator) and hit the run button.


### IOS

First thing you will need is to have your iOS dev environment all setup with cocoapods installed on your machine. you can find out more about cocoapods [here](https://guides.cocoapods.org/using/getting-started.html).

Open a terminal in the project directory and run `./gradlew apps:generateDummyFramework` this step might be one that "Shouldn't be necessary" but seems like it works best for a first time run.

Go into the ios directory via the command `cd apps/ios` and run `pod install`.  Once that is complete open the workspace at `<project_directory>/apps/ios/app.xcworkspace` with Xcode, run the project in a simulator and you should be good to go.

### Server Module

In IntelliJ go to File -> Project Structure  and select a Java 17 JDK.  Run Gradle Sync and then go into server/src/main/kotlin and run the main function contained within Main.kt.

### Learn More

To Learn more about mason visit [brickhub docs](https://docs.brickhub.dev/mason-make)