/*
 * Simple example
 */

import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
// Import the language & theme
import 'package:highlight/languages/dart.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_highlight/themes/a11y-dark.dart';

class CodeEditor extends StatefulWidget {
  @override
  _CodeEditorState createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  CodeController? _codeController;

  @override
  void initState() {
    super.initState();
    final source = "";
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
      expands: true,
    );
  }
}

class CodeEditor1 extends StatefulWidget {
  @override
  _CodeEditor1State createState() => _CodeEditor1State();
}

class _CodeEditor1State extends State<CodeEditor1> {
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

/*
 * Custom map example
 */

class CodeEditor2 extends StatefulWidget {
  @override
  _CodeEditor2State createState() => _CodeEditor2State();
}

class _CodeEditor2State extends State<CodeEditor2> {
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
      stringMap: {
        "Hello": TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        "world": TextStyle(fontStyle: FontStyle.italic, color: Colors.green),
      },
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

/*
 * Custom patterns
 */

class CodeEditor3 extends StatefulWidget {
  @override
  _CodeEditor3State createState() => _CodeEditor3State();
}

class _CodeEditor3State extends State<CodeEditor3> {
  CodeController? _codeController;

  @override
  void initState() {
    super.initState();
    final source = "void main() {\n    print(\"#Hello, #world!\");\n}";
    // Instantiate the CodeController
    _codeController = CodeController(
      text: source,
      language: dart,
      theme: monokaiSublimeTheme,
      patternMap: {
        r"\B#[a-zA-Z0-9]+\b":
            TextStyle(fontWeight: FontWeight.bold, color: Colors.purpleAccent),
      },
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

/*
 * Custom map
 */

class CodeEditor4 extends StatefulWidget {
  @override
  _CodeEditor4State createState() => _CodeEditor4State();
}

class _CodeEditor4State extends State<CodeEditor4> {
  CodeController? _codeController;

  @override
  void initState() {
    super.initState();
    final source = "void main() {\n    print(\"#Hello, #world!\");\n}";
    // Instantiate the CodeController
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
      textStyle: TextStyle(
        fontFamily: 'SourceCode',
        // color: Colors.grey.shade100,
      ),
      lineNumberStyle: LineNumberStyle(
          textStyle: TextStyle(
              // color: Colors.grey.shade500,
              )),
    );
  }
}

/*
 * Android screen
 */

class CodeEditor5 extends StatefulWidget {
  @override
  _CodeEditor5State createState() => _CodeEditor5State();
}

class _CodeEditor5State extends State<CodeEditor5> {
  CodeController? _codeController;

  @override
  void initState() {
    super.initState();
    final source = """// An expensive but pretty
// recursive implementation
int fibonacci(int n) {
  if (n <= 1) return n;
  return fibonacci(n - 1)
    + fibonacci(n - 2);
}

void main() {
  print("Fibonacci sequence:");
  for (var n = 0; n < 10; n++)
    print(fibonacci(n));
}
""";
    // Instantiate the CodeController
    _codeController = CodeController(
      text: source,
      language: dart,
      theme: a11yDarkTheme,
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
      expands: true,
    );
  }
}
