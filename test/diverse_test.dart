/// Copyright 2021, domohuhn.
/// License: BSD-3-Clause
/// See LICENSE for the full text of the license

import 'package:mutation_test/src/commands.dart';
import 'package:mutation_test/src/errors.dart';
import 'package:test/test.dart';

void main() {
  group('Diverse', () {
    test('Command - toString', () {
      final cmd = Command('original', 'make', []);
      expect(cmd.toString(), 'Command: "original"');
    });

    test('MutationError - toString', () {
      final err = MutationError('moo');
      expect(err.toString(), 'Error: moo');
    });
  });
}
