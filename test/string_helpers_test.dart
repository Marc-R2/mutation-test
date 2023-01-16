/// Copyright 2021, domohuhn.
/// License: BSD-3-Clause
/// See LICENSE for the full text of the license
import 'package:mutation_test/src/string_helpers.dart';
import 'package:test/test.dart';

void main() {
  const text = '''
  This is a long string.
  Another line.
  More!
  MORE!
  MOOOOORE!

  Ok, this may be enough lines.
  ''';
  test('Find line number', () {
    expect(findLineFromPosition(text, 45), 3);
  });

  test('Find start of line', () {
    expect(findBeginOfLineFromPosition(text, 45), 41);
  });

  test('Find end of line', () {
    expect(findEndOfLineFromPosition(text, 45), 48);
  });

  test('report file name', () {
    final moo = createReportFileName('input.cpp', 'output', 'html');
    expect(moo, 'output/input-report.html');
  });

  test('report file name forwardslash', () {
    final moo = createReportFileName('before/input.cpp', 'output', 'html');
    expect(moo, 'output/input-report.html');
  });

  test('report file name backslash', () {
    final moo = createReportFileName(r'before\input.cpp', 'output', 'html');
    expect(moo, 'output/input-report.html');
  });

  test('percent string', () {
    final moo = asPercentString(25, 100);
    expect(moo, '25.00%');
  });

  test('convert to xml', () {
    final moo = convertToXML('<&"\'>');
    expect(moo, '&lt;&amp;&quot;&apos;&gt;');
  });

  test('formatDuration', () {
    final moo = formatDuration(const Duration(hours: 1));
    expect(moo, '1h 0m 0s');
  });

  test('convertToMarkdown', () {
    final moo = convertToMarkdown('*');
    expect(moo, r'\*');
  });

  test('get directory forwardslash', () {
    expect(getDirectory('somefile.cpp'), '');
    expect(getDirectory('path/somefile.cpp'), 'path/');
    expect(getDirectory('more/dirs/path/somefile.cpp'), 'more/dirs/path/');
  });
  test('get directory backslash', () {
    expect(getDirectory('somefile.cpp'), '');
    expect(getDirectory(r'path\somefile.cpp'), r'path\');
    expect(getDirectory(r'more\dirs\path\somefile.cpp'), r'more\dirs\path\');
  });

  test('create link prefix', () {
    expect(createParentLinkPrefix('somefile.cpp'), './');
    expect(createParentLinkPrefix('path/somefile.cpp'), '../');
    expect(createParentLinkPrefix('more/dirs/path/somefile.cpp'), '../../../');
    expect(createParentLinkPrefix(r'path\somefile.cpp'), '../');
    expect(createParentLinkPrefix(r'more\dirs\path\somefile.cpp'), '../../../');
  });

  test('report file name 2', () {
    final moo = createReportFileName(
      'input.cpp',
      'output',
      'html',
      removeInputExt: false,
    );
    expect(moo, 'output/input.cpp-report.html');
  });

  test('Escape html chars', () {
    expect(
      escapeCharsForHtml('aa < bb && cc > dd'),
      'aa &lt; bb &amp;&amp; cc &gt; dd',
    );
  });
}
