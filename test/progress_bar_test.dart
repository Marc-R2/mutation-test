/// Copyright 2021, domohuhn.
/// License: BSD-3-Clause
/// See LICENSE for the full text of the license

import 'package:mutation_test/src/progress_bar.dart';
import 'package:test/test.dart';

void main() {
  group('ProgressBar', () {
    test('Progress bar - Empty ', () {
      final bar = ProgressBar(80);
      bar.totalSuffix = 'MB';
      expect(bar.toString(), '[               ]   0% (0/80MB)');
    });

    test('Progress bar - Start ', () {
      final bar = ProgressBar(80);
      bar.totalSuffix = 'MB';
      bar.update(1);
      expect(bar.toString(), '[>              ]   1% (1/80MB)');
    });

    test('Progress bar - Half ', () {
      final bar = ProgressBar(80, width: 50);
      bar.totalSuffix = 'MB';
      bar.update(40);
      expect(
        bar.toString(),
        '[================>                 ]  50% (40/80MB)',
      );
    });

    test('Progress bar - Almost full ', () {
      final bar = ProgressBar(80, width: 50);
      bar.totalSuffix = 'MB';
      bar.update(79);
      expect(
        bar.toString(),
        '[=================================>]  99% (79/80MB)',
      );
    });

    test('Progress bar - Full ', () {
      final bar = ProgressBar(80, width: 50);
      bar.totalSuffix = 'MB';
      bar.update(80);
      expect(
        bar.toString(),
        '[=====================================] 100% (80MB)',
      );
    });

    test('Progress bar - No total ', () {
      final bar = ProgressBar(80, width: 50);
      bar.showTotal = false;
      bar.totalSuffix = 'MB';
      bar.update(40);
      expect(
        bar.toString(),
        '[=====================>                      ]  50%',
      );
    });

    test('Progress bar - No percent ', () {
      final bar = ProgressBar(80, width: 50);
      bar.showPercent = false;
      bar.totalSuffix = 'MB';
      bar.update(40);
      expect(
        bar.toString(),
        '[==================>                   ] (40/80MB)',
      );
    });

    test('Progress bar - No text ', () {
      final bar = ProgressBar(80);
      bar.showPercent = false;
      bar.showTotal = false;
      bar.update(40);
      expect(bar.toString(), '[=============>              ]');
    });

    test('Progress bar - Ignore text for width', () {
      final bar = ProgressBar(80, widthIncludesText: false);
      bar.totalSuffix = 'MB';
      bar.update(40);
      expect(bar.toString(), '[=============>              ]  50% (40/80MB)');
    });
  });
}
