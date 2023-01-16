/// Copyright 2022, domohuhn.
/// License: BSD-3-Clause
/// See LICENSE for the full text of the license
import 'package:mutation_test/src/commands.dart';
import 'package:mutation_test/src/html_reporter.dart';
import 'package:mutation_test/src/mutations.dart';
import 'package:mutation_test/src/report_format.dart';
import 'package:mutation_test/src/version.dart';
import 'package:test/test.dart';

void main() {
  test('Create Toplevel html file', () {
    final result = createToplevelHtmlFile(ResultsReporter('test.xml', true));
    // exclude report creation time
    const end1 = 5494;
    const start2 = end1 + 24;
    expect(result.substring(0, end1), emptyToplevel.substring(0, end1));
    expect(result.substring(start2), emptyToplevel.substring(start2));
  });

  test('Create html source report', () {
    final reporter = ResultsReporter('test.xml', true);
    reporter.startFileTest('path.dart', 3, 'var x = 0;\n\n// mooo\n');
    reporter.addTestReport(
      'path.dart',
      MutatedLine(1, 0, 5, 'var x = 0;', 'var x = -0;'),
      TestReport(TestResult.Detected),
      true,
    );
    reporter.addTestReport(
      'path.dart',
      MutatedLine(1, 0, 5, 'var x = 0;', 'var x = a;'),
      TestReport(TestResult.Undetected),
      true,
    );
    reporter.addTestReport(
      'path.dart',
      MutatedLine(1, 0, 5, 'var x = 0;', 'var x = c;'),
      TestReport(TestResult.Timeout),
      true,
    );
    final result = createSourceHtmlFile(
      ResultsReporter('test.xml', true),
      reporter.testedFiles.values.first,
      'test.html',
    );
    // exclude report creation time
    const end1 = 5534;
    const start2 = end1 + 24;
    expect(result.substring(0, end1), htmlSourceFileReport.substring(0, end1));
    expect(result.substring(start2), htmlSourceFileReport.substring(start2));
  });
}

final emptyToplevel = '<!DOCTYPE html>\n'
    '<html lang="en">\n'
    '<head>\n'
    '<meta name="viewport" content="width=device-width, initial-scale=1">\n'
    '<style>\n${getCSSFileContents()}'
    '</style>\n'
    '</head>\n'
    '<body>\n'
    '<table width ="100%" cellspacing="0" border="0">\n'
    '    <tr><td class="title">Mutation test report</td></tr>\n'
    '     <tr><td><hr class="ruler"/></td></tr>\n'
    '\n'
    '     <tr>\n'
    '     <td width="100%">\n'
    '     <table width="100%" cellpadding="1" border="0">\n'
    '     <tbody><tr>\n'
    '     <td class="ItemLabel" width="10%">Current display:</td>\n'
    '     <td class="ItemText" width="35%">top level</td>\n'
    '     <td width="10%"></td>\n'
    '     <td class="MiddleHeader" width="15%">Detected</td>\n'
    '     <td class="MiddleHeader" width="15%">Total</td>\n'
    '     <td class="MiddleHeader" width="15%">Percentage</td>\n'
    '     </tr>\n'
    '\n'
    '     <tr>\n'
    '     <td class="ItemLabel" width="10%">Date:</td>\n'
    '     <td class="ItemText" width="35%">2022-10-30 15:40:12.063141</td>\n'
    '     <td class="ItemLabel" width="10%">Mutations:</td>\n'
    '     <td class="ItemReport" width="15%">0</td>\n'
    '     <td class="ItemReport" width="15%">0</td>\n'
    '     <td class="ItemReportHigh" width="15%">100.0 %</td>\n'
    '     </tr>\n'
    '     \n'
    '     <tr>\n'
    '     <td class="ItemLabel" width="10%">Builtin rules:</td>\n'
    '     <td class="ItemText" width="35%">true</td>\n'
    '     <td class="ItemLabel" width="10%">Timeouts:</td>\n'
    '     <td class="ItemReport" width="15%">0</td>\n'
    '     <td class="ItemReport" width="15%">0</td>\n'
    '     <td class="ItemReportHigh" width="15%">0.0 %</td>\n'
    '     </tr>\n'
    '     <tr>\n'
    '     <td class="ItemLabel" width="10%">Quality rating:</td>\n'
    '     <td class="ItemText" width="35%">N/A</td>\n'
    '     <td class="ItemLabel" width="10%">Success:</td>\n'
    '     <td class="ItemText" width="15%">true</td>\n'
    '     <td class="ItemText" width="15%"></td>\n'
    '     <td class="ItemText" width="15%"></td>\n'
    '     </tr>\n'
    '       </tbody>\n'
    '     </table>\n'
    '     </td>\n'
    '     </tr>\n'
    '     \n'
    '\n'
    '     \n'
    '     <tr><td><hr class="ruler"/></td></tr>\n'
    '</table>\n'
    '\n'
    '<center>\n'
    '<table width ="80%" cellspacing="1" border="0">\n'
    '     <tbody>\n'
    '     <tr><td width="60%"></td><td width="10%"></td><td width="10%"></td><td width="10%"></td><td width="10%"></td></tr>\n'
    '     <tr><td class="ItemHead" width="60%">Path</td><td class="ItemHead" width="30%" colspan="3">Detection rate</td><td class="ItemHead" width="10%">Timeouts</td></tr>\n'
    '    </tbody>\n'
    '</table>\n'
    '</center>\n'
    '\n'
    '\n'
    '<table width ="100%" cellspacing="0" border="0">\n'
    '  <tr><td><hr class="ruler"/></td></tr>\n'
    '  <tr><td class="footer">Generated by <a href="https://domohuhn.github.io/mutation-test/">${mutationTestVersion()}</a></td></tr>\n'
    '</table>\n'
    '</body>\n'
    '</html>\n';

final htmlSourceFileReport = '<!DOCTYPE html>\n'
    '<html lang="en">\n'
    '<head>\n'
    '<meta name="viewport" content="width=device-width, initial-scale=1">\n'
    '<style>\n${getCSSFileContents()}'
    '</style>\n'
    '</head>\n'
    '<body>\n'
    '<table width ="100%" cellspacing="0" border="0">\n'
    '    <tr><td class="title">Mutation test report</td></tr>\n'
    '     <tr><td><hr class="ruler"/></td></tr>\n'
    '\n'
    '     <tr>\n'
    '     <td width="100%">\n'
    '     <table width="100%" cellpadding="1" border="0">\n'
    '     <tbody><tr>\n'
    '     <td class="ItemLabel" width="10%">Current display:</td>\n'
    '     <td class="ItemText" width="35%">path.dart - <a href="./test.html">back to top</a></td>\n'
    '     <td width="10%"></td>\n'
    '     <td class="MiddleHeader" width="15%">Detected</td>\n'
    '     <td class="MiddleHeader" width="15%">Total</td>\n'
    '     <td class="MiddleHeader" width="15%">Percentage</td>\n'
    '     </tr>\n'
    '\n'
    '     <tr>\n'
    '     <td class="ItemLabel" width="10%">Date:</td>\n'
    '     <td class="ItemText" width="35%">2022-10-30 16:37:03.526343</td>\n'
    '     <td class="ItemLabel" width="10%">Mutations:</td>\n'
    '     <td class="ItemReport" width="15%">1</td>\n'
    '     <td class="ItemReport" width="15%">3</td>\n'
    '     <td class="ItemReportLow" width="15%">33.3 %</td>\n'
    '     </tr>\n'
    '     \n'
    '     <tr>\n'
    '     <td class="ItemLabel" width="10%">Builtin rules:</td>\n'
    '     <td class="ItemText" width="35%">true</td>\n'
    '     <td class="ItemLabel" width="10%">Timeouts:</td>\n'
    '     <td class="ItemReport" width="15%">1</td>\n'
    '     <td class="ItemReport" width="15%">3</td>\n'
    '     <td class="ItemReportMedium" width="15%">33.3 %</td>\n'
    '     </tr>\n'
    '     </tbody>\n'
    '     </table>\n'
    '     </td>\n'
    '     </tr>\n'
    '     \n'
    '\n'
    '     \n'
    '     <tr><td><hr class="ruler"/></td></tr>\n'
    '</table>\n'
    '\n'
    '<pre class="fileHeader">Source code</pre>\n'
    '<pre class="fileContents">\n'
    '<a name="1"><button class="collapsible problem"><pre class="fileContents"><span class="lineNumber">       1 </span>var x = 0;</pre></button>\n'
    '<div class="content">\n'
    '<b>Undetected mutations:</b>\n'
    '<table class="mutationTable">\n'
    '<tr><td class="mutationLabel" width="10%">1 :</td><td class="mutationText" width="90%"><span class="addedLine">+ <span class="changedTokens">var x</span> = a;</span></td></tr></table>\n'
    '<b>Detected mutations:</b>\n'
    '<table class="mutationTable">\n'
    '<tr><td class="mutationLabel" width="10%">1 :</td><td class="mutationText" width="90%"><span class="addedLine">+ <span class="changedTokens">var x </span>= -0;</span></td></tr></table>\n'
    '<b>Mutations that caused a time out:</b>\n'
    '<table class="mutationTable">\n'
    '<tr><td class="mutationLabel" width="10%">1 :</td><td class="mutationText" width="90%"><span class="addedLine">+ <span class="changedTokens">var x</span> = c;</span></td></tr></table>\n'
    '\n'
    '</div></a><a name="2"><span class="lineNumber">       2 </span></a>\n'
    '<a name="3"><span class="lineNumber">       3 </span>// mooo</a>\n'
    '<a name="4"><span class="lineNumber">       4 </span></a>\n'
    '</pre>\n'
    '<script>\n'
    'var coll = document.getElementsByClassName("collapsible");\n'
    'var i;\n'
    '\n'
    'for (i = 0; i < coll.length; i++) {\n'
    '  coll[i].addEventListener("click", function() {\n'
    '    this.classList.toggle("active");\n'
    '    var content = this.nextElementSibling;\n'
    '    if (content.style.maxHeight){\n'
    '      content.style.maxHeight = null;\n'
    '    } else {\n'
    '      content.style.maxHeight = content.scrollHeight + "px";\n'
    '    }\n'
    '\tfor (k = 0; k < coll.length; k++) {\n'
    '      var content2 = coll[k].nextElementSibling;\n'
    '      if (content2.style.maxHeight && content.parentElement == content2){\n'
    '      content2.style.maxHeight = content2.scrollHeight + content.scrollHeight + "px";\n'
    '    }\n'
    '      \n'
    '    }\n'
    '    \n'
    '  });\n'
    '}\n'
    '</script><table width ="100%" cellspacing="0" border="0">\n'
    '  <tr><td><hr class="ruler"/></td></tr>\n'
    '  <tr><td class="footer">Generated by <a href="https://domohuhn.github.io/mutation-test/">${mutationTestVersion()}</a></td></tr>\n'
    '</table>\n'
    '</body>\n'
    '</html>\n';
