/// Copyright 2021, domohuhn.
/// License: BSD-3-Clause
/// See LICENSE for the full text of the license
import 'dart:io';

import 'package:mutation_test/src/range.dart';
import 'package:test/test.dart';

void main() {
  group('Range', () {
    const text1 = 'smoe\nthing/**s\n*f\nsdf */*x;\n';
    const text2 = 'smoe\nthing// comment ad\n*x;\n';
    const text3 = 'ghbh\nfor(asd;sdf;sd++){\n*x;\n';

    final exclusion1 = TokenRange('/*', '*/');
    final exclusion2 = TokenRange('//', '\n');
    final exclusion3 = LineRange(2, 3);
    final exclusion4 = RegexRange(RegExp(r'\/[*].*?[*]\/', dotAll: true));
    final exclusion5 = RegexRange(RegExp(r'//.*\n'));
    final exclusion6 = RegexRange(RegExp(r'[\s]for[\s]*\([\s\S].*?\)[\s]*{'));

    test('exclusion multiline 1', () {
      for (var i = 0; i < text1.length; i++) {
        expect(exclusion1.isInRange(text1, i), i >= 10 && i <= 23);
      }
    });

    test('exclusion multiline 2', () {
      for (var i = 0; i < text2.length; i++) {
        expect(exclusion1.isInRange(text2, i), false);
      }
    });

    test('exclusion singleline 1', () {
      for (var i = 0; i < text2.length; i++) {
        expect(exclusion2.isInRange(text2, i), i >= 10 && i <= 23);
      }
    });

    test('exclusion singleline 2', () {
      for (var i = 0; i < text1.length; i++) {
        expect(exclusion2.isInRange(text1, i), false);
      }
    });

    var source2 = File('example/source2.dart').readAsStringSync();
    source2 = source2.replaceAll('\r', '');

    test('exclusion singleline 3', () {
      expect(exclusion2.isInRange(source2, 313), false);
      expect(exclusion2.isInRange(source2, 318), true);
      expect(exclusion2.isInRange(source2, 319), true);
      expect(exclusion2.isInRange(source2, 320), true);
    });

    test('exclusion multiline source2', () {
      for (var i = 0; i < 150; i++) {
        expect(exclusion1.isInRange(source2, i), 106 <= i && i <= 135);
        expect(exclusion4.isInRange(source2, i), 106 <= i && i <= 135);
      }
    });

    test('exclusion lines 1', () {
      for (var i = 0; i < text1.length; i++) {
        expect(exclusion3.isInRange(text1, i), 5 <= i && i <= 17);
      }
    });

    test('exclusion lines 2', () {
      for (var i = 0; i < text2.length; i++) {
        expect(exclusion3.isInRange(text2, i), 5 <= i);
      }
    });

    group('Regex exclusion', () {
      test('exclusion multiline 1', () {
        for (var i = 0; i < text1.length; i++) {
          expect(exclusion4.isInRange(text1, i), i >= 10 && i <= 23);
        }
      });

      test('exclusion multiline 2', () {
        for (var i = 0; i < text2.length; i++) {
          expect(exclusion4.isInRange(text2, i), false);
        }
      });

      test('exclusion singleline 1', () {
        for (var i = 0; i < text2.length; i++) {
          expect(exclusion5.isInRange(text2, i), i >= 10 && i <= 23);
        }
      });

      test('exclusion singleline 2', () {
        for (var i = 0; i < text1.length; i++) {
          expect(exclusion5.isInRange(text1, i), false);
        }
      });

      test('exclusion for', () {
        for (var i = 0; i < text3.length; i++) {
          expect(exclusion6.isInRange(text3, i), 4 <= i && i <= 22);
        }
      });
    });
  });
}
