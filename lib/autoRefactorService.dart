import 'autoRefactoringSettings.dart' as refact;
import 'dart:convert';

String autoRefactor(String text, String language) {
  String refactorText = "";
  Map<String, dynamic> settings = jsonDecode(refact.settings);
  refactorText = removeExtraSpacesAndLines(text, language, settings['max_extra_lines']);
  if (language == 'python') { 
    refactorText = addLineBreakAfterFunctionColon(refactorText);
  }
  else {
    refactorText = addLineBreakAfterBracket(refactorText, '', '{}', ''.padRight(settings['intend'], ' '));
  }
  refactorText = refactorText.trimRight();
  refactorText += '\n';
  return refactorText;
}

String removeExtraSpacesAndLines(String text, String language, int maxExtraLines) {
  String refactorText = "";
  text = text.trim();
  final List<String> textInLines = text.split('\n');
  final pattern = RegExp('\\s\\s+');
  bool multLine = false;
  for (int i = 0; i < textInLines.length; i++) {
    if (textInLines[i] == '') {
      if (multLine) {
        refactorText += '\n';
      }
      else {
        final List<String> reTextInLines = refactorText.split('\n');
        if (reTextInLines.length >= maxExtraLines){
          for (int j = 1; j < maxExtraLines; j++){
            if (reTextInLines[reTextInLines.length - 1 - j] != ''){
              refactorText += '\n';
              break;
            }
          }
        }
        else {
          refactorText += '\n';
        }
      }
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
      bool open = true;
      for (int j = 0 ; j < lineSplitedQuote.length; j++) {
        if (multLine) {
          if (j < lineSplitedQuote.length - 1) {
            refactorText += firstQuotes + lineSplitedQuote[j] + '`';
            multLine = false;
            open = false;
          }
          else {
            refactorText += '`' + lineSplitedQuote[j];
          }
        }
        else {
          refactorText += lineSplitedQuote[j].replaceAll(pattern, ' ');
          if (open) multLine = true;
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
      bool open = true;
      for (int j = 0 ; j < lineSplitedQuote.length; j++) {
        if (multLine) {
          if (j < lineSplitedQuote.length - 1) {
            refactorText += firstQuotes + lineSplitedQuote[j] + quotes;
            multLine = false;
            open = false;
          }
          else {
            refactorText += quotes + lineSplitedQuote[j];
          }
        }
        else {
          refactorText += lineSplitedQuote[j].replaceAll(pattern, ' ');
          if (open) multLine = true;
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
        if (i != 0){
          if (textInLines[i - 1] == ''){
            refactorText += '\n' + textInLines[i].replaceAll(pattern, ' ') + '\n';
          }
        }
        else {
          refactorText += textInLines[i].replaceAll(pattern, ' ') + '\n';
        }
      }
    }
  }
  return refactorText;
}

String addLineBreakAfterBracket(String text, String intend, String bracket, String settings) {
  String refactorText = "";
  //In dart, java, go, scala { is the designation of the beginning of a function
  //In python instead of the {, the : .
  final List<String> textInLines = text.split('\n');
  for (int i = 0; i < textInLines.length; i++) {
    if (textInLines[i].contains(bracket[0])) {
      int indexOfBracket = textInLines[i].indexOf(bracket[0]);
      String beforeBracket = textInLines[i].substring(0, indexOfBracket + 1);
      String afterBracket = textInLines[i].substring(indexOfBracket + 1);
      refactorText += intend + beforeBracket + '\n' 
                            + addLineBreakAfterBracket(afterBracket, intend + settings, bracket, settings);
    }
    else if (textInLines[i].contains(bracket[1])) {
      int indexOfBracket = textInLines[i].indexOf(bracket[0]);
      String beforeBracket = textInLines[i].substring(0, indexOfBracket);
      String afterBracket = textInLines[i].substring(indexOfBracket + 1);
      String newIntend = intend.length > settings.length ? intend.substring(settings.length) : '';
      refactorText += intend + beforeBracket + '\n ' + newIntend + bracket[0] + '\n' 
                            + addLineBreakAfterBracket(afterBracket, newIntend, bracket, settings);
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
      String beforeColon = textInLines[i].substring(0, indexOfColon + 1);
      String afterColon = textInLines[i].substring(indexOfColon + 1);
      refactorText +=  beforeColon + '\n' + addLineBreakAfterFunctionColon(afterColon);
    }
    else {
      refactorText += textInLines[i] + '\n';
    }
  }
  return refactorText;
}