class SuggestionGenerator {
  RegExp identifierRegex = RegExp(r"^[_a-zA-Z][_a-zA-Z0-9]*$");
  String? languageID;

  //TODO: replace with a trie
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
  }

  // TODO: implement using tries
  List<String> getSuggestions(String text, int cursorPosition) {
    String word = _getCurrentIdentifierPrefix(text, cursorPosition);
    if (word.isEmpty) return [];
    return dictionary.where((item) => item.startsWith(word)).toList();
  }

  /// Returns the prefix of an identifier or a keyword that is pointed to by the cursor
  String _getCurrentIdentifierPrefix(String text, int cursorPosition) {
    String prefix = '';
    int characterPosition = cursorPosition - 1;
    while (characterPosition >= 0 &&
        identifierRegex.hasMatch(text[characterPosition] + prefix)) {
      prefix = text[characterPosition] + prefix;
      characterPosition--;
    }
    return prefix;
  }
}
