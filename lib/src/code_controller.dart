import 'dart:math';
import 'package:code_text_field/src/code_modifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:highlight/highlight_core.dart';

class EditorParams {
  final int tabSpaces;

  const EditorParams({this.tabSpaces = 2});
}

class CodeController extends TextEditingController {
  final Mode? language;
  final Map<String, TextStyle>? theme;
  final Map<String, TextStyle>? patternMap;
  final Map<String, TextStyle>? stringMap;
  final EditorParams params;
  final List<CodeModifier> modifiers;
  final String languageId = _genId();
  // Computed members
  final styleList = <TextStyle>[];
  final modifierMap = <String, CodeModifier>{};
  RegExp? styleRegExp;

  /// Creates a CodeController instance
  CodeController({
    String? text,
    this.language,
    this.theme,
    this.patternMap,
    this.stringMap,
    this.params = const EditorParams(),
    this.modifiers = const <CodeModifier>[
      const IntendModifier(),
      const CloseBlockModifier(),
      const TabModifier(),
    ],
  }) : super(text: text) {
    // PatternMap
    if (language != null && theme == null)
      throw Exception("A theme must be provided for language parsing");
    // Register language
    if (language != null) {
      highlight.registerLanguage(languageId, language!);
    }
    // Create modifier map
    modifiers.forEach((el) {
      modifierMap[el.char] = el;
    });
  }

  void insertStr(String str) {
    final sel = selection;
    text = text.replaceRange(selection.start, selection.end, str);
    final len = str.length;
    selection = sel.copyWith(
      baseOffset: sel.start + len,
      extentOffset: sel.start + len,
    );
  }

  bool onKey(RawKeyEvent event) {
    if (event.isKeyPressed(LogicalKeyboardKey.tab)) {
      text = text.replaceRange(selection.start, selection.end, "\t");
      return true;
    }
    return false;
  }

  static String _genId() {
    const _chars = 'abcdefghijklmnopqrstuvwxyz1234567890';
    final _rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(
          10, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))),
    );
  }

  int? _insertedLoc(String a, String b) {
    final sel = selection;
    if (a.length + 1 != b.length || sel.start != sel.end) return null;
    return sel.start;
  }

  @override
  set value(TextEditingValue newValue) {
    final loc = _insertedLoc(text, newValue.text);
    if (loc != null) {
      final char = newValue.text[loc];
      final modifier = modifierMap[char];
      final val = modifier?.updateString(text, selection, params);
      if (val != null) {
        // Update newValue
        newValue = newValue.copyWith(
          text: val.text,
          selection: val.selection,
        );
      }
    }
    super.value = newValue;
  }

  TextSpan _processPatterns(String text, TextStyle? style) {
    final children = <TextSpan>[];
    text.splitMapJoin(
      styleRegExp!,
      onMatch: (Match m) {
        if (styleList.isEmpty) return '';
        int idx;
        for (idx = 1;
            idx < m.groupCount &&
                idx <= styleList.length &&
                m.group(idx) == null;
            idx++) {}
        children.add(TextSpan(
          text: m[0],
          style: styleList[idx - 1],
        ));
        return '';
      },
      onNonMatch: (String span) {
        children.add(TextSpan(text: span, style: style));
        return '';
      },
    );
    return TextSpan(style: style, children: children);
  }

  TextSpan _processLanguage(String text, TextStyle? style) {
    final result = highlight.parse(text, language: languageId);

    final nodes = result.nodes;

    final children = <TextSpan>[];
    var currentSpans = children;
    final stack = <List<TextSpan>>[];

    void _traverse(Node node) {
      final val = node.value;
      final nodeChildren = node.children;
      if (val != null) {
        var child = TextSpan(text: val, style: theme?[node.className]);
        if (styleRegExp != null)
          child = _processPatterns(val, theme?[node.className]);
        currentSpans.add(child);
      } else if (nodeChildren != null) {
        List<TextSpan> tmp = [];
        currentSpans.add(TextSpan(
          children: tmp,
          style: theme?[node.className],
        ));
        stack.add(currentSpans);
        currentSpans = tmp;
        nodeChildren.forEach((n) {
          _traverse(n);
          if (n == nodeChildren.last) {
            currentSpans = stack.isEmpty ? children : stack.removeLast();
          }
        });
      }
    }

    if (nodes != null) for (var node in nodes) _traverse(node);
    return TextSpan(style: style, children: children);
  }

  @override
  TextSpan buildTextSpan({TextStyle? style, bool? withComposing}) {
    // Retrieve pattern regexp
    final patternList = <String>[];
    if (stringMap != null) {
      patternList.addAll(stringMap!.keys.map((e) => r'(\b' + e + r'\b)'));
      styleList.addAll(stringMap!.values);
    }
    if (patternMap != null) {
      patternList.addAll(patternMap!.keys.map((e) => "(" + e + ")"));
      styleList.addAll(patternMap!.values);
    }
    styleRegExp = RegExp(patternList.join('|'), multiLine: true);

    // Return parsing
    if (language != null)
      return _processLanguage(text, style);
    else if (styleRegExp != null)
      return _processPatterns(text, style);
    else
      return TextSpan(text: text, style: style);
  }
}
