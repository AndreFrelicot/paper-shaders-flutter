# Paper Shaders Example

Example app for the `paper_shaders` package.

The app is an interactive showcase for the full Paper Shaders catalogue. It
lets you browse all shaders, switch presets, edit sizing and shader uniforms,
pick colors, and copy Dart initialization snippets for the current preset.

Run it on the current device:

```sh
flutter run
```

Common local targets:

```sh
flutter run -d macos
flutter run -d ios
flutter run -d android
flutter run -d chrome
```

The same app also provides the deterministic golden renderer used by the package
scripts:

```sh
cd ..
tool/render_flutter_goldens.sh
tool/check_flutter_parity.sh
```

The renderer walks `ShaderCatalog.all` and captures every catalogued preset at a
fixed frame.
