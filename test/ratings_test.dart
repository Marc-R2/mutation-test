/// Copyright 2021, domohuhn.
/// License: BSD-3-Clause
/// See LICENSE for the full text of the license

import 'package:mutation_test/src/ratings.dart';
import 'package:test/test.dart';

void main() {
  test('Rating - Empty ', () {
    final ratings = Ratings();
    expect(ratings.isSuccessful(100), true);
    expect(ratings.isSuccessful(99.999), false);
    expect(ratings.rating(100), 'N/A');
  });

  test('Rating - Threshold', () {
    final ratings = Ratings();
    ratings.failure = 50.0;
    expect(ratings.isSuccessful(100), true);
    expect(ratings.isSuccessful(51), true);
    expect(ratings.isSuccessful(49.999), false);
  });

  test('Rating - get rating', () {
    final ratings = Ratings();
    ratings.addRating(0, 'F');
    ratings.addRating(100, 'A');
    ratings.addRating(80, 'B');
    ratings.addRating(20, 'E');
    ratings.addRating(40, 'D');
    ratings.addRating(60, 'C');
    expect(ratings.rating(100), 'A');
    expect(ratings.rating(85), 'B');
    expect(ratings.rating(65), 'C');
    expect(ratings.rating(45), 'D');
    expect(ratings.rating(25), 'E');
    expect(ratings.rating(5), 'F');
  });

  test('Rating - sanitize', () {
    final ratings = Ratings();
    ratings.sanitize();
    expect(ratings.rating(100), 'A');
    expect(ratings.rating(85), 'B');
    expect(ratings.rating(65), 'C');
    expect(ratings.rating(45), 'D');
    expect(ratings.rating(25), 'E');
    expect(ratings.rating(5), 'F');
    expect(ratings.isSuccessful(81), true);
    expect(ratings.isSuccessful(79.999), false);
  });

  test('Rating - dont sanitize', () {
    final ratings = Ratings();
    ratings.failure = 50;
    ratings.sanitize();
    expect(ratings.rating(100), 'N/A');
    expect(ratings.isSuccessful(79.999), true);
    expect(ratings.failure, 50.0);
  });
}
