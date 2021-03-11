import 'package:example/code_snippets.dart';
import 'package:example/themes.dart';
import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/all.dart';

class CustomCodeBox extends StatefulWidget {
  final String language;
  final String theme;

  const CustomCodeBox({Key? key, required this.language, required this.theme})
      : super(key: key);

  @override
  _CustomCodeBoxState createState() => _CustomCodeBoxState();
}

class _CustomCodeBoxState extends State<CustomCodeBox> {
  String? language;
  String? theme;

  @override
  void initState() {
    super.initState();
    language = widget.language;
    theme = widget.theme;
  }

  List<String?> get languageList {
    const TOP = <String>{
      "java",
      "cpp",
      "python",
      "javascript",
      "cs",
      "dart",
      "haskell",
      "ruby",
    };
    return <String?>[
      ...TOP,
      null, // Divider
      ...CODE_SNIPPETS.keys.where((el) => !TOP.contains(el))
    ];
  }

  List<String?> get themeList {
    const TOP = <String>{
      "monokai-sublime",
      "a11y-dark",
      "an-old-hope",
      "vs2015",
      "vs",
      "atom-one-dark",
    };
    return <String?>[
      ...TOP,
      null, // Divider
      ...THEMES.keys.where((el) => !TOP.contains(el))
    ];
  }

  Widget buildDropdown(Iterable<String?> choices, String value, IconData icon,
      Function(String?) onChanged) {
    return DropdownButton<String>(
      value: value,
      items: choices.map((String? value) {
        return new DropdownMenuItem<String>(
          value: value,
          child: value == null
              ? Divider()
              : Text(value, style: TextStyle(color: Colors.white)),
        );
      }).toList(),
      icon: Icon(icon, color: Colors.white),
      onChanged: onChanged,
      dropdownColor: Colors.black87,
    );
  }

  @override
  Widget build(BuildContext context) {
    final codeDropdown =
        buildDropdown(languageList, language!, Icons.code, (val) {
      if (val == null) return;
      setState(() => language = val);
    });
    final themeDropdown =
        buildDropdown(themeList, theme!, Icons.color_lens, (val) {
      if (val == null) return;
      setState(() => theme = val);
    });
    final dropdowns = Row(children: [
      SizedBox(width: 12.0),
      codeDropdown,
      SizedBox(width: 12.0),
      themeDropdown,
    ]);
    final codeField = InnerField(
      key: ValueKey("$language - $theme"),
      language: language!,
      theme: theme!,
    );
    return Column(children: [
      dropdowns,
      codeField,
    ]);
  }
}

class InnerField extends StatefulWidget {
  final String language;
  final String theme;

  const InnerField({Key? key, required this.language, required this.theme})
      : super(key: key);

  @override
  _InnerFieldState createState() => _InnerFieldState();
}

class _InnerFieldState extends State<InnerField> {
  CodeController? _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: CODE_SNIPPETS[widget.language],
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
      language: allLanguages[widget.language],
      theme: THEMES[widget.theme],
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
