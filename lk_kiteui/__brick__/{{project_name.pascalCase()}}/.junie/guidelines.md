# {{project_name}} - Developer Guidelines

This document provides essential information for developers working on the LkServer / KiteUI projects.

## Project Overview

{{project_name}} is a Kotlin Multiplatform project that provides time tracking functionality. It consists of client applications and server components built with Lightning Server and KiteUI.

## Tech Stack

- **KiteUI**: A Kotlin Multiplatform UI Library for build cross-platform UIs
- **Lightning Server**: A Kotlin server framework for building backend services
- **Lightning Server / KiteUI**: A KiteUI client for Lightning Server
- **Readable**: A state management library based on SolidJS
  - Located at `libs-for-junie/readable`


## Project Structure

The project is organized into several modules:

- **apps**: Client applications (Android, iOS, JS)
  - `src/androidMain`: Android-specific code
  - `src/iosMain`: iOS-specific code
  - `src/jsMain`: Web client code
  - `src/commonMain`: Shared client code
  - `src/commonTest`: Tests for shared client code
- **server**: Core server logic
  - `src/main`: Server implementation
  - `src/test`: Server tests
- **shared**: Code shared between client and server
  - `src/commonMain`: Shared code
  - `src/commonTest`: Tests for shared code

## Building and Running
  - Build the project: `./gradlew build`
  - Run tests: `./gradlew test`
  - Run Android app: `./gradlew :apps:installDebug`
  - Run web client: `./gradlew :apps:viteRun`
  - Reload web client on change: `./gradlew :apps:viteCompileDebug --continuous`
  - Run server locally: `./gradlew :server-ktor:run`

### Prerequisites
- JDK 17 or higher
- Gradle 8.x or higher
- For Android: Android SDK
- For iOS: Xcode and CocoaPods

## Testing Guidelines

The project uses different testing approaches for different modules:

- **Shared code**: Uses Kotlin's built-in testing framework (`kotlin.test`)
  - Tests are located in `shared/src/commonTest`
  - Run with `./gradlew :shared:test`

- **Server code**: Uses JUnit for testing with in-memory database
  - Tests are located in `server/src/test`
  - Base test class: `TimeTrackerTest` provides common setup
  - Run with `./gradlew :server:test`

## Best Practices

1. **Code Organization**
   - Keep platform-specific code in appropriate source sets
   - Share as much code as possible in `commonMain`
   - Use `expect/actual` for platform-specific implementations
   - Data entities should be contained within the shared module.

2. **Testing**
   - Write tests for all business logic
   - Use the appropriate testing framework for each module
   - For server tests, create a class such as `ServerTest` for database setup

3. **Development Workflow**
   - Run tests before committing changes
   - Use feature branches for new features
   - Follow Kotlin coding conventions

4. **Dependency Management**
   - Add new dependencies to the appropriate module's build.gradle.kts file
   - Prefer using the version catalog in the root build.gradle.kts

## Libraries
  - KiteUI, UI Library
  - LightningServer server library.

## KiteUI
  - View Containers
    - col, column aligns children vertically.
    - row, aligns children horizontally.
    - frame, children positioned absolutely.
  - View Modifiers, can modify any view but generally used on containers
    - scrolling, adds vertical scrolling to the view.
    - scrollingHorizontally, adds horizontal scrolling to the view.
    - scrollingBoth, adds vertical and horizontal scrolling to the view.
    - hintPopover, shows a hint view on hover.
    - textPopover, shows a hint view with text only on hover.
    - weight, indicates this view should take a ratio of the remaining space.
    - expanding, a shortcut for weight(1f). 
    - centered, centers within a container.
    - align, controls alignment within a container.
    - sizeConstraints, Sets requirements on the size of the view. 
    - padded, Forces a view to have padding.
    - unpadded, Forces a view to have no padding. 
    - compact, Reduces the padding on a view.
    - shownWhen, Shows or hides a view dynamically.  Animated.
    - theme-oriented modifiers.  change the look of something.  The exact look depends on the theme.
      - card
      - fieldTheme
      - bar
      - nav
      - important
      - critical
      - warning
      - danger
      - affirmative
      - emphasized
      - InsetSemantic
    - dismissBackground, Creates a dimmed background for making floating modals.
  - Display Only Views
    - activityIndicator, Creates a spinning icon to indicate loading.
    - progressBar, Horizontal progress indicator.
    - circularProgress, Circular progress indicator.
    - icon, Displays a changeable icon.
    - image, Displays a changeable image.
    - video, Displays a changeable video.
    - separator, Creates a thin line in a row or column.
    - space, Creates a thin line in a row or column.
    - textView, Show a piece of text.
    - subtext, Show a smaller piece of text.
    - h1 - h6, Headers h1 through h6.
  - Interactive Elements
    - button, A button that triggers an action, which can be long-running.
    - menuButton, button that opens a menu.
    - link, link to an internal page.
    - externalLink, link to an external page.
  - Form Controls
    - checkbox, used in forms to include things.
    - radioButton, used in forms to pick a single options.
    - toggleButton, button that switches between two states.
    - field, wraps another input with a label.
    - localDateField, a field for entering a date.
    - localTimeField, a field for entering a time.
    - localDateTimeField, a field for entering a date and time.
    - select, a drop-down selection
    - switch, a switch, intended to do something immediately when changed.
    - textArea, multi-line text input.
    - textInput, generally single line text input.
    - numberInput, input that is limited to numbers.
    - phoneNumberInput, text input meant to accept text formatted as a phone number.

## Lightning Server Guidelines