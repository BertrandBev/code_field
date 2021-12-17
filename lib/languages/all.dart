import 'go.dart';
import 'java.dart';
import 'python.dart';
import 'scala.dart';

final builtinLanguages = {
  'go': go,
  'java': java,
  'python': python,
  'scala': scala,
};
final allLanguages = {...builtinLanguages};
