import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import './code_controller.dart';

class LineNumberController extends TextEditingController {
  final TextSpan Function(int, TextStyle?)? lineNumberBuilder;

  LineNumberController(this.lineNumberBuilder);

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, bool? withComposing}) {
    final children = <TextSpan>[];
    final list = text.split("\n");
    for (int k = 0; k < list.length; k++) {
      final el = list[k];
      final number = int.parse(el);
      var textSpan = TextSpan(text: el, style: style);
      if (lineNumberBuilder != null) textSpan = lineNumberBuilder!(number, style);
      children.add(textSpan);
      if (k < list.length - 1) children.add(TextSpan(text: "\n"));
    }
    return TextSpan(children: children, style: style);
  }
}

class LineNumberStyle {
  /// Width of the line number column
  final double width;

  /// Alignment of the numbers in the column
  final TextAlign textAlign;

  /// Style of the numbers
  final TextStyle? textStyle;

  /// Background of the line number column
  final Color? background;

  /// Central horizontal margin between the numbers and the code
  final double margin;

  const LineNumberStyle({
    this.width = 42.0,
    this.textAlign = TextAlign.right,
    this.margin = 10.0,
    this.textStyle,
    this.background,
  });
}

class CodeField extends StatefulWidget {
  /// {@macro flutter.widgets.textField.minLines}
  final SmartQuotesType smartQuotesType;

  /// {@macro flutter.widgets.textField.minLines}
  final int? minLines;

  /// {@macro flutter.widgets.textField.maxLInes}
  final int? maxLines;

  /// {@macro flutter.widgets.textField.expands}
  final bool expands;

  /// Whether overflowing lines should wrap around or make the field scrollable horizontally
  final bool wrap;

  /// A CodeController instance to apply language highlight, themeing and modifiers
  final CodeController controller;

  /// A LineNumberStyle instance to tweak the line number column styling
  final LineNumberStyle lineNumberStyle;

  /// {@macro flutter.widgets.textField.cursorColor}
  final Color? cursorColor;

  /// {@macro flutter.widgets.textField.textStyle}
  final TextStyle? textStyle;

  /// A way to replace specific line numbers by a custom TextSpan
  final TextSpan Function(int, TextStyle?)? lineNumberBuilder;

  /// {@macro flutter.widgets.textField.enabled}
  final bool? enabled;

  /// {@macro flutter.widgets.editableText.onChanged}
  final void Function(String)? onChanged;

  /// {@macro flutter.widgets.editableText.readOnly}
  final bool readOnly;

  final bool isDense;

  final Color? background;
  final EdgeInsets padding;
  final Decoration? decoration;
  final TextSelectionThemeData? textSelectionTheme;
  final FocusNode? focusNode;
  final void Function()? onTap;

  const CodeField({
    Key? key,
    required this.controller,
    this.minLines,
    this.maxLines,
    this.expands = false,
    this.wrap = false,
    this.background,
    this.decoration,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(),
    this.lineNumberStyle = const LineNumberStyle(),
    this.enabled,
    this.onTap,
    this.readOnly = false,
    this.cursorColor,
    this.textSelectionTheme,
    this.lineNumberBuilder,
    this.focusNode,
    this.onChanged,
    this.isDense = false,
    this.smartQuotesType = SmartQuotesType.enabled,
  }) : super(key: key);

  @override
  CodeFieldState createState() => CodeFieldState();
}

class CodeFieldState extends State<CodeField> {
  // Add a controller
  LinkedScrollControllerGroup? _controllers;
  ScrollController? _numberScroll;
  ScrollController? _codeScroll;
  LineNumberController? _numberController;

  StreamSubscription<bool>? _keyboardVisibilitySubscription;
  FocusNode? _focusNode;
  String? lines;
  String longestLine = "";

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _numberScroll = _controllers?.addAndGet();
    _codeScroll = _controllers?.addAndGet();
    _numberController = LineNumberController(widget.lineNumberBuilder);
    widget.controller.addListener(_onTextChanged);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode!.onKey = _onKey;
    _focusNode!.attach(context, onKey: _onKey);

    _onTextChanged();
  }

  KeyEventResult _onKey(FocusNode node, RawKeyEvent event) {
    if (widget.readOnly) return KeyEventResult.ignored;
    return widget.controller.onKey(event);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _numberScroll?.dispose();
    _codeScroll?.dispose();
    _numberController?.dispose();
    _keyboardVisibilitySubscription?.cancel();
    super.dispose();
  }

  void rebuild() {
    setState(() {});
  }

  void _onTextChanged() {
    // Rebuild line number
    final str = widget.controller.text.split("\n");
    final buf = <String>[];
    for (var k = 0; k < str.length; k++) {
      buf.add((k + 1).toString());
    }
    _numberController?.text = buf.join("\n");
    // Find longest line
    longestLine = "";
    widget.controller.text.split("\n").forEach((line) {
      if (line.length > longestLine.length) longestLine = line;
    });
    setState(() {});
  }

  // Wrap the codeField in a horizontal scrollView
  Widget _wrapInScrollView(Widget codeField, TextStyle textStyle, double minWidth) {
    final leftPad = widget.lineNumberStyle.margin / 2;
    final intrinsic = IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 0.0,
              minWidth: max(minWidth - leftPad, 0.0),
            ),
            child: Padding(
              child: Text(longestLine, style: textStyle),
              padding: const EdgeInsets.only(right: 16.0),
            ), // Add extra padding
          ),
          widget.expands ? Expanded(child: codeField) : codeField,
        ],
      ),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: leftPad,
        right: widget.padding.right,
      ),
      scrollDirection: Axis.horizontal,
      child: intrinsic,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Default color scheme
    const ROOT_KEY = 'root';
    final defaultBg = Colors.grey.shade900;
    final defaultText = Colors.grey.shade200;

    final theme = widget.controller.theme;
    Color? backgroundCol = widget.background ?? theme?[ROOT_KEY]?.backgroundColor ?? defaultBg;
    if (widget.decoration != null) {
      backgroundCol = null;
    }
    TextStyle textStyle = widget.textStyle ?? TextStyle();
    textStyle = textStyle.copyWith(
      color: textStyle.color ?? theme?[ROOT_KEY]?.color ?? defaultText,
      fontSize: textStyle.fontSize ?? 16.0,
    );
    TextStyle numberTextStyle = widget.lineNumberStyle.textStyle ?? TextStyle();
    final numberColor = (theme?[ROOT_KEY]?.color ?? defaultText).withOpacity(0.7);
    // Copy important attributes
    numberTextStyle = numberTextStyle.copyWith(
      color: numberTextStyle.color ?? numberColor,
      fontSize: textStyle.fontSize,
      fontFamily: textStyle.fontFamily,
    );
    final cursorColor = widget.cursorColor ?? theme?[ROOT_KEY]?.color ?? defaultText;

    final lineNumberCol = TextField(
      smartQuotesType: widget.smartQuotesType,
      scrollPadding: widget.padding,
      style: numberTextStyle,
      controller: _numberController,
      enabled: false,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      expands: widget.expands,
      scrollController: _numberScroll,
      decoration: InputDecoration(
        disabledBorder: InputBorder.none,
        isDense: widget.isDense,
      ),
      textAlign: widget.lineNumberStyle.textAlign,
    );

    final numberCol = Container(
      width: widget.lineNumberStyle.width,
      padding: EdgeInsets.only(
        left: widget.padding.left,
        right: widget.lineNumberStyle.margin / 2,
      ),
      color: widget.lineNumberStyle.background,
      child: lineNumberCol,
    );

    final codeField = TextField(
      keyboardType: TextInputType.visiblePassword,
      smartQuotesType: widget.smartQuotesType,
      focusNode: _focusNode,
      onTap: widget.onTap,
      scrollPadding: widget.padding,
      style: textStyle,
      controller: widget.controller,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      expands: widget.expands,
      scrollController: _codeScroll,
      decoration: InputDecoration(
        disabledBorder: InputBorder.none,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        isDense: widget.isDense,
      ),
      cursorColor: cursorColor,
      autocorrect: false,
      enableSuggestions: false,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      readOnly: widget.readOnly,
    );

    final codeCol = Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: widget.textSelectionTheme,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Control horizontal scrolling
          return widget.wrap ? codeField : _wrapInScrollView(codeField, textStyle, constraints.maxWidth);
        },
      ),
    );

    return Container(
      decoration: widget.decoration,
      color: backgroundCol,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          numberCol,
          Expanded(child: codeCol),
        ],
      ),
    );
  }
}
