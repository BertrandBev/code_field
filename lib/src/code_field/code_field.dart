import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import '../code_theme/code_theme.dart';
import '../line_numbers/line_number_controller.dart';
import '../line_numbers/line_number_style.dart';
import 'code_auto_complete.dart';
import 'code_controller.dart';

class CodeField extends StatefulWidget {
  /// {@macro flutter.widgets.textField.smartQuotesType}
  final SmartQuotesType? smartQuotesType;

  /// {@macro flutter.widgets.textField.smartDashesType}
  final SmartDashesType? smartDashesType;

  /// {@macro flutter.widgets.textField.keyboardType}
  final TextInputType? keyboardType;

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

  /// {@macro flutter.widgets.textField.isDense}
  final bool isDense;

  /// {@macro flutter.widgets.textField.selectionControls}
  final TextSelectionControls? selectionControls;
  final Key? fieldKey;

  /// {@macro flutter.widgets.textField.textInputAction}
  final TextInputAction? textInputAction;

  /// {@macro flutter.services.TextInputConfiguration.enableSuggestions}
  final bool enableSuggestions;
  final Color? background;
  final EdgeInsets padding;
  final Decoration? decoration;
  final TextSelectionThemeData? textSelectionTheme;
  final FocusNode? focusNode;
  final void Function()? onTap;
  final bool lineNumbers;
  final bool horizontalScroll;
  final String? hintText;
  final TextStyle? hintStyle;
  final CodeAutoComplete? autoComplete;

  const CodeField({
    Key? key,
    required this.controller,
    this.fieldKey,
    this.minLines,
    this.maxLines,
    this.expands = false,
    this.wrap = false,
    this.background,
    this.decoration,
    this.textStyle,
    this.padding = EdgeInsets.zero,
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
    this.smartQuotesType,
    this.smartDashesType,
    this.keyboardType,
    this.lineNumbers = true,
    this.horizontalScroll = true,
    this.selectionControls,
    this.hintText,
    this.hintStyle,
    this.autoComplete,
    this.textInputAction,
    this.enableSuggestions = false,
  }) : super(key: key);

  @override
  State<CodeField> createState() => _CodeFieldState();
}

class _CodeFieldState extends State<CodeField> {
  // Add a controller
  LinkedScrollControllerGroup? _controllers;
  ScrollController? _numberScroll;
  ScrollController? _codeScroll;
  LineNumberController? _numberController;

  StreamSubscription<bool>? _keyboardVisibilitySubscription;
  FocusNode? _focusNode;
  String? lines;
  String longestLine = '';
  // Track the available width of the code column in order to compute
  // visual line wrapping for line-numbers.
  double _codeColumnWidth = 0;
  var _currentTextStyle = const TextStyle();

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      createAutoComplate();
    });

    _onTextChanged();
  }

  void createAutoComplate() {
    widget.autoComplete?.show(context, widget, _focusNode!);
    widget.controller.autoComplete = widget.autoComplete;
    _codeScroll?.addListener(hideAutoComplete);
  }

  KeyEventResult _onKey(FocusNode node, RawKeyEvent event) {
    if (widget.readOnly) {
      return KeyEventResult.ignored;
    }

    return widget.controller.onKey(event);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _numberScroll?.dispose();
    _codeScroll?.dispose();
    _numberController?.dispose();
    _keyboardVisibilitySubscription?.cancel();
    widget.autoComplete?.remove();
    super.dispose();
  }

  void rebuild() {
    setState(() {});
  }

  void _onTextChanged() {
    // Rebuild line number
    final str = widget.controller.text.split('\n');
    final buf = <String>[];

    if (widget.wrap && _codeColumnWidth > 0) {
      // When wrapping is enabled we need to account for visual lines that
      // are created by the soft wrap. We measure each logical line using a
      // TextPainter and add blank placeholders so the scrolling offset of
      // the linked controllers stays in sync.
      for (var k = 0; k < str.length; k++) {
        final logicalLine = str[k];

        // Compute how many visual lines this logical line occupies.
        final tp = TextPainter(
          text: TextSpan(text: logicalLine, style: _currentTextStyle),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: _codeColumnWidth);
        final visualLines = tp.computeLineMetrics().length;

        // First visual line gets the real line number.
        buf.add((k + 1).toString());

        // Remaining visual lines get an empty placeholder so that the
        // total number of lines matches the code field.
        for (int v = 1; v < visualLines; v++) {
          buf.add('');
        }
      }
    } else {
      for (var k = 0; k < str.length; k++) {
        buf.add((k + 1).toString());
      }
    }

    _numberController?.text = buf.join('\n');

    // Find longest line
    longestLine = '';
    widget.controller.text.split('\n').forEach((line) {
      if (line.length > longestLine.length) longestLine = line;
    });

    setState(() {});
  }

  // Wrap the codeField in a horizontal scrollView
  Widget _wrapInScrollView(
    Widget codeField,
    TextStyle textStyle,
    double minWidth,
  ) {
    final leftPad = widget.lineNumberStyle.margin / 2;
    final intrinsic = IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 0,
              minWidth: max(minWidth - leftPad, 0),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(longestLine, style: textStyle),
            ), // Add extra padding
          ),
          widget.expands ? Expanded(child: codeField) : codeField,
        ],
      ),
    );

    return MediaQuery(
      // TODO: Temporary fix: https://github.com/flutter/flutter/issues/127017
      data: !kIsWeb && Platform.isIOS
          ? const MediaQueryData(
              gestureSettings: DeviceGestureSettings(touchSlop: 8),
            )
          : MediaQuery.of(context),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: leftPad,
          right: widget.padding.right,
        ),
        scrollDirection: Axis.horizontal,
        child: intrinsic,
      ),
    );
  }

  void removeAutoComplete() {
    widget.autoComplete?.remove();
  }

  void hideAutoComplete() {
    widget.autoComplete?.hide();
  }

  @override
  Widget build(BuildContext context) {
    // Default color scheme
    const rootKey = 'root';
    final defaultBg = Colors.grey.shade900;
    final defaultText = Colors.grey.shade200;

    final styles = CodeTheme.of(context)?.styles;
    Color? backgroundCol =
        widget.background ?? styles?[rootKey]?.backgroundColor ?? defaultBg;

    if (widget.decoration != null) {
      backgroundCol = null;
    }

    TextStyle textStyle = widget.textStyle ?? const TextStyle();
    textStyle = textStyle.copyWith(
      color: textStyle.color ?? styles?[rootKey]?.color ?? defaultText,
      fontSize: textStyle.fontSize ?? 16.0,
    );

    TextStyle numberTextStyle =
        widget.lineNumberStyle.textStyle ?? const TextStyle();
    final numberColor =
        (styles?[rootKey]?.color ?? defaultText).withOpacity(0.7);

    // Copy important attributes
    numberTextStyle = numberTextStyle.copyWith(
      color: numberTextStyle.color ?? numberColor,
      fontSize: textStyle.fontSize,
      fontFamily: textStyle.fontFamily,
    );

    final cursorColor =
        widget.cursorColor ?? styles?[rootKey]?.color ?? defaultText;

    TextField? lineNumberCol;
    Container? numberCol;

    if (widget.lineNumbers) {
      lineNumberCol = TextField(
        smartQuotesType: widget.smartQuotesType,
        smartDashesType: widget.smartDashesType,
        scrollPadding: widget.padding,
        style: numberTextStyle,
        controller: _numberController,
        enabled: false,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        selectionControls: widget.selectionControls,
        expands: widget.expands,
        scrollController: _numberScroll,
        decoration: InputDecoration(
          disabledBorder: InputBorder.none,
          isDense: widget.isDense,
        ),
        textAlign: widget.lineNumberStyle.textAlign,
      );

      numberCol = Container(
        width: widget.lineNumberStyle.width,
        padding: EdgeInsets.only(
          left: widget.padding.left,
          right: widget.lineNumberStyle.margin / 2,
        ),
        color: widget.lineNumberStyle.background,
        child: lineNumberCol,
      );
    }

    final codeField = TextField(
      key: widget.fieldKey,
      keyboardType: widget.keyboardType,
      smartQuotesType: widget.smartQuotesType,
      smartDashesType: widget.smartDashesType,
      focusNode: _focusNode,
      onTap: () {
        widget.autoComplete?.hide();
        widget.onTap?.call();
      },
      scrollPadding: widget.padding,
      style: textStyle,
      controller: widget.controller,
      minLines: widget.minLines,
      selectionControls: widget.selectionControls,
      maxLines: widget.maxLines,
      expands: widget.expands,
      scrollController: _codeScroll,
      decoration: InputDecoration(
        disabledBorder: InputBorder.none,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        isDense: widget.isDense,
        hintText: widget.hintText,
        hintStyle: widget.hintStyle,
      ),
      onTapOutside: (e) {
        Future.delayed(const Duration(milliseconds: 300), hideAutoComplete);
      },
      cursorColor: cursorColor,
      autocorrect: false,
      enableSuggestions: widget.enableSuggestions,
      enabled: widget.enabled,
      onChanged: (text) {
        widget.onChanged?.call(text);
        widget.autoComplete?.streamController.add(text);
      },
      readOnly: widget.readOnly,
      textInputAction: widget.textInputAction,
    );

    final codeCol = Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: widget.textSelectionTheme,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Control horizontal scrolling
          return widget.wrap
              ? codeField
              : _wrapInScrollView(codeField, textStyle, constraints.maxWidth);
        },
      ),
    );

    return Container(
      decoration: widget.decoration,
      color: backgroundCol,
      padding: !widget.lineNumbers ? const EdgeInsets.only(left: 8) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.lineNumbers && numberCol != null) numberCol,
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Save the textStyle and available width so _onTextChanged can
                // accurately compute the amount of visual lines when wrapping.
                _currentTextStyle = textStyle;
                // Subtract left padding that will be applied inside the
                // SingleChildScrollView when horizontal scrolling is disabled.
                var availableWidth = constraints.maxWidth;

                const caretMargin = 3.0; // 1 gap + 2 cursor
                availableWidth -= caretMargin;

                if ((availableWidth - _codeColumnWidth).abs() > 0.5) {
                  _codeColumnWidth = max(0, availableWidth);
                  print('availableWidth: $availableWidth');
                  // Recalculate the line numbers because wrapping may have
                  // changed due to a width change.
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _onTextChanged();
                    }
                  });
                }
                return codeCol;
              },
            ),
          ),
        ],
      ),
    );
  }
}
