import 'dart:math';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';

import 'constants/constants.dart';

late String refactorSettings;

void loadRefactorSettings() async{
  refactorSettings = await rootBundle.loadString('assets/settings/autoRefactoringSettings.json');
}

String autoRefactor(String text, String language){
  loadRefactorSettings();
  String refactorText = "";
  Map<String, dynamic> settings = jsonDecode(refactorSettings);
  List<Tuple2<String, List<Tuple2<int, int>>>> indexes;
  Tuple2<String, List<Tuple2<String, List<Tuple2<int, int>>>>> result = removeExtraSpacesAndLines(text, 
                                                                      language, int.parse(settings['max_extra_lines']), false);
  refactorText = result.item1;
  indexes = result.item2;
  refactorText = refactorText.trimRight();
  final List<String> textInLines = refactorText.split('\n');
  result = addLineBreakAfterBracket(textInLines, '', settings['linebreak_after_this_brackets'], 
                                                                      ''.padRight(int.parse(settings['intend']), ' '), indexes);
  refactorText = result.item1;
  indexes = result.item2;                                                                    
  if (language == python) { 
    refactorText = addLineBreakAfterFunctionColon(refactorText, ''.padRight(int.parse(settings['intend'])), indexes);
  }
  refactorText = refactorText.trimRight();
  if (settings['add_line_at_the_end'] == "true"){
    refactorText += '\n ';
  }
  return refactorText;
}

List<dynamic> multilineFunctions(String text, String firstQuotes, String quote, bool multiline, String language, int maxExtraLines){
  final List<String> lineSplitedQuote = text.split(quote);
  List<Tuple2<int, int>> indexesOfline = [];
  String refactorText = '';
  int beforeIndex = 0;
  for (int j = 0 ; j < lineSplitedQuote.length; j++){
    String newLine;
    if (multiline) {
      if (j < lineSplitedQuote.length - 1) {
        newLine = firstQuotes + lineSplitedQuote[j] + quote;
        multiline = false;
      }
      else {
        newLine = quote + lineSplitedQuote[j];
      }
      indexesOfline.add(Tuple2(beforeIndex, beforeIndex + newLine.length - 1));
    }
    else {
      Tuple2<String, List<Tuple2<String, List<Tuple2<int, int>>>>> result = 
                                                removeExtraSpacesAndLines(lineSplitedQuote[j], language, maxExtraLines, true);
      newLine = result.item1;
      for (int z = 0; z < result.item2[0].item2.length; z++){
        indexesOfline.add(Tuple2(beforeIndex + result.item2[0].item2[z].item1, beforeIndex + result.item2[0].item2[z].item2));
      }
      multiline = true;
    }
    refactorText += newLine;
    beforeIndex += newLine.length;
  }
  return [refactorText, multiline, indexesOfline];
}

Tuple2<String, List<Tuple2<String, List<Tuple2<int, int>>>>> removeExtraSpacesAndLines(String text, String language, 
                                                                  int maxExtraLines, bool oneLine){
  List<Tuple2<String, List<Tuple2<int, int>>>> indexes = [];
  String refactorText = "";
  text = text.trim();
  final List<String> textInLines = text.split('\n');
  final pattern = RegExp('\\s\\s+');
  final singleQuotePattern = RegExp(r"[^\\]'|^'");
  final doubleQuotePattern = RegExp(r'[^\\]"|^"');
  bool multiline = false;
  for (int i = 0; i < textInLines.length; i++) {
    if (textInLines[i] == '' || textInLines[i].trim() == '') {
      if (multiline) {
        refactorText += '\n';
        indexes.add(Tuple2(multline, []));
      }
      else {
        final List<String> reTextInLines = refactorText.split('\n');
        if (reTextInLines.length >= maxExtraLines){
          for (int j = 0; j < maxExtraLines; j++){
            if (reTextInLines[reTextInLines.length - 2 - j] != ''){
              refactorText += '\n';
              indexes.add(Tuple2(simple, []));
              break;
            }
          }
        }
        else {
          refactorText += (oneLine ? '' : '\n');
          indexes.add(Tuple2(simple, []));
        }
      }
    }
    else if (language == go && textInLines[i].contains('`')){
      //In dart, python, java, scala for multiline use """. In go use `.
      String firstQuotes;
      if (multiline) {
        firstQuotes = '';
      } 
      else {
        firstQuotes = '`';
      }
      List<dynamic> result = multilineFunctions(textInLines[i], firstQuotes, '`', multiline, language, maxExtraLines);
      multiline = result[1];
      indexes.add(Tuple2(haveString,result[2]));
      refactorText += result[0] + (oneLine ? '' : '\n');
    }
    else if (language != go && (textInLines[i].contains('"""') || textInLines[i].contains('\'\'\''))){
      //In dart, python, java, scala for multiline use """. In go use `.
      String quote;
      int indexDoubQuote = textInLines[i].indexOf('"""');
      int indexSingleQuote = textInLines[i].indexOf('\'\'\'');
      if (indexDoubQuote == -1) {
        quote = '\'\'\'';
      } 
      else if (indexSingleQuote == -1){
        quote = '"""';
      } 
      else {
        quote = indexDoubQuote < indexSingleQuote ? '"""' : '\'\'\'';
      }
      String firstQuotes;
      if (multiline){
        firstQuotes = '';
      } 
      else {
        firstQuotes = quote;
      }
      List<dynamic> result = multilineFunctions(textInLines[i], firstQuotes, quote, multiline, language, maxExtraLines);
      multiline = result[1];
      indexes.add(Tuple2(haveString,result[2]));
      refactorText += result[0] + (oneLine ? '' : '\n');
    }
    else if (textInLines[i].contains(doubleQuotePattern) || textInLines[i].contains(singleQuotePattern)){
      if (multiline){
        refactorText += textInLines[i];
      }
      else {
        RegExp singleQuoteRex1 = RegExp(r"[^\\]'");
        RegExp singleQuoteRex2 = RegExp(r"^'");
        RegExp doubleQuoteRex1 = RegExp(r'[^\\]"');
        RegExp doubleQuoteRex2 = RegExp(r'^"');
        
        RegExp fullOtherRegex;
        RegExp regex1;
        RegExp regex2;
        String quote;

        int indexDoubleQuote1 = textInLines[i].indexOf(doubleQuoteRex1);
        int indexDoubleQuote2 = textInLines[i].indexOf(doubleQuoteRex2);
        int indexDoubQuote = indexDoubleQuote2 == -1 ? (indexDoubleQuote1 == -1 ? -1 : indexDoubleQuote1 + 1) : indexDoubleQuote2;

        int indexSingleQuote1 = textInLines[i].indexOf(singleQuoteRex1);
        int indexSingleQuote2 = textInLines[i].indexOf(singleQuoteRex2);
        int indexSingleQuote = indexSingleQuote2 == -1 ? (indexSingleQuote1 == -1 ? -1 : indexSingleQuote1 + 1) : indexSingleQuote2;

        if (indexDoubQuote == -1) {
          quote = "'";
        } 
        else if (indexSingleQuote == -1) {
          quote = '"';
        } 
        else {
          quote = indexDoubQuote < indexSingleQuote ? '"' : "'";
        }
        regex1 = quote == '"' ? doubleQuoteRex1 : singleQuoteRex1;
        regex2 = quote == '"' ? doubleQuoteRex2 : singleQuoteRex2;
        fullOtherRegex = quote == '"' ? singleQuotePattern : doubleQuotePattern;

        List<Tuple2<int, int>> indexesOfline = [];
        int beforeIndex = 0;
        int firstIndex = quote == '\''? indexSingleQuote : indexDoubQuote;
        int secondIndex = textInLines[i].indexOf(regex1, firstIndex + 1);
        secondIndex = secondIndex == -1 ? textInLines[i].indexOf(regex2, firstIndex + 1) : secondIndex + 1;

        while (firstIndex != -1 && secondIndex != -1){
          String lineBeforeQuote = textInLines[i].substring(beforeIndex, firstIndex).replaceAll(pattern, ' ');
          if (lineBeforeQuote.contains(fullOtherRegex)){
            Tuple2<String, List<Tuple2<String, List<Tuple2<int, int>>>>> result = 
                                                          removeExtraSpacesAndLines(lineBeforeQuote, language, maxExtraLines, true);
            for (int z = 0; z < result.item2[0].item2.length; z++){
              indexesOfline.add(Tuple2(beforeIndex + result.item2[0].item2[z].item1, beforeIndex + result.item2[0].item2[z].item2));
            }
          }
          refactorText += lineBeforeQuote;

          String lineInQuotes = textInLines[i].substring(firstIndex + 1, secondIndex);
          indexesOfline.add(Tuple2(firstIndex, secondIndex));
          refactorText += quote + lineInQuotes + quote;

          beforeIndex += lineBeforeQuote.length + lineInQuotes.length + 2;
          firstIndex = textInLines[i].indexOf(regex1, secondIndex + 1);
          firstIndex = firstIndex == -1 ? textInLines[i].indexOf(regex2, secondIndex + 1) : firstIndex + 1;
          if (firstIndex != -1) {
            secondIndex = textInLines[i].indexOf(regex1, firstIndex + 1);
            secondIndex = secondIndex == -1 ? textInLines[i].indexOf(regex2, firstIndex + 1) : secondIndex + 1;
          }
        }

        indexes.add(Tuple2(haveString,indexesOfline));
        refactorText += (oneLine ? '' : '\n');
      }
    }
    else {
      if (multiline){
        refactorText += textInLines[i] + '\n';
        indexes.add(Tuple2(multline, []));
      }
      else {
        refactorText += textInLines[i].trim().replaceAll(pattern, ' ') + (oneLine ? '' : '\n');
        indexes.add(Tuple2(simple, []));
      }
    }
  }
  return Tuple2(refactorText, indexes);
}

Tuple2<bool, int> symbolContains(String bracket, String text, Tuple2<String, List<Tuple2<int, int>>> indexesOfString){
  if (indexesOfString.item1 == multline){
    return Tuple2(false, -1);
  }
  if (!text.contains(bracket)){
    return Tuple2(false, -1);
  }
  if (indexesOfString.item1 == simple){
    return Tuple2(true, text.indexOf(bracket));
  }
  List<int> indexesOfBracket= [];
  int index = 0;
  while(index != -1){
    index = text.indexOf(bracket, index);
    if (index != -1){
      indexesOfBracket.add(index);
      index +=1;
    }
  }
  for (int i = 0; i < indexesOfBracket.length; i++){
    bool insideString = false;
    for (int j = 0; j < indexesOfString.item2.length; j++){
      if (indexesOfBracket[i] >= indexesOfString.item2[j].item1 && indexesOfBracket[i] <= indexesOfString.item2[j].item2){
        insideString = true;
        break;
      }
    }
    if (!insideString){
      return Tuple2(true, indexesOfBracket[i]);
    }
  }
  return Tuple2(false, -1);
}

Tuple2<String, List<Tuple2<String, List<Tuple2<int, int>>>>> addLineBreakAfterBracket(List<String> textInLines, String intend, List<dynamic> brackets, String settings,
                                          List<Tuple2<String, List<Tuple2<int, int>>>> indexesOfStrings){
  //In dart, java, go, scala { is the designation of the beginning of a function.
  //In python instead of the {, the : .
  String text = textInLines.join('\n');
  if (brackets.isEmpty) {
    return Tuple2(text, indexesOfStrings);
  }
  List<int> indexes = [];
  for (int i = 0; i < brackets.length; i++){
    int firstIndex;
    int secondIndex;
    for (int j = 0; j < textInLines.length; j++){
      firstIndex = symbolContains(brackets[i][0], textInLines[j], indexesOfStrings[j]).item2;
      secondIndex = symbolContains(brackets[i][1], textInLines[j], indexesOfStrings[j]).item2;
      if (firstIndex != -1) {
        firstIndex += textInLines.sublist(0, j).join().length;
      }
      if (secondIndex != -1) {
        secondIndex += textInLines.sublist(0, j).join().length;
      }
      if (firstIndex != -1 && secondIndex != -1){
        indexes.add(firstIndex<secondIndex ? firstIndex : secondIndex);
        break;
      }
      else if (firstIndex != -1){
        indexes.add(firstIndex);
        break;
      }
      else if (secondIndex != -1){
        indexes.add(secondIndex);
        break;
      }
    }
    if (indexes.length != i + 1){
      indexes.add(-1);
    }
  }
  int min = indexes.reduce(max);
  int indexOfmin = indexes.indexOf(min);
  for (int i = 0;i < indexes.length; i++){
    if (indexes[i] < min && indexes[i] != -1){
      min = indexes[i];
      indexOfmin = i;
    }
  }
  String bracket = brackets[indexOfmin];

  String refactorText = "";
  List<Tuple2<String, List<Tuple2<int, int>>>> newIndexesOfStrings = [];
  int i = 0;

  while(textInLines.length - i > 0){
    Tuple2<bool, int> containsFirstBracket = symbolContains(bracket[0], textInLines[i], indexesOfStrings[i]);
    Tuple2<bool, int> containsSecondBracket = symbolContains(bracket[1], textInLines[i], indexesOfStrings[i]);

    if (containsFirstBracket.item1 && (containsSecondBracket.item2 == -1 || containsFirstBracket.item2 < containsSecondBracket.item2)) {
      int indexOfBracket = containsFirstBracket.item2;
      String beforeBracket = textInLines[i].substring(0, indexOfBracket + 1);
      String afterBracket = textInLines[i].substring(indexOfBracket + 1);

      List<String> linesWithAfterBracket = textInLines.sublist(i + 1);
      List<Tuple2<String, List<Tuple2<int, int>>>> indexesOfStringsWithAfterBracket = indexesOfStrings.sublist(i + 1);
      
      List<Tuple2<int, int>> indexesForBeforeBracket = [];
      for (int j = 0; j < indexesOfStrings[i].item2.length; j++){
        if (indexesOfStrings[i].item2[j].item2 < indexOfBracket){
          indexesForBeforeBracket.add(indexesOfStrings[i].item2[j]);
        }
      }
      newIndexesOfStrings.add(Tuple2(indexesForBeforeBracket.isNotEmpty ? haveString : simple, indexesForBeforeBracket));

      if (afterBracket.trim() != '') {
        linesWithAfterBracket.insert(0, afterBracket);
        List<Tuple2<int, int>> indexesForAfterBracket = [];
        for (int j = 0; j < indexesOfStrings[i].item2.length; j++){
          if (indexesOfStrings[i].item2[j].item1 > indexOfBracket){
            indexesForAfterBracket.add(Tuple2(indexesOfStrings[i].item2[j].item1 - indexOfBracket - 1, 
                                                          indexesOfStrings[i].item2[j].item2 - indexOfBracket - 1));
          }
        }
        indexesOfStringsWithAfterBracket.insert(0,Tuple2(indexesForAfterBracket.isNotEmpty ? 
                                                          haveString : simple, indexesForAfterBracket));
      }
      Tuple2<String, List<Tuple2<String, List<Tuple2<int, int>>>>> result = 
            addLineBreakAfterBracket(linesWithAfterBracket, intend + settings, brackets, settings, indexesOfStringsWithAfterBracket);
      refactorText += intend + beforeBracket + '\n' + result.item1;
      newIndexesOfStrings.addAll(result.item2);
      return Tuple2(refactorText, newIndexesOfStrings);
    }
    else if (containsSecondBracket.item1){
      int indexOfBracket = containsSecondBracket.item2;
      String beforeBracket = textInLines[i].substring(0, indexOfBracket);
      String afterBracket = textInLines[i].substring(indexOfBracket + 1);
      String newIntend = intend.length > settings.length ? intend.substring(settings.length) : '';

      List<String> linesWithAfterBracket = textInLines.sublist(i + 1);
      List<Tuple2<String, List<Tuple2<int, int>>>> indexesOfStringsWithAfterBracket = indexesOfStrings.sublist(i + 1);

      List<Tuple2<int, int>> indexesForBeforeBracket = [];
      for (int j = 0; j < indexesOfStrings[i].item2.length; j++){
        if (indexesOfStrings[i].item2[j].item2 < indexOfBracket){
          indexesForBeforeBracket.add(indexesOfStrings[i].item2[j]);
        }
      }
      newIndexesOfStrings.add(Tuple2(indexesForBeforeBracket.isNotEmpty ? haveString : simple, indexesForBeforeBracket));

      if (afterBracket.trim() != ''){
        linesWithAfterBracket.insert(0, afterBracket);
        List<Tuple2<int, int>> indexesForAfterBracket = [];
        for (int j = 0; j < indexesOfStrings[i].item2.length; j++){
          if (indexesOfStrings[i].item2[j].item1 > indexOfBracket){
            indexesForAfterBracket.add(Tuple2(indexesOfStrings[i].item2[j].item1 - indexOfBracket - 1, 
                                                          indexesOfStrings[i].item2[j].item2 - indexOfBracket - 1));
          }
        }
        indexesOfStringsWithAfterBracket.insert(0,Tuple2(indexesForAfterBracket.isNotEmpty ? 
                                                          haveString : simple, indexesForAfterBracket));
      }

      Tuple2<String, List<Tuple2<String, List<Tuple2<int, int>>>>> result = addLineBreakAfterBracket(linesWithAfterBracket, newIntend, brackets, settings, indexesOfStringsWithAfterBracket);
      if (beforeBracket.trim() == ''){
        refactorText += newIntend + bracket[1] + '\n' + result.item1;
      }
      else {
        refactorText += intend + beforeBracket + '\n ' + newIntend + bracket[1] + '\n' + result.item1;
      }
      newIndexesOfStrings.addAll(result.item2);
      
      return Tuple2(refactorText, newIndexesOfStrings);
    }
    else {
      if (indexesOfStrings[i].item1 != multline){
        int lengthOfIntend = textInLines[i].length - textInLines[i].trimLeft().length;
        List<Tuple2<int, int>> indexesForBeforeBracket = [];
        for (int j = 0; j < indexesOfStrings[i].item2.length; j++){
          indexesForBeforeBracket.add(Tuple2(indexesOfStrings[i].item2[j].item1 - lengthOfIntend + intend.length, 
                                              indexesOfStrings[i].item2[j].item2 - lengthOfIntend + intend.length));
        }
        newIndexesOfStrings.add(Tuple2(indexesForBeforeBracket.isNotEmpty ? haveString : simple, indexesForBeforeBracket));

        refactorText += intend + textInLines[i].trimLeft() + '\n';
      }
      else {
        refactorText += textInLines[i] + '\n';
        newIndexesOfStrings.add(indexesOfStrings[i]);
      }
      i++;
    }
  }
  return Tuple2(refactorText, newIndexesOfStrings);
}

String addLineBreakAfterFunctionColon(String text, String intend, List<Tuple2<String, List<Tuple2<int, int>>>> indexesOfStrings){
  String refactorText = "";
  text = text.trimRight();
  final List<String> textInLines= text.split('\n');
  for (int i = 0; i < textInLines.length; i++){
    Tuple2<bool, int> containsColon = symbolContains(':', textInLines[i], indexesOfStrings[i]);
    if (containsColon.item1) {
      int indexOfColon = containsColon.item2;
      String beforeColon = textInLines[i].substring(0, indexOfColon + 1);
      String afterColon = textInLines[i].substring(indexOfColon + 1);
      List<Tuple2<String, List<Tuple2<int, int>>>> indexesForAfterColonList = [];
      if (afterColon.trim() != ''){
        List<Tuple2<int, int>> indexesForAfterColon = [];
        for (int j = 0; j < indexesOfStrings[i].item2.length; j++){
          if (indexesOfStrings[i].item2[j].item1 > indexOfColon){
            indexesForAfterColon.add(Tuple2(indexesOfStrings[i].item2[j].item1 - indexOfColon - 1, indexesOfStrings[i].item2[j].item2 - indexOfColon - 1));
          }
        }
        indexesForAfterColonList.add(Tuple2(indexesForAfterColon.isNotEmpty ? haveString : simple, indexesForAfterColon));
        refactorText +=  beforeColon + '\n' + intend + addLineBreakAfterFunctionColon(afterColon, intend, indexesForAfterColonList);
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
