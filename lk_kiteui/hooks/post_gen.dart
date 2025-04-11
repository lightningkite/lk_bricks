import 'dart:io';
import 'package:mason/mason.dart';

import 'apps_kotlin.dart';
import 'server_kotlin.dart';
import 'shared_kotlin.dart';

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
  final appsContents = appsFileContents(packageId);

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

  if (context.vars['add_server']) {
    final serverDirectory =
        Directory("$projectPath/server/src/main/kotlin/$packageDirectories");

    final sharedDirectory =
        Directory("$projectPath/shared/src/main/kotlin/$packageDirectories");

    serverDirectory.createSync(recursive: true);
    sharedDirectory.createSync(recursive: true);

    final serverContents = serverFileContents(packageId);
    final sharedContents = sharedFileContents(packageId);
    final serverFiles = serverContents.keys
        .map((fileName) => File("${serverDirectory.path}/$fileName"));
    final sharedFiles = sharedContents.keys
        .map((fileName) => File("${sharedDirectory.path}/$fileName"));

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
    // final appFiles = ["App.kt", "AppTheme.kt", "Styles.kt"]
    //   .map((fileName) => File("${commonDirectory.path}/$fileName"));
    // final counterFiles = ["CounterView.kt", "CounterVM.kt"]
    //     .map((fileName) => File("${counterDir.path}/$fileName"));
    // ;
    // final appsContents = appsFileContents(packageId);

    // mainActivityFile.writeAsStringSync(appsContents["MainActivity"]!);

    // appFiles.forEach((file) {
    //   file.createSync(recursive: true);
    //   final contents = appsContents[file.path.split("/").last];
    //   file.writeAsStringSync(contents!);
    // });
  }
}
