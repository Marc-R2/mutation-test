/// Copyright 2021, domohuhn.
/// License: BSD-3-Clause
/// See LICENSE for the full text of the license

import 'package:mutation_test/src/mutations/mutated_line.dart';

/// Wrapper for the return value of the iterator.
class MutatedCode {
  MutatedCode(this.text, this.line);

  /// The full content of the mutated file
  String text;

  /// Information about the mutated line.
  MutatedLine line;
}
