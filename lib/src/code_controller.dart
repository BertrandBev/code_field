import 'dart:math';

import 'package:flutter/material.dart';
import 'package:highlight/highlight_core.dart';

class CodeController extends TextEditingController {
  final Mode? language;
  final Map<String, TextStyle>? theme;
  final Map<String, TextStyle>? patternMap;
  final Map<String, TextStyle>? stringMap;
  final String languageId = genId();
  // Computed members
  final styleList = <TextStyle>[];
  RegExp? styleRegExp;

  /// Creates a CodeController instance
  CodeController({
    String? text,
    this.language,
    this.theme,
    this.patternMap,
    this.stringMap,
  }) : super(text: text) {
    // PatternMap
    if (language != null && theme == null)
      throw Exception("A theme must be provided for language parsing");
    if (language != null) {
      // Register language
      highlight.registerLanguage(languageId, language!);
    }
  }

  static String genId() {
    const _chars = 'abcdefghijklmnopqrstuvwxyz1234567890';
    final _rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(
          10, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))),
    );
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
    // final pattern = r"((a)b)|((c)(d))";
    // final re = RegExp(pattern);
    // final m = re.firstMatch("cd");
    // final groups = <String>[];
    // for (int k = 0; k < m.groupCount; k++) groups.add(m.group(k));
    // print("count: ${m.groupCount}, groups: ${groups}");

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
    print(patternList.join('|'));
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
