/// Copyright 2021, domohuhn.
/// License: BSD-3-Clause
/// See LICENSE for the full text of the license

import 'package:mutation_test/src/mutations/mutated_code.dart';

/// Wrapper to allow iteration
class IterableMutation extends Iterable<MutatedCode> {
  IterableMutation(this._itr);

  final Iterator<MutatedCode> _itr;

  @override
  Iterator<MutatedCode> get iterator => _itr;
}
