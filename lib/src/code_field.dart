import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import './code_controller.dart';

class LineNumberStyle {
  final double width;
  final TextAlign textAlign;
  final EdgeInsets padding;
  final TextStyle? textStyle;
  final Color? background;

  const LineNumberStyle({
    this.width = 42.0,
    this.textAlign = TextAlign.right,
    this.padding = const EdgeInsets.only(right: 10.0),
    this.textStyle,
    this.background,
  });
}

class CodeField extends StatefulWidget {
  final int? minLines;
  final int? maxLines;
  final bool expands;
  final CodeController controller;
  final LineNumberStyle lineNumberStyle;
  final Color? background;
  final EdgeInsets padding;
  final EdgeInsets scrollPadding;
  final Decoration? decoration;
  final TextStyle? textStyle;
  final Color? cursorColor;
  final TextSelectionThemeData? textSelectionTheme;

  const CodeField({
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
  }) : super(key: key);

  @override
  _CodeFieldState createState() => _CodeFieldState();
}

class _CodeFieldState extends State<CodeField> {
// Add a controller
  LinkedScrollControllerGroup? _controllers;
  ScrollController? _numberScroll;
  ScrollController? _codeScroll;
  TextEditingController? _numberController;
  //
  String? lines;
  String longestLine = "";

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _numberScroll = _controllers?.addAndGet();
    _codeScroll = _controllers?.addAndGet();
    _numberController = TextEditingController();
    widget.controller.addListener(_onTextChanged);
    _onTextChanged();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _numberScroll?.dispose();
    _codeScroll?.dispose();
    _numberController?.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // Rebuild line number
    final str = widget.controller.text.split("\n");
    final buf = <String>[];
    for (var k = 0; k < str.length; k++) {
      buf.add((k).toString());
    }
    _numberController?.text = buf.join("\n");
    // Find longest line
    longestLine = "";
    widget.controller.text.split("\n").forEach((line) {
      if (line.length > longestLine.length) longestLine = line;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Default color scheme
    const ROOT_KEY = 'root';
    final defaultBg = Colors.grey.shade900;
    final defaultText = Colors.grey.shade200;

    final theme = widget.controller.theme;
    Color? backgroundCol =
        widget.background ?? theme?[ROOT_KEY]?.backgroundColor ?? defaultBg;
    if (widget.decoration != null) {
      backgroundCol = null;
    }
    TextStyle textStyle = widget.textStyle ?? TextStyle();
    textStyle = textStyle.copyWith(
      color: textStyle.color ?? theme?[ROOT_KEY]?.color ?? defaultText,
      fontSize: textStyle.fontSize ?? 16.0,
    );
    TextStyle numberTextStyle = widget.lineNumberStyle.textStyle ?? TextStyle();
    final numberColor =
        (theme?[ROOT_KEY]?.color ?? defaultText).withOpacity(0.7);
    // Copy important attributes
    numberTextStyle = numberTextStyle.copyWith(
      color: numberTextStyle.color ?? numberColor,
      fontSize: textStyle.fontSize,
      fontFamily: textStyle.fontFamily,
    );
    final cursorColor =
        widget.cursorColor ?? theme?[ROOT_KEY]?.color ?? defaultText;

    final numberCol = Container(
      width: widget.lineNumberStyle.width,
      padding: widget.lineNumberStyle.padding,
      color: widget.lineNumberStyle.background,
      child: TextField(
        style: numberTextStyle,
        controller: _numberController,
        enabled: false,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        expands: widget.expands,
        scrollController: _numberScroll,
        decoration: InputDecoration(
          disabledBorder: InputBorder.none,
        ),
        textAlign: widget.lineNumberStyle.textAlign,
      ),
    );
    final codeField = TextField(
      scrollPadding: widget.scrollPadding,
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
      ),
      cursorColor: cursorColor,
      autocorrect: false,
      enableSuggestions: false,
    );
    final intrinsic = IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 0.0),
              child: Text(longestLine, style: textStyle),
            ),
          ),
          widget.expands ? Expanded(child: codeField) : codeField,
        ],
      ),
    );
    final codeCol = Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: widget.textSelectionTheme,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: intrinsic,
      ),
    );
    return Container(
      decoration: widget.decoration,
      color: backgroundCol,
      padding: widget.padding,
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
