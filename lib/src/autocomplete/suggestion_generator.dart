import 'dart:math';
import 'package:autotrie/autotrie.dart';

class SuggestionGenerator {
  RegExp identifierRegex = RegExp(r"^[_a-zA-Z][_a-zA-Z0-9]*$");
  String? languageID;

  final autoCompleteLanguage = AutoComplete(engine: SortEngine.entriesOnly());

  final autoCompleteUser = AutoComplete(engine: SortEngine.entriesOnly());
  late List<String> dictionary;

  SuggestionGenerator(this.languageID) {
    this.dictionary = [];
    initDictionary();
  }

  /// Placeholder for dictionary initialization using json resource files for the given language
  void initDictionary() async {
    this.dictionary = [
      'abstract',
      'continue',
      'for',
      'new',
      'switch',
      'assert',
      'default',
      'goto',
      'package',
      'synchronized',
      'boolean',
      'do',
      'if',
      'private',
      'this',
      'break',
      'double',
      'implements',
      'protected',
      'throw',
      'byte',
      'else',
      'import',
      'public',
      'throws',
      'case',
      'enum',
      'instanceof',
      'return',
      'transient',
      'catch',
      'extends',
      'int',
      'short',
      'try',
      'char',
      'final',
      'interface',
      'static',
      'void',
      'class',
      'finally',
      'long',
      'strictfp',
      'volatile',
      'const',
      'float',
      'native',
      'super',
      'while'
    ];

    dictionary.forEach((element) {
      autoCompleteLanguage.enter(element);
    });
  }

  List<String> getSuggestions(String text, int cursorPosition) {
    String word = _getCurrentIdentifierPrefix(text, cursorPosition);
    if (word.isEmpty) return [];
    return autoCompleteLanguage.suggest(word) + autoCompleteUser.suggest(word);
  }

  /// Returns the prefix of an identifier or a keyword that is pointed to by the cursor
  String _getCurrentIdentifierPrefix(String text, int cursorPosition) {
    String prefix = '';
    int characterPosition = cursorPosition - 1;
    while (characterPosition >= 0 &&
        identifierRegex.hasMatch(text[characterPosition])) {
      prefix = text[characterPosition] + prefix;
      characterPosition--;
    }
    return prefix;
  }

  /// Parses text - gets user keywords and addes them into user trie
  void parseText(String text) {
    List<String> list = _getKeyWords(text);
    list.forEach((element) {
      autoCompleteUser.enter(element);
    });
    filterUserKeywords(text);
  }

  /// Delete from trie keywords that are not currently in editor text
  void filterUserKeywords(String text) {
    List<String> keywords = _getKeyWords(text);
    final userKeyWords = autoCompleteUser.allEntries.toList();
    final notInText =
        userKeyWords.where((element) => !keywords.contains(element)).toList();
    notInText.forEach((element) {
      autoCompleteUser.delete(element);
    });
  }

  /// Returns keywords from text
  List<String> _getKeyWords(String text) {
    List<String> keywords = text.split(RegExp(r"[^a-zA-Z0-9][^_a-zA-Z0-9]*"));
    keywords.removeWhere((el) => el.isEmpty == true);
    keywords.removeWhere((el) => dictionary.contains(el));
    keywords.removeWhere((element) => !element.startsWith(RegExp(r"[a-zA-Z]")));
    keywords = keywords.toSet().toList();
    return keywords;
  }
}
