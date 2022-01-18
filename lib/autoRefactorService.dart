import 'dart:math';

import 'autoRefactoringSettings.dart' as refact;
import 'dart:convert';

String autoRefactor(String text, String language){
  String refactorText = "";
  Map<String, dynamic> settings = jsonDecode(refact.settings);
  refactorText = removeExtraSpacesAndLines(text, language, int.parse(settings['max_extra_lines']));
  refactorText = refactorText.trimRight();
  final List<String> textInLines = refactorText.split('\n');
  refactorText = addLineBreakAfterBracket(textInLines, '', 
                          settings['linebreak_after_this_brackets'], ''.padRight(int.parse(settings['intend']), ' '));
  if (language == 'python') { 
    refactorText = addLineBreakAfterFunctionColon(refactorText, ''.padRight(int.parse(settings['intend'])));
  }
  refactorText = refactorText.trimRight();
  if (settings['add_line_at_the_end'] == "true"){
    refactorText += '\n ';
  }
  return refactorText;
}

String removeExtraSpacesAndLines(String text, String language, int maxExtraLines){
  String refactorText = "";
  text = text.trim();
  final List<String> textInLines = text.split('\n');
  final pattern = RegExp('\\s\\s+');
  bool multLine = false;
  for (int i = 0; i < textInLines.length; i++) {
    if (textInLines[i] == '' || textInLines[i].trim() == '') {
      if (multLine) {
        refactorText += '\n';
      }
      else {
        final List<String> reTextInLines = refactorText.split('\n');
        if (reTextInLines.length >= maxExtraLines){
          for (int j = 0; j < maxExtraLines; j++){
            if (reTextInLines[reTextInLines.length - 2 - j] != ''){
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
    else if (language == 'go' && textInLines[i].contains('`')){
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
      for (int j = 0 ; j < lineSplitedQuote.length; j++){
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
          refactorText += ' ' + lineSplitedQuote[j].trim().replaceAll(pattern, ' ') + ' ';
          if (open) multLine = true;
        }
      }
      refactorText += '\n';
    }
    else if (language != 'go' && (textInLines[i].contains('"""') || textInLines[i].contains('\'\'\''))){
      //In dart, python, java, scala for multiline use """. In go use `.
      String quotes;
      int indexDoubQuote = textInLines[i].indexOf('"""');
      int indexOnlyQuote = textInLines[i].indexOf('\'\'\'');
      if (indexDoubQuote == -1) {
        quotes = '\'\'\'';
      } 
      else if (indexOnlyQuote == -1){
        quotes = '"""';
      } 
      else {
        quotes = indexDoubQuote < indexOnlyQuote ? '"""' : '\'\'\'';
      }
      final List<String> lineSplitedQuote = textInLines[i].split(quotes);
      String firstQuotes;
      if (multLine){
        firstQuotes = '';
      } 
      else {
        firstQuotes = quotes;
      }
      bool open = true;
      for (int j = 0 ; j < lineSplitedQuote.length; j++){
        if (multLine){
          if (j < lineSplitedQuote.length - 1){
            refactorText += firstQuotes + lineSplitedQuote[j] + quotes;
            multLine = false;
            open = false;
          }
          else {
            refactorText += quotes + lineSplitedQuote[j];
          }
        }
        else {
          refactorText += ' ' + lineSplitedQuote[j].trim().replaceAll(pattern, ' ') + ' ';
          if (open) multLine = true;
        }
      }
      refactorText += '\n';
    }
    else if (textInLines[i].contains('"') || textInLines[i].contains('\'')){
      if (multLine){
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
        for (int j = 0 ; j < lineSplitedQuote.length; j++){
          if (j % 2 == 0) {
            refactorText += ' ' + lineSplitedQuote[j].trim().replaceAll(pattern, ' ') + ' ';
          }
          else {
            refactorText += quote + lineSplitedQuote[j] + quote;
          }
        }
        refactorText += '\n';
      }
    }
    else {
      if (multLine){
        refactorText += textInLines[i] + '\n';
      }
      else {
        refactorText += textInLines[i].trim().replaceAll(pattern, ' ') + '\n';
      }
    }
  }
  return refactorText;
}

String addLineBreakAfterBracket(List<String> textInLines, String intend, List<dynamic> brackets, String settings){
  //In dart, java, go, scala { is the designation of the beginning of a function
  //In python instead of the {, the : .
  textInLines.removeLast();
  String text = textInLines.join('\n');
  if (brackets.length < 1) {
    return text;
  }
  List<int> indexes = [];
  for (int i = 0; i < brackets.length; i++){
    int firstIndex = text.indexOf(brackets[i][0]);
    int secondIndex = text.indexOf(brackets[i][1]);
    if (firstIndex != -1 && secondIndex != -1){
      indexes.add(firstIndex<secondIndex ? firstIndex : secondIndex);
    }
    else if (firstIndex != -1){
      indexes.add(firstIndex);
    }
    else{
      indexes.add(secondIndex);
    }
  }
  int min = indexes.reduce(max);
  int indexOfmin = 0;
  for (int i = 0;i < indexes.length; i++){
    if (indexes[i] < min && indexes[i] != -1){
      min = indexes[i];
      indexOfmin = i;
    }
  }
  String bracket = brackets[indexOfmin];
  
  String refactorText = "";
  int i = 0;
  while(textInLines.length - i > 0){
    if (textInLines[i].contains(bracket[0])) {
      int indexOfBracket = textInLines[i].indexOf(bracket[0]);
      String beforeBracket = textInLines[i].substring(0, indexOfBracket + 1);
      String afterBracket = textInLines[i].substring(indexOfBracket + 1);
      List<String> subList = textInLines.sublist(i+1);
      List<String> subListWithAfterBracket = subList;
      if (afterBracket.trim() != '')
        subListWithAfterBracket.insert(0, afterBracket);
      if (afterBracket.trim() == ''){
        refactorText += intend + beforeBracket + '\n'
                            + addLineBreakAfterBracket(subList, intend + settings, brackets, settings);
      }
      else {
        refactorText += intend + beforeBracket + '\n' 
              + addLineBreakAfterBracket(subListWithAfterBracket, intend + settings, brackets, settings);
      }
      return refactorText;
    }
    else if (textInLines[i].contains(bracket[1])){
      int indexOfBracket = textInLines[i].indexOf(bracket[1]);
      String beforeBracket = textInLines[i].substring(0, indexOfBracket);
      String afterBracket = textInLines[i].substring(indexOfBracket + 1);
      String newIntend = intend.length > settings.length ? intend.substring(settings.length) : '';
      List<String> subList = textInLines.sublist(i+1);
      List<String> subListWithAfterBracket = subList;
      if (afterBracket.trim() != ''){
        subListWithAfterBracket.insert(0, afterBracket);
      }
      if (beforeBracket.trim() == ''){
        if (afterBracket.trim() == ''){
          refactorText += newIntend + bracket[1] + '\n'
                            + addLineBreakAfterBracket(subList, newIntend, brackets, settings);
        }
        else {
          refactorText += newIntend + bracket[1] + '\n' 
                + addLineBreakAfterBracket(subListWithAfterBracket, newIntend, brackets, settings);
        }
      }
      else {
        if (afterBracket.trim() == '') {
          refactorText += intend + beforeBracket + '\n ' + newIntend + bracket[1] + '\n'
                             + addLineBreakAfterBracket(subList, newIntend, brackets, settings);
        }
        else {
          refactorText += intend + beforeBracket + '\n ' + newIntend + bracket[1] + '\n' 
                + addLineBreakAfterBracket(subListWithAfterBracket, newIntend, brackets, settings);
        }
      }
      return refactorText;
    }
    else {
      refactorText += intend + textInLines[i].trimLeft() + '\n';
      i++;
    }
  }
  return refactorText;
}

String addLineBreakAfterFunctionColon(String text, String intend){
  String refactorText = "";
  final List<String> textInLines= text.split('\n');
  for (int i = 0; i < textInLines.length; i++){
    if (textInLines[i].contains(':')) {
      int indexOfColon = textInLines[i].indexOf(':');
      String beforeColon = textInLines[i].substring(0, indexOfColon + 1);
      String afterColon = textInLines[i].substring(indexOfColon + 1);
      if (afterColon.trim() != ''){
        refactorText +=  beforeColon + '\n' + intend + addLineBreakAfterFunctionColon(afterColon, intend);
      }
      else {
        refactorText += textInLines[i] + '\n';
      }
    }
    else {
      refactorText += textInLines[i] + '\n';
    }
  }
  return refactorText;
}