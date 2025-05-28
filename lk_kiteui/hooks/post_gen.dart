import 'dart:io';
import 'package:mason/mason.dart';

import 'apps_kotlin.dart';
import 'server_kotlin.dart';
import 'shared_kotlin.dart';

void run(HookContext context) {
  final projectPath = context.vars['projectPath'];
  final String packageId = context.vars['package_id'];
  final String projectName = context.vars['project_name'];
  final packageDirectories = packageId.replaceAll(".", "/");
  final commonDirectory = Directory(
    "$projectPath/apps/src/commonMain/kotlin/$packageDirectories",
  );
  final iosDirectory = Directory(
    "$projectPath/apps/src/iosMain/kotlin/$packageDirectories",
  );
  final androidDirectory = Directory(
    "$projectPath/apps/src/androidMain/kotlin/$packageDirectories",
  );
  final counterDir = Directory("${commonDirectory.path}/counter");
  final cheatSheetDir = Directory("${commonDirectory.path}/cheatsheet");

  counterDir.createSync(recursive: true);
  cheatSheetDir.createSync(recursive: true);
  androidDirectory.createSync(recursive: true);
  iosDirectory.createSync(recursive: true);

  final mainActivityFile = File("${androidDirectory.path}/MainActivity.kt");
  mainActivityFile.createSync(recursive: true);

  final appFiles = [
    "App.kt",
    "AppTheme.kt",
    "Styles.kt",
  ].map((fileName) => File("${commonDirectory.path}/$fileName"));

  final iosAppFile = File("${iosDirectory.path}/App.ios.kt");

  final counterFiles = [
    "CounterView.kt",
    "CounterVM.kt",
  ].map((fileName) => File("${counterDir.path}/$fileName"));
  final appsContents = appsFileContents(packageId);

  final cheatSheetFiles = [
    "CheatSheetView.kt",
  ].map((fileName) => File("${cheatSheetDir.path}/$fileName"));

  mainActivityFile.writeAsStringSync(appsContents["MainActivity"]!);

  appFiles.forEach((file) {
    file.createSync(recursive: true);
    final contents = appsContents[file.path.split("/").last];
    file.writeAsStringSync(contents!);
  });

  counterFiles.forEach((file) {
    file.createSync(recursive: true);
    final contents = appsContents[file.path.split("/").last];
    file.writeAsStringSync(contents!);
  });

  cheatSheetFiles.forEach((file) {
    file.createSync(recursive: true);
    final contents = appsContents[file.path.split("/").last];
    file.writeAsStringSync(contents!);
  });

  iosAppFile.createSync(recursive: true);
  iosAppFile.writeAsStringSync(iosAppFileContents(packageId));

  if (context.vars['add_server']) {
    final serverDirectory = Directory(
      "$projectPath/server/src/main/kotlin/$packageDirectories",
    );

    final sharedDirectory = Directory(
      "$projectPath/shared/src/commonMain/kotlin/$packageDirectories",
    );

    serverDirectory.createSync(recursive: true);
    sharedDirectory.createSync(recursive: true);

    final serverContents = serverFileContents(packageId, projectName);
    final sharedContents = sharedFileContents(packageId);
    final serverFiles = serverContents.keys.map(
      (fileName) => File("${serverDirectory.path}/$fileName"),
    );
    final sharedFiles = sharedContents.keys.map(
      (fileName) => File("${sharedDirectory.path}/$fileName"),
    );

    serverFiles.forEach((file) {
      file.createSync(recursive: true);
      final contents = serverContents[file.path.split("/").last];
      file.writeAsStringSync(contents!);
    });

    sharedFiles.forEach((file) {
      file.createSync(recursive: true);
      final contents = sharedContents[file.path.split("/").last];
      file.writeAsStringSync(contents!);
    });
  }
}
