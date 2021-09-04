


import 'dart:io';
import 'package:mutation_test/mutations.dart';

import 'test-runner.dart';
import 'errors.dart';
import 'configuration.dart';
import 'string-helpers.dart';
import 'report-format.dart';
import 'builtin-rules.dart';

export 'report-format.dart';
export 'builtin-rules.dart';

/// Runs the mutation tests using the xml configuration file [inputFile].
/// Undetected modifications are written to a file in [outputPath] using the 
/// specified [format].
/// 
/// The testrunner will use builtin mutation rules unless a path to a XML file
/// is given as [ruleFile].
/// 
/// The amount of output to the command line is controlled via [verbose].
/// You can perform a [dry] run that wil not run any tests or perform any modifications,
/// but will list all found mutations per file.
/// Returns true if all modifications were detected by the test commands. 
Future<bool> runMutationTest(String inputFile, String outputPath, bool verbose, bool dry, ReportFormat format,
    {String? ruleFile}) async {
  final configuration = Configuration.fromFile(inputFile, verbose, dry);
  final tests = TestRunner(inputFile);
  if (ruleFile!=null) {
    configuration.addRulesFromFile(ruleFile);
    tests.xmlFiles.add(ruleFile);
  } else {
    if(verbose) {
      print('No ruleset given - adding builtin ruleset!');
    }
    tests.xmlFiles.add('Built in Ruleset');
    configuration.parseXMLString(builtinMutationRules());
  }
  configuration.validate();

  await checkTests(configuration,tests);

  for (final current in configuration.files) {
    final source = File(current.path).readAsStringSync();
    var data = MutationData(configuration,tests,current,source);
    var count = await countMutations(data);
    print('${current.path} : performing $count mutations');
    if (dry || count==0) {
      continue;
    }
    var failed = await doMutationTests(data);
    if (failed > 0) {
      print('FAILED: $failed (${asPercentString(failed, count)}) mutations passed all tests!');
    }

    // restore orignal
    File(current.path).writeAsStringSync(source);
  }
  if(!dry) {
    createReport(tests,outputPath,inputFile,format);
  }
  return tests.foundAll;
}


/// Data structure holding all data for a mutation run.
class MutationData {
  /// The current configuration
  final Configuration configuration;
  /// The testrunner
  final TestRunner test;
  /// Name of the file to mutate
  final TargetFile filename;
  /// Contents of the file to mutate
  final String contents;
  
  MutationData(this.configuration,this.test,this.filename,this.contents);
}

/// Checks if the tests in [cfg] can be run by the test runner [test] on the unmodified sources.
Future<void> checkTests(Configuration cfg, TestRunner test) async {
  if (cfg.verbose) {
    print('Checking if the test commands work with unmodified sources ...');
  }
  test.prepare(cfg);
  if (cfg.dry) {
    return;
  }
  var results = await test.run(cfg, outputOnFailure: true);
  if (!results) {
    throw Error('Running the test commands failed with unmodified code! Aborting.');
  }
}

/// Counts the mutations possible mutations in [data].
Future<int> countMutations(MutationData data) async {
  return doMutationTests(data, functor: (MutationData data, MutatedCode mutated) async {return true;}) ;
}

/// Performs the mutation tests in [data].
/// The unmodified contents of the file are mutated
/// using all mutation rules in [data] and then the tests are run.
/// Returns the number of undetected mutations.
Future<int> doMutationTests(MutationData data,
   {Future<bool> Function(MutationData data, MutatedCode mutated) functor = runTest,
   bool supressVerbose=false}) async {
  var failed = 0;
  for (final mutation in data.configuration.mutations) {
    if (data.configuration.verbose&&!supressVerbose) {
      print('Pattern: ${mutation.pattern}');
    }
    for ( final m in mutation.allMutations(data.contents,data.filename.whitelist , data.configuration.exclusions) ) {
      var result = await functor(data,m);
      if(result) {
        failed += 1;
      }
    }
  }
  return failed;
}

/// Writes the [mutated] code to disk and runs the tests. 
/// Undetected Mutations are added to the TestRunner in [data].
/// Returns true if the mutation was not found by the tests.
Future<bool> runTest(MutationData data, MutatedCode mutated) async {
  File(data.filename.path).writeAsStringSync(mutated.text);
  var result = await data.test.run(data.configuration);
  if (result) {
    data.test.addMutation(data.filename.path, mutated.line);
    return true;
  }
  return false;
}




