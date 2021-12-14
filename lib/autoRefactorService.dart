String autoRefactor(String text, String language) {
  String refactorText = "";
  refactorText = removeExtraLines(text);
  refactorText = removeExtraSpaces(refactorText, language);
  if (language == 'python') {
    refactorText = addLineBreakAfterFunctionColon(refactorText);
  }
  else {
    refactorText = addLineBreakAfterFunctionBracket(refactorText, '');
  }
  refactorText = refactorText.trimRight();
  refactorText += '\n';
  return refactorText;
}

String removeExtraLines(String text) {
  String refactorText = "";
  text = text.trim();
  final List<String> textInLines = text.split('\n');
  for (int i = 0; i < textInLines.length; i++) {
    if (textInLines[i] == '') {
      final List<String> reTextInLines = refactorText.split('\n');
      if (reTextInLines.length >= 2){
        if (reTextInLines[reTextInLines.length - 2] != ''){
            refactorText += '\n';
        }
        else if (reTextInLines[reTextInLines.length - 3] != ''){
          refactorText += '\n';
        }
      }
      else {
        refactorText += '\n';
      }
    }
    else {
      refactorText += textInLines[i] + '\n';
    }
  }
  return refactorText;
}

String removeExtraSpaces(String text, String language) {
  String refactorText = "";
  final List<String> textInLines = text.split('\n');
  final pattern = RegExp('\\s\\s+');
  bool multLine = false;
  for (int i = 0; i < textInLines.length; i++) {
    if (textInLines[i] == '') {
      refactorText += '\n';
    }
    else if (language == 'go' && textInLines[i].contains('`')) {
      //In dart, python, java, scala for multiline use """. In go use `.
      final List<String> lineSplitedQuote = textInLines[i].split('`');
      String firstQuotes;
      if (multLine) {
        firstQuotes = '';
      } 
      else {
        firstQuotes = '`';
      }
      for (int j = 0 ; j < lineSplitedQuote.length; j++) {
        if (multLine) {
          if (j < lineSplitedQuote.length - 1) {
            refactorText += firstQuotes + lineSplitedQuote[j] + '`';
            multLine = false;
          }
          else {
            refactorText += '`' + lineSplitedQuote[j];
          }
        }
        else {
          refactorText += lineSplitedQuote[j].replaceAll(pattern, ' ');
          multLine = true;
        }
      }
      refactorText += '\n';
    }
    else if (language != 'go' && (textInLines[i].contains('"""') || textInLines[i].contains('\'\'\''))) {
      //In dart, python, java, scala for multiline use """. In go use `.
      String quotes;
      int indexDoubQuote = textInLines[i].indexOf('"""');
      int indexOnlyQuote = textInLines[i].indexOf('\'\'\'');
      if (indexDoubQuote == -1) {
        quotes = '\'\'\'';
      } 
      else if (indexOnlyQuote == -1) {
        quotes = '"""';
      } 
      else {
        quotes = indexDoubQuote < indexOnlyQuote ? '"""' : '\'\'\'';
      }
      final List<String> lineSplitedQuote = textInLines[i].split(quotes);
      String firstQuotes;
      if (multLine) {
        firstQuotes = '';
      } 
      else {
        firstQuotes = quotes;
      }
      for (int j = 0 ; j < lineSplitedQuote.length; j++) {
        if (multLine) {
          if (j < lineSplitedQuote.length - 1) {
            refactorText += firstQuotes + lineSplitedQuote[j] + quotes;
            multLine = false;
          }
          else {
            refactorText += quotes + lineSplitedQuote[j];
          }
        }
        else {
          refactorText += lineSplitedQuote[j].replaceAll(pattern, ' ');
          multLine = true;
        }
      }
      refactorText += '\n';
    }
    else if (textInLines[i].contains('"') || textInLines[i].contains('\'')) {
      if (multLine) {
        refactorText += textInLines[i];
      }
      else {
        String quote;
        int indexDoubQuote = textInLines[i].indexOf('"');
        int indexOnlyQuote = textInLines[i].indexOf('\'');
        if (indexDoubQuote == -1) {
          quote = '\'';
        } 
        else if (indexOnlyQuote == -1) {
          quote = '"';
        } 
        else {
          quote = indexDoubQuote < indexOnlyQuote ? '"' : '\'';
        }
        final List<String> lineSplitedQuote = textInLines[i].split(quote);
        for (int j = 0 ; j < lineSplitedQuote.length; j++) {
          if (j % 2 == 0) {
            refactorText += lineSplitedQuote[j].replaceAll(pattern, ' ');
          }
          else {
            refactorText += quote + lineSplitedQuote[j] + quote;
          }
        }
        refactorText += '\n';
      }
    }
    else {
      if (multLine) {
        refactorText += textInLines[i] + '\n';
      }
      else {
        refactorText += textInLines[i].replaceAll(pattern, ' ') + '\n';
      }
    }
  }
  return refactorText;
}

String addLineBreakAfterFunctionBracket(String text, String intend) {
  String refactorText = "";
  //In dart, java, go, scala { is the designation of the beginning of a function
  //In python instead of the {, the : .
  final List<String> textInLines = text.split('\n');
  for (int i = 0; i < textInLines.length; i++) {
    if (textInLines[i].contains('{')) {
      int indexOfBracket = textInLines[i].indexOf('{');
      String beforeBracket = textInLines[i].substring(0, indexOfBracket+1);
      String afterBracket = textInLines[i].substring(indexOfBracket+1);
      refactorText += intend + beforeBracket + '\n' 
                            + addLineBreakAfterFunctionBracket(afterBracket, intend + '  ');
    }
    else if (textInLines[i].contains('}')) {
      int indexOfBracket = textInLines[i].indexOf('}');
      String beforeBracket = textInLines[i].substring(0, indexOfBracket);
      String afterBracket = textInLines[i].substring(indexOfBracket+1);
      String newIntend = intend.length > 2 ? intend.substring(2) : '';
      refactorText += intend + beforeBracket + '\n ' + newIntend + '}' + '\n' 
                                + addLineBreakAfterFunctionBracket(afterBracket, newIntend);
    }
    else {
      refactorText += intend + textInLines[i] + '\n';
    }
  }
  return refactorText;
}

String addLineBreakAfterFunctionColon(String text){
  String refactorText = "";
  final List<String> textInLines= text.split('\n');
  for (int i = 0; i < textInLines.length; i++) {
    if (textInLines[i].contains(':')) {
      int indexOfColon = textInLines[i].indexOf(':');
      String beforeColon = textInLines[i].substring(0, indexOfColon+1);
      String afterColon = textInLines[i].substring(indexOfColon+1);
      refactorText +=  beforeColon + '\n' + addLineBreakAfterFunctionColon(afterColon);
    }
    else {
      refactorText += textInLines[i] + '\n';
    }
  }
  return refactorText;
}