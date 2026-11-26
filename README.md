# MetaEngine OpenAPI Dart Dio

Generate a typed Dart client that uses Dio from an OpenAPI 3.x schema. The generator runs locally on macOS, Linux and Windows, with a self-contained engine runner.

## Install

Install the generator with Dart 3.4 or later.

```sh
dart pub global activate metaengine_openapi_dart_dio
```

Add the Pub cache's `bin` directory to your PATH to use the command directly. The first run downloads and verifies the runner for your platform.

## Generate a client

```sh
metaengine_openapi_dart_dio api.yaml ./lib/generated
```

Pass a local YAML or JSON file or an HTTP(S) URL. Add `dio` to the Dart project that uses the generated client.

OpenAPI 3.2 `query` operations generate HTTP QUERY requests with their typed bodies.

```sh
dart pub add dio
metaengine_openapi_dart_dio api.yaml ./lib/generated --receive-timeout 1500
```

Run `metaengine_openapi_dart_dio --help` for the full option list.

| Option | Behavior |
| --- | --- |
| `--connect-timeout`, `--receive-timeout`, `--send-timeout` | Set the individual Dio timeouts in milliseconds. Zero disables that timeout. |
| `--timeout` | Set the default timeout in seconds. |
| `--header <name:env-var>` | Read a header value from an environment variable when the generated client runs. Repeat for additional headers. |
| `--oauth2-refresh <scheme> <token-url>` | Generate OAuth2 refresh for the named OpenAPI security scheme. Use `--oauth2-grant-type` to select `client_credentials` or `authorization_code`. |
| `--include-tags <csv>` | Generate only operations with the selected tags. |
| `--documentation` | Include OpenAPI descriptions in generated Dart documentation. |

## Supported platforms

macOS on Intel and Apple silicon, Linux on x64 and arm64, and Windows on x64. The CLI selects the runner that matches the Dart executable's platform and architecture.

The CLI downloads a self-contained runner built with [MetaEngine.Dart.OpenApi.Dio 1.0.0](https://www.nuget.org/packages/MetaEngine.Dart.OpenApi.Dio/1.0.0).
