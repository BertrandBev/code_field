import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:highlight/highlight.dart';
import '../../code_text_field.dart';

/// config auto complete
class CodeAutoComplete<T> {
  /// can input your options which created through editor text and language.
  List<T> Function(String, int cursorIndex, Mode?) optionsBuilder;

  /// depends on your options, you can create your own item widget.
  final Widget Function(BuildContext, T, bool, Function(String) onTap)
      itemBuilder;

  /// set the tip panel size.
  final BoxConstraints constraints;

  /// set the tip panel background color.
  final Color? backgroundColor;

  /// the tip panel display status.
  bool isShowing = false;

  /// the tip panel current index of items.
  int current = 0;

  /// the tip panel set state function.
  void Function(void Function())? panelSetState;

  /// the code field widget.
  late CodeField widget;

  /// a getter function to get the text value from option<T>, default to toString
  String Function(T)? optionValue;

  /// the options list.
  List<T> options = [];

  /// the panel offset.
  Offset? offset;
  final StreamController streamController = StreamController.broadcast();
  Stream get stream => streamController.stream;

  CodeAutoComplete({
    required this.optionsBuilder,
    required this.itemBuilder,
    this.offset,
    this.constraints = const BoxConstraints(maxHeight: 300, maxWidth: 240),
    this.backgroundColor,
    this.optionValue,
  });

  OverlayEntry? panelOverlay;

  /// remove the tip panel.
  void remove() {
    if (panelOverlay != null) panelOverlay?.remove();
    panelOverlay = null;
  }

  /// hide the tip panel.
  void hide() {
    streamController.add(null);
  }

  /// create and show the tip panel.
  void show(BuildContext codeFieldContext, CodeField wdg, FocusNode focusNode) {
    widget = wdg;
    OverlayEntry overlayEntry = OverlayEntry(builder: (context) {
      return StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          isShowing = false;
          current = 0;
          options = optionsBuilder(
            widget.controller.text,
            widget.controller.selection.baseOffset,
            widget.controller.language,
          );
          if (!focusNode.hasFocus || options.isEmpty) return const Offstage();
          if (snapshot.hasData &&
              snapshot.data != true &&
              snapshot.data != null &&
              '${snapshot.data}'.isNotEmpty) {
            isShowing = true;
            return panelWrap(codeFieldContext, wdg, focusNode);
          } else {
            return const Offstage();
          }
        },
      );
    });

    panelOverlay = overlayEntry;
    Overlay.of(codeFieldContext).insert(overlayEntry);
  }

  /// the core widget of tip panel.
  Widget buildPanel(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: options
            .map((tip) => itemBuilder(
                context, tip, current == options.indexOf(tip), write))
            .toList(),
      ),
    );
  }

  /// write the text to code field.
  void write(String text) {
    var offset = widget.controller.selection.baseOffset;
    int start = repeatCount(widget.controller.text.substring(0, offset), text);
    widget.controller
      ..text = widget.controller.text.replaceRange(
          widget.controller.selection.baseOffset - start,
          widget.controller.selection.baseOffset,
          text)
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: offset + text.length - start));
    widget.onChanged?.call(widget.controller.text);
    hide();
  }

  /// write the current item text to code field.
  void writeCurrent() {
    if (options.isNotEmpty) {
      write(optionValue?.call(options[current]) ?? options[current].toString());
    }
  }

  /// get the repeat count of pre word and tip word.
  static int repeatCount(String text, String text2) {
    text = text.toLowerCase();
    text2 = text2.toLowerCase();
    var same = 0;
    while (text2.isNotEmpty) {
      if (text.endsWith(text2)) {
        return same += text2.length;
      }
      text2 = text2.substring(0, text2.length - 1);
    }
    return same;
  }

  /// get the panel offset through the cursor offset.
  Offset cursorOffset(
      BuildContext context, CodeField widget, FocusNode focusNode) {
    var s = widget.controller.text;
    TextStyle textStyle = widget.textStyle ?? const TextStyle();
    textStyle = textStyle.copyWith(
      fontSize: textStyle.fontSize ?? 16.0,
    );
    TextPainter painter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        style: textStyle,
        text: s.substring(0, widget.controller.selection.baseOffset),
      ),
    )..layout();
    var cursorBefore = s.substring(0, widget.controller.selection.baseOffset);
    TextPainter hpainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        style: textStyle,
        text: cursorBefore.substring(max(cursorBefore.lastIndexOf('\n'), 0)),
      ),
    )..layout();

    return Offset(focusNode.offset.dx + hpainter.width,
            focusNode.offset.dy + painter.height) +
        (offset ?? Offset.zero);
  }

  /// the style widget of tip panel.
  Widget panelWrap(BuildContext context, CodeField wdg, FocusNode focusNode) {
    Offset offset = cursorOffset(context, widget, focusNode);
    return Positioned(
        top: offset.dy,
        left: offset.dx,
        child: Material(
          elevation: 8,
          child: StatefulBuilder(builder: (context, setState) {
            panelSetState = setState;
            return background(ConstrainedBox(
              constraints: constraints,
              child: ConstrainedBox(
                constraints: constraints,
                child: buildPanel(context),
              ),
            ));
          }),
        ));
  }

  /// the style widget of tip panel.
  Widget background(Widget content) {
    if (backgroundColor != null) {
      return ColoredBox(color: backgroundColor!, child: content);
    }
    return content;
  }
}
