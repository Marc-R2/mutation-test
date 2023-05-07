/// Copyright 2021, domohuhn.
/// License: BSD-3-Clause
/// See LICENSE for the full text of the license

import 'package:mutation_test/src/mutations/mutation.dart';
import 'package:mutation_test/src/range.dart';
import 'package:mutation_test/src/string_helpers.dart';

/// Iterator for all mutations in a given text.
class MutationIterator implements Iterator<MutatedCode> {
  MutationIterator(this.mutation, this.text, this.whitelist, this.exclusions)
      : _matches = mutation.pattern.allMatches(text).iterator;

  final Mutation mutation;
  final String text;
  final List<Range> whitelist;
  final List<Range> exclusions;
  int _index = 0;
  bool _initialized = false;

  final MutatedCode _currentMutation = MutatedCode(
    '',
    MutatedLine(0, 0, 0, '', '', Mutation('')),
  );
  final Iterator<Match> _matches;

  @override
  MutatedCode get current => _currentMutation;

  @override
  bool moveNext() {
    if (_index >= mutation.replacements.length || !_initialized) {
      var advance = true;
      _index = 0;
      while (advance) {
        if (_matches.moveNext()) {
          if (isPositionOk(whitelist, exclusions, text, _matches.current)) {
            advance = false;
            _initialized = true;
          }
        } else {
          return false;
        }
      }
    }
    _currentMutation.text =
        mutation.replacements[_index].replace(text, _matches.current);

    _currentMutation.line = createMutatedLine(
      _matches.current.start,
      _matches.current.end,
      text,
      _currentMutation.text,
      mutation,
    );

    _index += 1;
    return true;
  }

  /// Checks if a [position] in [text] is inside the whitelists or if it is excluded.
  static bool isPositionOk(
    List<Range> whitelist,
    List<Range> exclusions,
    String text,
    Match position,
  ) {
    final whitelisted = whitelist.isEmpty ||
        (isInRange(whitelist, text, position.start) &&
            isInRange(whitelist, text, position.end));
    final blacklisted = isInRange(exclusions, text, position.start) ||
        isInRange(exclusions, text, position.end);
    return whitelisted && !blacklisted;
  }

  /// Checks if a [position] in [text] is inside
  /// one of the ranges defined by [ranges].
  static bool isInRange(List<Range> ranges, String text, int position) =>
      ranges.any((ex) => ex.isInRange(text, position));

  /// Adds a mutations to the Testrunner.
  static MutatedLine createMutatedLine(
    int absoluteStart,
    int absoluteEnd,
    String original,
    String mutated,
    Mutation mutation,
  ) {
    if (absoluteStart < 0) absoluteStart = 0;
    if (absoluteStart > original.length) absoluteStart = original.length;
    if (absoluteStart > absoluteEnd) absoluteEnd = absoluteStart;
    if (absoluteEnd > original.length) absoluteEnd = original.length;

    var line = findLineFromPosition(original, absoluteStart);
    final lineStart = findBeginOfLineFromPosition(original, absoluteStart);
    final lineEnd = findEndOfLineFromPosition(original, absoluteEnd);

    // this may be false if the mutations matches the newline character and starts there.
    final mutationStart =
        lineStart <= absoluteStart ? absoluteStart - lineStart : 0;

    // if the mutations begin is on the newline character,
    // we want to add one to the line number
    if (absoluteStart + 1 == lineStart) line += 1;

    final mutationEnd = absoluteEnd - lineStart;
    final lineEndMutated =
        findEndOfLineFromPosition(mutated, lineStart + mutationEnd);

    return MutatedLine(
      line,
      mutationStart,
      mutationEnd,
      original.substring(lineStart, lineEnd),
      mutated.substring(lineStart, lineEndMutated),
      mutation,
    );
  }
}
