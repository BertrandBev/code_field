// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:highlight/src/mode.dart';
import 'package:highlight/src/common_modes.dart';

const KEYWORD = "break default func interface select case map struct chan"
    " else goto package switch const fallthrough if range type continue for"
    " import return var go defer";

const TYPE = "var int8 int16 int32 int64 uint8 uint16 uint32 uint64 uintptr"
    " byte rune int uint float32 float64 complex64 complex128 bool string";

const BUILT_IN = "append cap close complex copy imag len make new"
    " panic print println real recover delete";

final go = Mode(
    refs: {},
    aliases: ["golang"],
    keywords: {
      "keyword": KEYWORD,
      "literal": "true false iota nil",
      "built_in": BUILT_IN,
      "type" : TYPE
    },
    illegal: "</",
    contains: [
      C_LINE_COMMENT_MODE,
      C_BLOCK_COMMENT_MODE,
      Mode(className: "string", variants: [
        QUOTE_STRING_MODE,
        APOS_STRING_MODE,
        Mode(begin: "`", end: "`")
      ]),
      Mode(className: "number", variants: [
        Mode(
            begin:
                "(-?)(\\b0[xX][a-fA-F0-9]+|(\\b\\d+(\\.\\d*)?|\\.\\d+)([eE][-+]?\\d+)?)[i]",
            relevance: 1),
        C_NUMBER_MODE
      ]),
      Mode(begin: ":="),
      Mode(
        className: "bullet",
        begin: "\\.",
        end: "[^_A-Za-z0-9_-]",
        excludeBegin: true,
        excludeEnd: true,
      ),
      Mode(
          className: "function",
          beginKeywords: "func",
          end: "\\s*(\\{|\$)",
          excludeEnd: true,
          contains: [
            TITLE_MODE,
            Mode(
                className: "params",
                begin: "\\(",
                end: "\\)",
                keywords: {
                  "keyword": KEYWORD,
                  "literal": "true false iota nil",
                  "built_in": BUILT_IN,
                },
                illegal: "[\"']")
          ])
    ]);
