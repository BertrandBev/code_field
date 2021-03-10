import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import './code_controller.dart';

class LineNumberController extends TextEditingController {
  final TextSpan Function(int, TextStyle?)? lineNumberBuilder;

  LineNumberController(this.lineNumberBuilder);

  @override
  TextSpan buildTextSpan({TextStyle? style, bool? withComposing}) {
    final children = <TextSpan>[];
    text.split("\n").forEach((el) {
      final number = int.parse(el);
      var textSpan = TextSpan(text: el, style: style);
      if (lineNumberBuilder != null)
        textSpan = lineNumberBuilder!(number, style);
      children.add(textSpan);
      children.add(TextSpan(text: "\n"));
    });
    return TextSpan(children: children, style: style);
  }
}

class LineNumberStyle {
  final double width;
  final TextAlign textAlign;
  final TextStyle? textStyle;
  final Color? background;
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
  final int? minLines;
  final int? maxLines;
  final bool expands;
  final CodeController controller;
  final LineNumberStyle lineNumberStyle;
  final Color? background;
  final EdgeInsets padding;
  final Decoration? decoration;
  final TextStyle? textStyle;
  final Color? cursorColor;
  final TextSelectionThemeData? textSelectionTheme;
  final TextSpan Function(int, TextStyle?)? lineNumberBuilder;
  final int tabSpaces;

  const CodeField({
    Key? key,
    required this.controller,
    this.minLines,
    this.maxLines,
    this.expands = false,
    this.background,
    this.decoration,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(),
    this.lineNumberStyle = const LineNumberStyle(),
    this.cursorColor,
    this.textSelectionTheme,
    this.lineNumberBuilder,
    this.tabSpaces = 2,
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
  //
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

  void _insertStr(String str) {
    String text = widget.controller.text;
    TextSelection textSelection = widget.controller.selection;
    String newText =
        text.replaceRange(textSelection.start, textSelection.end, str);
    final len = str.length;
    widget.controller.text = newText;
    widget.controller.selection = textSelection.copyWith(
      baseOffset: textSelection.start + len,
      extentOffset: textSelection.start + len,
    );
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

    final lineNumberCol = TextField(
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
      ),
      textAlign: widget.lineNumberStyle.textAlign,
    );

    final numberCol = Container(
      width: widget.lineNumberStyle.width,
      padding: EdgeInsets.only(
        left: widget.padding.left,
        right: widget.lineNumberStyle.margin / 2,
      ),
      // padding: widget.lineNumberStyle.padding,
      color: widget.lineNumberStyle.background,
      child: lineNumberCol,
    );

    final codeField = TextField(
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
      ),
      cursorColor: cursorColor,
      autocorrect: false,
      enableSuggestions: false,
    );

    final codeFocus = Focus(
      child: codeField,
      onKey: (data, event) {
        if (event.isKeyPressed(LogicalKeyboardKey.tab)) {
          _insertStr(" " * widget.tabSpaces);
          return true;
        }
        return false;
      },
    );

    final intrinsic = IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0), // Add some buffer
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 0.0),
              child: Text(longestLine, style: textStyle),
            ),
          ),
          widget.expands ? Expanded(child: codeFocus) : codeFocus,
        ],
      ),
    );
    final codeCol = Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: widget.textSelectionTheme,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: widget.lineNumberStyle.margin / 2,
          right: widget.padding.right,
        ),
        scrollDirection: Axis.horizontal,
        child: intrinsic,
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
