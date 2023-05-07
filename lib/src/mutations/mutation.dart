/// Copyright 2021, domohuhn.
/// License: BSD-3-Clause
/// See LICENSE for the full text of the license

import 'package:mutation_test/src/mutations/iterable_mutation.dart';
import 'package:mutation_test/src/mutations/mutation_iterator.dart';
import 'package:mutation_test/src/range.dart';
import 'package:mutation_test/src/replacements.dart';

export 'package:mutation_test/src/mutations/iterable_mutation.dart';
export 'package:mutation_test/src/mutations/mutated_code.dart';
export 'package:mutation_test/src/mutations/mutated_line.dart';
export 'package:mutation_test/src/mutations/mutation.dart';

/// A possible mutations of the source file.
///
/// Each occurence of the pattern will be replaced by one of the replacements and then the test commands are run
/// to check if the mutations is detected.
class Mutation {
  Mutation(this.pattern);

  final Pattern pattern;
  final List<Replacement> replacements = [];

  /// Iterate through [text] and replaces all matches of the pattern with every replacement.
  /// Only one match is mutated at a time and replaced with a single replacement.
  IterableMutation allMutations(
    String text,
    List<Range> whitelist,
    List<Range> exclusions,
  ) {
    return IterableMutation(
      MutationIterator(this, text, whitelist, exclusions),
    );
  }
}
