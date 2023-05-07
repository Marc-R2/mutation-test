/// Copyright 2021, domohuhn.
/// License: BSD-3-Clause
/// See LICENSE for the full text of the license
import 'dart:io';

import 'package:mutation_test/src/progress_bar.dart';
import 'package:mutation_test/src/string_helpers.dart';

/// Tracks the current progress and estimates the remaining time.
class MutationProgressBar {
  MutationProgressBar(int count, this.verbose, this.threshold, this.quiet)
      : file = ProgressBar(count, showTotal: false, left: 'File ['),
        total = ProgressBar(
          count,
          width: 27,
          left: 'Total [',
          widthIncludesText: false,
        );

  ProgressBar file;
  ProgressBar total;
  bool verbose;
  double threshold;
  int _width = 0;
  bool quiet = false;
  final Stopwatch _timer = Stopwatch();

  set mutationCount(int v) => total.maximum = v;

  /// Starts the progress bar for a new file.
  /// Prints the [path] of the file and the number of mutations [count] for that file.
  /// [count] is also used to compute the percentage of progress.
  void startFile(String path, int count) {
    if (!_timer.isRunning) _timer.start();
    if (!quiet) print('$path : $count mutations'.padRight(_width));
    file.current = 0;
    file.maximum = count;
  }

  /// Writes the end of file message to the console with the count of [failed] tests.
  void endFile(int failed) {
    final pct = 1.0 - failed.toDouble() / file.maximum.toDouble();
    final prefix = 100 * pct <= threshold ? 'FAILED' : 'OK';
    final text = '$prefix: $failed/${file.maximum} '
            '(${asPercentString(failed, file.maximum)}) '
            'mutations were not detected!'
        .padRight(_width);
    _writeText(text, true);
  }

  /// Increments the progress bar with one additional test.
  void increment() {
    file.update(1);
    total.update(1);
  }

  /// Updates the progress bar in the console by writing a new line.
  void render() {
    final text = createText();
    final next = text.length;
    _writeText(text.padRight(_width), false);
    _width = next;
  }

  /// Creates the text to update the progress bar
  String createText() {
    var text = '$file $total';
    final duration = _timer.elapsed;
    final max = duration * (1.0 / total.progress);
    final remaining = max - duration;
    text += ' ~${formatDuration(remaining)}';
    text.padRight(_width);
    return text;
  }

  void _writeText(String text, bool newline) {
    if (quiet) return;
    if (verbose) {
      print(text);
    } else {
      stdout.write('\r$text${newline ? '\n' : ''}}');
    }
  }
}
