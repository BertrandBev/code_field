# CodeField

A customizable code text field supporting syntax highlighting

## Features

- Code highlight for 189 built-in languages with 90 themes thanks to [flutter_highlight](https://pub.dev/packages/flutter_highlight)
- Easy highlight customisation through the use of theme
- Fully customizable code field style through a TextField like API

## Installing

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  code_text_field: <latest_version>
```

[Latest version]()

In your library add the following import:

```dart
import 'package:code_text_field/code_field.dart';
```

## Simple example

```dart
import 'package:code_text_field/code_field.dart';
// Import the language & theme
import 'package:highlight/languages/dart.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';

class CodeField extends StatefulWidget {
  @override
  _CodeFieldState createState() => _CodeFieldState();
}

class _CodeFieldState extends State<CodeField> {
  CodeController _codeController;

  @override
  void initState() {
    super.initState();
    final source = "void main() {\n\tprint(\"Hello, world!);\n}\n";
    // Instanciate the CodeController
    _codeController = CodeController(
      text: source,
      language: dart,
      theme: monokaiSublimeTheme,
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CodeField(
      controller: _codeController,
    );
  }
}
```

## Style customisation

## Custom language




<!-- LIMITATIONS -->
<!-- https://github.com/flutter/flutter/issues/71679 -->


