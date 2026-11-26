import 'dart:io';

import 'package:metaengine_openapi_dart_dio/src/cli.dart';

const packageVersion = '1.0.0';
const releaseOrigin =
    'https://github.com/meta-engine/metaengine-openapi-dart-dio/releases/download/';

Future<void> main(List<String> arguments) async {
  exitCode = await runCli(
    arguments,
    version: packageVersion,
    releaseOrigin: Uri.parse(releaseOrigin),
  );
}
