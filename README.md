# CodeField

A customizable code text field supporting syntax highlighting

[![Pub](https://img.shields.io/pub/v/code_text_field.svg)](https://pub.dev/packages/code_text_field)
[![Website shields.io](https://img.shields.io/website-up-down-green-red/http/shields.io.svg)](https://bertrandbev.github.io/code_field/)
[![GitHub license](https://img.shields.io/github/license/Naereen/StrapDown.js.svg)](https://raw.githubusercontent.com/BertrandBev/code_field/master/LICENSE)

<img src="https://raw.githubusercontent.com/BertrandBev/code_field/master/doc/images/android.png" width="60%">

## Live demo

A [live demo]() showcasing a few language / themes combinaisons 

## Features

- Code highlight for 189 built-in languages with 90 themes thanks to [flutter_highlight](https://pub.dev/packages/flutter_highlight)
- Easy language highlight customization through the use of theme maps
- Fully customizable code field style through a TextField like API
- Handles horizontal/vertical scrolling and vertical expansion
- Works on Android, iOS, and Web

## Installing

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  code_text_field: <latest_version>
```

[latest version](https://pub.dev/packages/code_text_field/install)

In your library add the following import:

```dart
import 'package:code_text_field/code_field.dart';
```

## Simple example

A CodeField widget works with a **CodeController** which dynamically parses the text input according to a language and renders it with a theme map

```dart
import 'package:flutter/material.dart';
import 'package:code_text_field/code_field.dart';
// Import the language & theme
import 'package:highlight/languages/dart.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';

class CodeEditor extends StatefulWidget {
  @override
  _CodeEditorState createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  CodeController? _codeController;

  @override
  void initState() {
    super.initState();
    final source = "void main() {\n    print(\"Hello, world!\");\n}";
    // Instantiate the CodeController
    _codeController = CodeController(
      text: source,
      language: dart,
      theme: monokaiSublimeTheme,
    );
  }

  @override
  void dispose() {
    _codeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CodeField(
      controller: _codeController!,
      textStyle: TextStyle(fontFamily: 'SourceCode'),
    );
  }
}
```

<img src="https://raw.githubusercontent.com/BertrandBev/code_field/master/doc/images/example_0.png" width="60%">

Here, the monospace font [Source Code Pro](https://fonts.google.com/specimen/Source+Code+Pro?preview.text_type=custom) has been added to the assets folder and to the [pubspec.yaml](https://github.com/BertrandBev/code_field/blob/master/example/pubspec.yaml) file

## Parser options

On top of a language definition, world-wise styling can be specified in the **stringMap** field

```dart
_codeController = CodeController(
  //...
  stringMap: {
    "Hello": TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
    "world": TextStyle(fontStyle: FontStyle.italic, color: Colors.green),
  },
);
```

<img src="https://raw.githubusercontent.com/BertrandBev/code_field/master/doc/images/example_1.png" width="60%">

More complex regexes may also be used with the **patternMap**. When a language is used though, its regexes patterns take precedence over **patternMap** and **stringMap**.

```dart
_codeController = CodeController(
  //...
  patternMap: {
    r"\B#[a-zA-Z0-9]+\b":
        TextStyle(fontWeight: FontWeight.bold, color: Colors.purpleAccent),
  },
);
```

<img src="https://raw.githubusercontent.com/BertrandBev/code_field/master/doc/images/example_2.png" width="60%">

Both **patternMap** and **stringMap** can be used without specifying a language

```dart
_codeController = CodeController(
  text: source,
  patternMap: {
    r'".*"': TextStyle(color: Colors.yellow),
    r'[a-zA-Z0-9]+\(.*\)': TextStyle(color: Colors.green),
  },
  stringMap: {
    "void": TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
    "print": TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
  },
);
```

<img src="https://raw.githubusercontent.com/BertrandBev/code_field/master/doc/images/example_3.png" width="60%">

## API

### CodeField

```dart
CodeField({
  Key? key,
  required this.controller,
  this.minLines,
  this.maxLines,
  this.expands = false,
  this.background,
  this.decoration,
  this.textStyle,
  this.padding = const EdgeInsets.symmetric(horizontal: 8.0),
  this.scrollPadding = const EdgeInsets.symmetric(vertical: 8.0),
  this.lineNumberStyle = const LineNumberStyle(),
  this.cursorColor,
  this.textSelectionTheme,
})
```

```dart
LineNumberStyle({
  this.width = 42.0,
  this.textAlign = TextAlign.right,
  this.padding = const EdgeInsets.only(right: 10.0),
  this.textStyle,
  this.background,
})
```

### CodeController

```dart
CodeController({
  String? text,
  this.language,
  this.theme,
  this.patternMap,
  this.stringMap,
})
```

## Limitations

- Autocomplete disabling on android [doesn't work yet](https://github.com/flutter/flutter/issues/71679)
- The TextField cursor doesn't seem to be handling space keys properly on the web platform. Pending issue resolution
