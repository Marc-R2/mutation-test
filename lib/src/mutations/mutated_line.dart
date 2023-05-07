/// Copyright 2021, domohuhn.
/// License: BSD-3-Clause
/// See LICENSE for the full text of the license

import 'package:mutation_test/src/mutations/mutation.dart';
import 'package:mutation_test/src/string_helpers.dart';

/// A mutations data structure with Information about a mutated line.
class MutatedLine {
  MutatedLine(
    this.line,
    int first,
    int last,
    this.original,
    this.mutated,
    this.mutation,
  ) {
    /// make wrong states impossible to repesent
    start = first >= 0 ? first : 0;
    end = last <= original.length ? last : original.length;
  }

  /// line number in the source
  final int line;

  /// start position of the mutations in the original line
  late final int start;

  /// end position of the mutated code in the original line
  late final int end;

  /// original line of code
  final String original;

  /// mutated line of code
  final String mutated;

  final Mutation mutation;

  /// Pretty formatting
  String toMarkdown() {
    var rv = 'Line $line:<br>\n';
    rv += _formatRemoved(true);
    rv += _formatAdded(true);
    // ignore: unnecessary_string_escapes
    return rv.replaceAll('*', '\*');
  }

  /// Pretty formatting
  String toHTML() {
    var rv = 'Line $line:<br>\n';
    rv += _formatRemoved(false);
    rv += _formatAdded(false);
    return rv;
  }

  String _formatRemoved(bool escape) {
    var rv =
        '&nbsp;&nbsp;&nbsp;&nbsp;<span style="background-color: rgb(255, 200, 200);">';
    rv += '- ${_escapeChars(original.substring(0, start), escape)}';
    rv += '<span style="background-color: rgb(255, 50, 50);">';
    rv += _escapeChars(original.substring(start, end), escape);
    rv += '</span>';
    rv += _escapeChars(original.substring(end), escape);
    rv += '</span><br>\n';
    return rv;
  }

  String _formatAdded(bool escape) {
    final begin = start < mutated.length ? start : 0;
    var rv =
        '&nbsp;&nbsp;&nbsp;&nbsp;<span style="background-color: rgb(200, 255, 200);">';
    rv += '+ ${_escapeChars(mutated.substring(0, begin), escape)}';
    rv += '<span style="background-color: rgb(50, 255, 50);">';
    var mutationEnd = end + mutated.length - original.length;
    mutationEnd = mutationEnd >= begin && mutationEnd <= mutated.length
        ? mutationEnd
        : begin;
    rv += _escapeChars(mutated.substring(begin, mutationEnd), escape);
    rv += '</span>';
    rv += _escapeChars(mutated.substring(mutationEnd), escape);
    rv += '</span><br>\n';
    return rv;
  }

  /// Formats the modified code for the Html reporting.
  String formatMutatedCodeToHTML() {
    final begin = start < mutated.length ? start : 0;
    var rv = '<span class="addedLine">';
    rv += '+ ${escapeCharsForHtml(mutated.substring(0, begin))}';
    rv += '<span class="changedTokens">';
    var mutationEnd = end + mutated.length - original.length;
    mutationEnd = mutationEnd >= begin && mutationEnd <= mutated.length
        ? mutationEnd
        : begin;
    rv += escapeCharsForHtml(mutated.substring(begin, mutationEnd));
    rv += '</span>';
    rv += escapeCharsForHtml(mutated.substring(mutationEnd));
    rv += '</span>';
    return rv;
  }

  String _escapeChars(String text, bool doIt) {
    if (doIt) return convertToMarkdown(text);
    return text;
  }

  @override
  String toString() {
    return '$line: "${mutated.trim()}"';
  }
}
