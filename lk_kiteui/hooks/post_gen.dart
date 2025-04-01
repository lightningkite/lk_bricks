import 'dart:io';

import 'package:mason/mason.dart';

void run(HookContext context) {
  context.vars.keys.forEach((key) {
    print("$key: ${context.vars[key]}");
  });
  final projectPath = context.vars['projectPath'];
  final directory = Directory("$projectPath/code");
  print("FILE EXITS: ${directory.existsSync()}");
  print("FILE PATH: ${directory.absolute}");
}
