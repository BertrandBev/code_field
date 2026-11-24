import 'package:flutter/services.dart'
    show KeyEvent, KeyDownEvent, KeyRepeatEvent, LogicalKeyboardKey;
import 'package:highlight/highlight_core.dart';
import 'package:material_ui/material_ui.dart';

import '../code_modifiers/close_block_code_modifier.dart';
import '../code_modifiers/code_modifier.dart';
import '../code_modifiers/indent_code_modifier.dart';
import '../code_modifiers/tab_code_modifier.dart';
import '../code_theme/code_theme.dart';
import '../code_theme/code_theme_data.dart';
import 'code_auto_complete.dart';
import 'editor_params.dart';

class CodeController extends TextEditingController {
  Mode? _language;

  CodeAutoComplete? autoComplete;

  /// A highlight language to parse the text with.
  Mode? get language => _language;

  set language(Mode? language) {
    if (language == _language) return;

    _language = language;

    if (language != null) {
      _languageId = language.hashCode.toString();
      highlight.registerLanguage(_languageId, language);
    } else {
      _languageId = '';
    }

    notifyListeners();
  }

  /// A map of specific regexes to style.
  final Map<String, TextStyle>? patternMap;

  /// A map of specific keywords to style.
  final Map<String, TextStyle>? stringMap;

  /// Common editor parameters.
  final EditorParams params;

  /// Code modifiers.
  final List<CodeModifier> modifiers;

  /* Computed members */

  String _languageId = '';

  final Map<String, CodeModifier> _modifierMap = {};
  final List<TextStyle> _styleList = [];

  RegExp? _styleRegExp;

  String get languageId => _languageId;

  CodeController({
    String? text,
    Mode? language,
    this.autoComplete,
    this.patternMap,
    this.stringMap,
    this.params = const EditorParams(),
    this.modifiers = const [
      IndentModifier(),
      CloseBlockModifier(),
      TabModifier(),
    ],
  }) : super(text: text) {
    this.language = language;

    for (final modifier in modifiers) {
      _modifierMap[modifier.char] = modifier;
    }

    // Build styleRegExp.
    final patternList = <String>[];

    if (stringMap != null) {
      patternList.addAll(
        stringMap!.keys.map((e) => r'(\b' + e + r'\b)'),
      );
      _styleList.addAll(stringMap!.values);
    }

    if (patternMap != null) {
      patternList.addAll(
        patternMap!.keys.map((e) => '($e)'),
      );
      _styleList.addAll(patternMap!.values);
    }

    if (patternList.isNotEmpty) {
      _styleRegExp = RegExp(
        patternList.join('|'),
        multiLine: true,
        unicode: true,
      );
    }
  }

  /// Sets a specific cursor position.
  void setCursor(int offset) {
    selection = TextSelection.collapsed(offset: offset);
  }

  /// Replaces the current selection by [str].
  void insertStr(String str) {
    final sel = selection;

    text = text.replaceRange(
      sel.start,
      sel.end,
      str,
    );

    final newOffset = sel.start + str.length;

    selection = TextSelection.collapsed(
      offset: newOffset,
    );
  }

  /// Removes the character just before the cursor.
  void removeChar() {
    if (selection.start < 1) return;

    final sel = selection;

    text = text.replaceRange(
      sel.start - 1,
      sel.start,
      '',
    );

    selection = TextSelection.collapsed(
      offset: sel.start - 1,
    );
  }

  /// Removes the selected text.
  void removeSelection() {
    final sel = selection;

    text = text.replaceRange(
      sel.start,
      sel.end,
      '',
    );

    selection = TextSelection.collapsed(
      offset: sel.start,
    );
  }

  /// Removes the selection or last character.
  void backspace() {
    if (selection.start < selection.end) {
      removeSelection();
    } else {
      removeChar();
    }
  }

  /// Handles keyboard events using the new KeyEvent API.
  KeyEventResult onKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.tab) {
      insertStr('\t');
      return KeyEventResult.handled;
    }

    final completion = autoComplete;

    if (completion?.isShowing ?? false) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (completion!.options.isNotEmpty) {
          completion.current =
              (completion.current + 1) % completion.options.length;
          completion.panelSetState?.call(() {});
        }
        return KeyEventResult.handled;
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (completion!.options.isNotEmpty) {
          completion.current =
              (completion.current - 1 + completion.options.length) %
                  completion.options.length;
          completion.panelSetState?.call(() {});
        }
        return KeyEventResult.handled;
      }

      if (event.logicalKey == LogicalKeyboardKey.enter) {
        completion!.writeCurrent();
        return KeyEventResult.handled;
      }

      if (event.logicalKey == LogicalKeyboardKey.escape) {
        completion!.hide();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  int? _insertedLoc(String oldText, String newText) {
    final sel = selection;

    if (oldText.length + 1 != newText.length ||
        sel.start != sel.end ||
        sel.start < 0 ||
        sel.start >= newText.length) {
      return null;
    }

    return sel.start;
  }

  @override
  set value(TextEditingValue newValue) {
    final loc = _insertedLoc(text, newValue.text);

    if (loc != null) {
      final char = newValue.text[loc];
      final modifier = _modifierMap[char];

      final val = modifier?.updateString(
        super.text,
        selection,
        params,
      );

      if (val != null) {
        newValue = newValue.copyWith(
          text: val.text,
          selection: val.selection,
        );
      }
    }

    super.value = newValue;
  }

  /// Processes custom regex patterns.
  TextSpan _processPatterns(
      String text,
      TextStyle? style,
      ) {
    final children = <TextSpan>[];

    text.splitMapJoin(
      _styleRegExp!,
      onMatch: (Match match) {
        if (_styleList.isEmpty) return '';

        var styleIndex = -1;

        for (var i = 1; i <= match.groupCount; i++) {
          if (match.group(i) != null) {
            styleIndex = i - 1;
            break;
          }
        }

        children.add(
          TextSpan(
            text: match[0],
            style: styleIndex >= 0 && styleIndex < _styleList.length
                ? _styleList[styleIndex]
                : style,
          ),
        );

        return '';
      },
      onNonMatch: (String span) {
        children.add(
          TextSpan(
            text: span,
            style: style,
          ),
        );

        return '';
      },
    );

    return TextSpan(
      style: style,
      children: children,
    );
  }

  /// Processes syntax highlighting.
  TextSpan _processLanguage(
      String text,
      CodeThemeData? widgetTheme,
      TextStyle? style,
      ) {
    final result = highlight.parse(
      text,
      language: _languageId,
    );

    List<TextSpan> processNodes(List<Node> nodes) {
      final children = <TextSpan>[];

      for (final node in nodes) {
        final nodeStyle = widgetTheme?.styles[node.className];

        if (node.value != null) {
          final value = node.value!;

          if (_styleRegExp != null) {
            children.add(
              _processPatterns(value, nodeStyle ?? style),
            );
          } else {
            children.add(
              TextSpan(
                text: value,
                style: nodeStyle,
              ),
            );
          }
        } else if (node.children != null) {
          children.add(
            TextSpan(
              style: nodeStyle,
              children: processNodes(node.children!),
            ),
          );
        }
      }

      return children;
    }

    return TextSpan(
      style: style,
      children: processNodes(result.nodes ?? []),
    );
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    bool? withComposing,
  }) {
    if (_language != null) {
      return _processLanguage(
        text,
        CodeTheme.of(context),
        style,
      );
    }

    if (_styleRegExp != null) {
      return _processPatterns(text, style);
    }

    return TextSpan(
      text: text,
      style: style,
    );
  }

  /// Creates a copy of this controller.
  CodeController copyWith({
    String? text,
    Mode? language,
    CodeAutoComplete? autoComplete,
    Map<String, TextStyle>? patternMap,
    Map<String, TextStyle>? stringMap,
    EditorParams? params,
    List<CodeModifier>? modifiers,
  }) {
    final controller = CodeController(
      text: text ?? this.text,
      language: language ?? this.language,
      autoComplete: autoComplete ?? this.autoComplete,
      patternMap: patternMap ?? this.patternMap,
      stringMap: stringMap ?? this.stringMap,
      params: params ?? this.params,
      modifiers: modifiers ?? this.modifiers,
    );

    return controller;
  }
}
