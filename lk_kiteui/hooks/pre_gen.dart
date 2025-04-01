import 'dart:io';

import 'package:mason/mason.dart';

void run(HookContext context) {
  final directory = Directory.current.path;
  context.vars["projectPath"] = "$directory/${context.vars['project_name']}";
}
