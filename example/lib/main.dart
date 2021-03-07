import 'package:example/custom_code_box.dart';
import 'package:flutter/material.dart';
import 'package:code_text_field/code_controller.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Code field',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: HomePage(title: 'Code field demo page'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CodeController _codeController;

  @override
  void initState() {
    super.initState();
    final String source = '''function myFunction(p1, p2) {
    function inner(str) {
      return "some string";
    }
    if (p1 == p2)
      return 2 * p1 * p2;
    else
      return 0;
}
''';

    _codeController = CodeController(
      text: source,
      patternMap: {
        r"\B#[a-zA-Z0-9]+\b": TextStyle(color: Colors.red),
        r"\B@[a-zA-Z0-9]+\b": TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.blue,
        ),
        r"\B![a-zA-Z0-9]+\b":
            TextStyle(color: Colors.yellow, fontStyle: FontStyle.italic),
      },
      stringMap: {
        "bev": TextStyle(color: Colors.indigo),
      },
      language: javascript,
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
    final preset = <String>[
      "dart|monokai-sublime",
      "python|monokai",
      "cpp|an-old-hope",
      "java|a11y-dark",
      "javascript|vs2015",
    ];
    List<Widget> children = preset.map((e) {
      final parts = e.split('|');
      print(parts);
      final box = CustomCodeBox(
        language: parts[0],
        theme: parts[1],
      );
      return Padding(
        padding: EdgeInsets.only(bottom: 32.0),
        child: box,
      );
    }).toList();
    final page = Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 900),
        child: Column(children: children),
      ),
    );
    return Scaffold(
      backgroundColor: Color(0xFF363636),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.code),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(child: page),
    );
  }
}
