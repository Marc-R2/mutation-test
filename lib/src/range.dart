/// Copyright 2021, domohuhn.
/// License: BSD-3-Clause
/// See LICENSE for the full text of the license
import 'package:mutation_test/src/string_helpers.dart';

/// A range in the source files.
abstract class Range {
  /// Checks if [position] in [text] is inside an exclusion range
  /// defined by the start and end token in this instance.
  bool isInRange(String text, int position);
}

/// A range in the source file delimited by tokens.
class TokenRange extends Range {
  TokenRange(this.startToken, this.endToken);

  final String startToken;
  final String endToken;

  /// Checks if [position] in [text] is inside an exclusion range
  /// defined by the start and end token in this instance.
  @override
  bool isInRange(String text, int position) {
    final start = findFirstTokenBeforePosition(text, position, startToken);
    if (start < 0) return false;
    final shiftEnd = endToken.length - 1;
    final end = findFirstTokenAfterPosition(text, start, endToken);
    if (end < 0 || start >= end) {
      // check if the start of the new position might be the end token of previous range
      // it may be better to search exclusion zones from start of file ...
      if (start == position &&
          position > 0 &&
          endToken.length > 1 &&
          isInRange(text, position - 1)) {
        return true;
      }
      return false;
    }
    return start <= position && position <= end + shiftEnd;
  }
}

/// A range in the source file delimited by line numbers.
class LineRange extends Range {
  LineRange(this.start, this.end);
  final int start;
  final int end;

  /// Checks if [position] in [text] is inside an exclusion range
  /// defined by the start and end token in this instance.
  @override
  bool isInRange(String text, int position) {
    final line = findLineFromPosition(text, position);
    return start <= line && line <= end;
  }
}

/// A range in the source file defined by a regex (anyhting matching the regex is excluded).
class RegexRange extends Range {
  RegexRange(this.pattern);
  final RegExp pattern;

  /// Checks if [position] in [text] is inside an exclusion range
  /// defined by the start and end token in this instance.
  @override
  bool isInRange(String text, int position) {
    for (final m in pattern.allMatches(text)) {
      if (m.start <= position && position < m.end) {
        return true;
      }
    }
    return false;
  }
}
