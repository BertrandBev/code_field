import 'package:code_text_field/code_text_field.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test write back pre function.', () {
    var c = CodeAutoComplete.repeatCount('MA', 'MATCH');
    expect(c, 2);
  });
}
