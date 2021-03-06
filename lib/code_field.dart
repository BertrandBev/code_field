import 'package:code_field/code_controller.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

class LineNumberStyle {
  final double width;
  final TextAlign textAlign;
  final EdgeInsets padding;
  final TextStyle textStyle;
  final Color background;

  const LineNumberStyle({
    this.width = 42.0,
    this.textAlign = TextAlign.right,
    this.padding = const EdgeInsets.only(right: 10.0),
    this.textStyle,
    this.background,
  });
}

class CodeField extends StatefulWidget {
  final CodeController controller;
  final LineNumberStyle lineNumberStyle;
  final Color background;
  final EdgeInsets padding;
  final Decoration decoration;
  final TextStyle textStyle;
  final Color cursorColor;
  final TextSelectionThemeData textSelectionTheme;

  const CodeField({
    Key key,
    @required this.controller,
    this.background,
    this.decoration,
    this.textStyle,
    this.padding = const EdgeInsets.all(8.0),
    this.lineNumberStyle = const LineNumberStyle(),
    this.cursorColor,
    this.textSelectionTheme,
  }) : super(key: key);

  @override
  _CodeFieldState createState() => _CodeFieldState();
}

class _CodeFieldState extends State<CodeField> {
// Add a controller
  LinkedScrollControllerGroup _controllers;
  ScrollController _numberScroll;
  ScrollController _codeScroll;
  TextEditingController _numberController;
  //
  String lines;

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _numberScroll = _controllers.addAndGet();
    _codeScroll = _controllers.addAndGet();
    _numberController = TextEditingController();
    widget.controller.addListener(_onTextChanged);
    _onTextChanged();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _numberScroll.dispose();
    _codeScroll.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // Rebuild line number
    final str = widget.controller.text.split("\n");
    final buf = <String>[];
    for (var k = 0; k < str.length; k++) {
      buf.add((k).toString());
    }
    _numberController.text = buf.join("\n");
  }

  @override
  Widget build(BuildContext context) {
    // Default color scheme
    const ROOT_KEY = 'root';
    final theme = widget.controller.theme;
    final backgroundCol = widget.background ??
        theme[ROOT_KEY]?.backgroundColor ??
        Colors.grey.shade900;
    final textStyle = widget.textStyle ??
        TextStyle(
          color: theme[ROOT_KEY]?.color ?? Colors.grey.shade800,
        );
    final numberTextStyle = widget.lineNumberStyle.textStyle ??
        TextStyle(
          color:
              (theme[ROOT_KEY]?.color ?? Colors.grey.shade800).withOpacity(0.7),
          fontSize: textStyle.fontSize,
        );
    final cursorColor =
        widget.cursorColor ?? theme[ROOT_KEY]?.color ?? Colors.grey.shade800;

    final numberCol = Container(
      width: widget.lineNumberStyle.width,
      padding: widget.lineNumberStyle.padding,
      color: widget.lineNumberStyle.background,
      child: TextField(
        style: numberTextStyle,
        controller: _numberController,
        enabled: false,
        expands: true,
        maxLines: null,
        scrollController: _numberScroll,
        decoration: InputDecoration(
          disabledBorder: InputBorder.none,
        ),
        textAlign: widget.lineNumberStyle.textAlign,
      ),
    );
    final codeCol = Expanded(
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: widget.textSelectionTheme,
        ),
        child: TextField(
          style: textStyle,
          controller: widget.controller,
          expands: true,
          maxLines: null,
          scrollController: _codeScroll,
          decoration: InputDecoration(
            disabledBorder: InputBorder.none,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          cursorColor: cursorColor,
        ),
      ),
    );

    return Container(
      decoration: widget.decoration,
      color: backgroundCol,
      padding: widget.padding,
      child: Row(
        children: [
          numberCol,
          codeCol,
        ],
      ),
    );
  }
}
