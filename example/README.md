# Generate an Orders client

Create a Dart project and install Dio and the generator.

```sh
dart create -t console orders_client
cd orders_client
dart pub add dio
dart pub global activate metaengine_openapi_dart_dio
```

Save [orders.yaml](https://raw.githubusercontent.com/meta-engine/metaengine-openapi-dart-dio/main/example/orders.yaml)
next to your project's `pubspec.yaml`. Generate the client and check the generated code.

```sh
dart pub global run metaengine_openapi_dart_dio orders.yaml lib/generated
dart analyze lib/generated
```

The generated Dart files include a `getOrder` method and a typed `Order` model.
