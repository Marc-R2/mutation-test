/// Copyright 2021, domohuhn.
/// License: BSD-3-Clause
/// See LICENSE for the full text of the license
import 'package:test/test.dart';

import '../example/source.dart';

// This file is an example for a bad test.
// It is used to generate the reports in directory example.

void main() {
  test('polynomial', () {
    expect(poly(2, 1, 4, 0), equals(12));
  });

  test('conditions first', () {
    expect(conditions(2, 2, 4), equals(6));
  });

  test('conditions second', () {
    expect(conditions(2, -3, 4), equals(5));
  });

  test('conditions third', () {
    expect(conditions(2, 3, 0), equals(6));
  });

  test('func', () {
    expect(outer(1, 1), equals(4));
  });
}
