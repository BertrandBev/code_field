import 'package:highlight/highlight_core.dart';
import '../LanguagesModes/common_modes.dart';

const KEYWORD = "and elif is global as in if"
    " from raise for except finally print import pass return"
    " exec else break not with class assert yield try while continue"
    " del or def lambda async await nonlocal|10";

final python = Mode(
    refs: {
      'substringsMode': Mode(
          className: "subst",
          begin: "\\{",
          end: "\\}",
          keywords: {
            "keyword": KEYWORD,
            "built_in": "Ellipsis NotImplemented",
            "literal": "False None True",
          },
          illegal: "#",
          contains: [
            Mode(ref: 'stringsMode'),
            Mode(ref: 'numbersMode'),
            Mode(ref: 'metasMode')
          ]),
      'simpleMode': Mode(begin: "\\{\\{", relevance: 0),
      'stringsMode': Mode(className: "string", contains: [
        BACKSLASH_ESCAPE
      ], variants: [
        Mode(
            begin: "(u|b)?r?'''",
            end: "'''",
            contains: [BACKSLASH_ESCAPE, Mode(ref: 'metasMode')],
            relevance: 10),
        Mode(
            begin: "(u|b)?r?\"\"\"",
            end: "\"\"\"",
            contains: [BACKSLASH_ESCAPE, Mode(ref: 'metasMode')],
            relevance: 10),
        Mode(begin: "(fr|rf|f)'''", end: "'''", contains: [
          BACKSLASH_ESCAPE,
          Mode(ref: 'metasMode'),
          Mode(ref: 'simpleMode'),
          Mode(ref: 'substringsMode')
        ]),
        Mode(begin: "(fr|rf|f)\"\"\"", end: "\"\"\"", contains: [
          BACKSLASH_ESCAPE,
          Mode(ref: 'metasMode'),
          Mode(ref: 'simpleMode'),
          Mode(ref: 'substringsMode')
        ]),
        Mode(begin: "(u|r|ur)'", end: "\\n|'", relevance: 10),
        Mode(begin: "(u|r|ur)\"", end: "\\n|\"", relevance: 10),
        Mode(begin: "(b|br)'", end: "\\n|'"),
        Mode(begin: "(b|br)\"", end: "\\n|\""),
        Mode(begin: "(fr|rf|f)'", end: "\\n|'", contains: [
          BACKSLASH_ESCAPE,
          Mode(ref: 'simpleMode'),
          Mode(ref: 'substringsMode')
        ]),
        Mode(begin: "(fr|rf|f)\"", end: "\\n|\"", contains: [
          BACKSLASH_ESCAPE,
          Mode(ref: 'simpleMode'),
          Mode(ref: 'substringsMode')
        ]),
        APOS_STRING_MODE,
        QUOTE_STRING_MODE
      ]),
      'numbersMode': Mode(className: "number", relevance: 0, variants: [
        Mode(begin: "\\b(0b[01]+)[lLjJ]?"),
        Mode(begin: "\\b(0o[0-7]+)[lLjJ]?"),
        Mode(
            begin:
                "(-?)(\\b0[xX][a-fA-F0-9]+|(\\b\\d+(\\.\\d*)?|\\.\\d+)([eE][-+]?\\d+)?)[lLjJ]?")
      ]),
      'metasMode': Mode(className: "meta", begin: "^(>>>|\\.\\.\\.) "),
    },
    aliases: ["py", "gyp", "ipython"],
    keywords: {
      "keyword": KEYWORD,
      "built_in": "Ellipsis NotImplemented",
      "literal": "False None True",
      "type": "int str float list dict tup set bool",
    },
    illegal: "(<\\/|->|\\?)|=>",
    contains: [
      Mode(
        className: "bullet",
        begin: "\\.",
        end: "[^_A-Za-z0-9_-]",
        excludeBegin: true,
        excludeEnd: true,
      ),
      Mode(ref: 'metasMode'),
      Mode(ref: 'numbersMode'),
      Mode(beginKeywords: "if", relevance: 0),
      Mode(ref: 'stringsMode'),
      HASH_COMMENT_MODE,
      Mode(
          variants: [
            Mode(className: "function", beginKeywords: "def"),
            Mode(className: "class", beginKeywords: "class")
          ],
          end: ":",
          illegal: "[\${=;\\n,]",
          contains: [
            UNDERSCORE_TITLE_MODE,
            Mode(className: "params", begin: "\\(", end: "\\)", keywords: {
              "keyword": KEYWORD,
              "built_in": "Ellipsis NotImplemented",
              "literal": "False None True",
              "type": "int str float list dict tup set bool",
            }, contains: [
              Mode(self: true),
              Mode(ref: 'metasMode'),
              Mode(ref: 'numbersMode'),
              Mode(ref: 'stringsMode'),
              HASH_COMMENT_MODE
            ]),
            Mode(begin: "->", endsWithParent: true, keywords: "None")
          ]),
      Mode(className: "meta", begin: "^[\\t ]*@", end: "\$", contains: [
        Mode(ref: 'stringsMode'),
      ]),
      Mode(begin: "\\b(print|exec)\\(")
    ]);
