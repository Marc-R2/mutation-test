/// Copyright 2021, domohuhn.
/// License: BSD-3-Clause
/// See LICENSE for the full text of the license

import 'dart:io';

import 'package:mutation_test/src/commands.dart';
import 'package:mutation_test/src/errors.dart';
import 'package:mutation_test/src/mutations/mutation.dart';
import 'package:mutation_test/src/range.dart';
import 'package:mutation_test/src/ratings.dart';
import 'package:mutation_test/src/replacements.dart';
import 'package:xml/xml.dart' as xml;

/// A structure holding the information about the mutation input.
class TargetFile {
  TargetFile(this.path, this.whitelist);

  String path;
  List<Range> whitelist;
}

/// Reads the xml configuration file
class Configuration {
  Configuration(this.verbose, this.dry)
      : files = [],
        excludedFiles = [],
        mutations = [],
        commands = [],
        exclusions = [],
        ratings = Ratings();

  /// Constructs the configuration from an xml file in [path]
  Configuration.fromFile({
    required String path,
    required this.verbose,
    required this.dry,
  })  : files = [],
        excludedFiles = [],
        mutations = [],
        commands = [],
        exclusions = [],
        ratings = Ratings() {
    addRulesFromFile(path);
  }

  /// The list of source files that will be mutated
  final List<TargetFile> files;

  /// The list files that are excluded
  final List<String> excludedFiles;

  /// The mutation rules added from the rules
  final List<Mutation> mutations;

  /// The commands to execute to detect mutations
  final List<Command> commands;

  /// Lists the excluded sections in files
  final List<Range> exclusions;

  /// The ratings for the mutation-test
  final Ratings ratings;

  /// Verbose output
  final bool verbose;

  /// Dry run only. Do not mutate files.
  final bool dry;

  bool toplevelFound = false;

  /// Add all rules from [path]
  void addRulesFromFile(String path) {
    verbosePrint('Processing $path');
    final file = File(path);
    final contents = file.readAsStringSync();
    parseXMLString(contents);
  }

  /// Removes all input source files from the target file list
  /// that were explicitly excluded in the rules file.
  void _removeExcludedSourceFiles() {
    for (final excluded in excludedFiles) {
      files.removeWhere((element) {
        if (element.path != excluded) return false;
        verbosePrint('Excluding file: $excluded');
        return true;
      });
    }
  }

  /// Parses an XML string with the given [contents]
  void parseXMLString(String contents) {
    final document = xml.XmlDocument.parse(contents);
    for (final element in document.findAllElements('mutations')) {
      processTopLevel(element);
    }
    if (!toplevelFound) {
      throw MutationError('Could not find xml element <mutations>');
    }
    _removeExcludedSourceFiles();
  }

  /// Checks if the configuration is valid.
  /// That means at least one input file, one test command and
  /// one mutation rule.
  void validate() {
    if ((files.isEmpty) || mutations.isEmpty || commands.isEmpty) {
      throw MutationError(
        'At least one entry in the configuration for '
        'each of the following elements is needed:\n'
        'files: ${files.length} mutation rules: ${mutations.length} '
        'verification commands: ${commands.length}',
      );
    }
    ratings.sanitize();
  }

  /// Reads the configuration from an xml element.
  void processTopLevel(xml.XmlElement root) {
    processVersion(root);

    processFiles(root);

    processRules(root);

    processExclude(root);

    processCommands(root);

    processThreshold(root);
  }

  /// Prints a verbose message if [verbose] is true.
  void verbosePrint(String str) {
    if (verbose) print(str);
  }

  /// Check the version of the configuration file.
  ///
  /// Throws a [MutationError] if the version is not supported or
  /// the version attribute is missing.
  void processVersion(xml.XmlElement root) {
    final str = root.getAttribute('version');
    toplevelFound = true;
    if (str == null) {
      throw MutationError(
        'No version attribute found in xml element <mutations>!',
      );
    }
    if (double.parse(str) != 1.0) {
      throw MutationError('Configuration file version not supported!');
    }
    verbosePrint('- configuration file version $str');
  }

  /// Reads all files and directories from the configuration file.
  void processFiles(xml.XmlElement root) {
    _processXMLNode(root, 'files', (xml.XmlElement el) {
      _processXMLNode(el, 'file', _addFile);
    });

    _processXMLNode(root, 'directories', (xml.XmlElement el) {
      _processXMLNode(el, 'directory', _addDirectory);
    });

    verbosePrint(' ${files.length} input files');
  }

  /// Reads the rules from the configuration file.
  void processRules(xml.XmlElement root) {
    _processXMLNode(root, 'rules', (xml.XmlElement el) {
      _processXMLNode(el, 'literal', _addLiteralRule);
      _processXMLNode(el, 'regex', _addRegexRule);
    });
    verbosePrint(' ${mutations.length} mutation rules');
  }

  /// Reads the exclude rules from the configuration file.
  void processExclude(xml.XmlElement root) {
    _processXMLNode(root, 'exclude', (xml.XmlElement el) {
      _processXMLNode(el, 'token', _addTokenRange);
      _processXMLNode(el, 'lines', _addLineRange);
      _processXMLNode(el, 'regex', (el) {
        exclusions.add(RegexRange(_parseRegEx(el)));
      });
      _processXMLNode(el, 'file', _addExcludedFile);
    });
    verbosePrint(' ${exclusions.length} exclusion rules');
  }

  /// Reads the commands from the configuration file.
  void processCommands(xml.XmlElement root) {
    _processXMLNode(root, 'commands', (xml.XmlElement el) {
      _processXMLNode(el, 'command', _addCommand);
    });
    verbosePrint(
      ' ${commands.length} commands will be executed to detect mutations',
    );
  }

  /// Reads the threshold from the configuration file.
  void processThreshold(xml.XmlElement root) {
    _processXMLNode(root, 'threshold', _parseThreshold);
  }

  /// Applies the given [functor] to all elements of type [type] in [root].
  void _processXMLNode(
    xml.XmlElement root,
    String type,
    void Function(xml.XmlElement) functor,
  ) {
    for (final element in root.findAllElements(type)) {
      functor(element);
    }
  }

  void _addFile(xml.XmlElement element) {
    final path = element.text.trim();
    if (!File(path).existsSync()) {
      throw MutationError('Input file "$path" not found!');
    }
    final whitelist = <Range>[];
    _processXMLNode(element, 'lines', (el) {
      whitelist.add(_parseLineRange(el));
    });
    files.add(TargetFile(path, whitelist));
  }

  void _addExcludedFile(xml.XmlElement element) {
    final path = element.text.trim();
    excludedFiles.add(path);
  }

  void _addDirectory(xml.XmlElement element) {
    final path = element.text.trim();
    if (!Directory(path).existsSync()) {
      throw MutationError('Input directory "$path" not found!');
    }
    final recurseStr = element.getAttribute('recursive');
    final recurse = recurseStr != null && recurseStr == 'true';
    final patterns = <RegExp>[];
    _processXMLNode(element, 'matching', (el) {
      final pat = el.getAttribute('pattern');
      if (pat == null) {
        throw MutationError(
          '<matching> tokens must have a pattern as attribute!',
        );
      }
      patterns.add(RegExp(pat));
    });
    final tree = Directory(path).listSync(recursive: recurse);
    for (final f in tree) {
      if (patterns.isNotEmpty) {
        for (final pat in patterns) {
          if (pat.hasMatch(f.path) && f is! Link) {
            files.add(TargetFile(f.path, []));
          }
        }
      } else {
        files.add(TargetFile(f.path, []));
      }
    }
  }

  void _parseThreshold(xml.XmlElement element) {
    if (ratings.initialized) {
      throw MutationError(
        'There must be only one <threshold> element in the inputs!',
      );
    }
    final failure = element.getAttribute('failure');
    if (failure == null) {
      throw MutationError('<threshold> needs attribute "failure"');
    }
    ratings.failure = double.parse(failure);

    _processXMLNode(element, 'rating', (el) {
      final lowerbound = el.getAttribute('over');
      final name = el.getAttribute('name');
      if (lowerbound == null || name == null) {
        throw MutationError(
          '<rating> needs attributes "over" '
          'and "name" - got $lowerbound, $name',
        );
      }
      ratings.addRating(double.parse(lowerbound), name);
    });

    if (verbose) {
      print(' $ratings');
    }
  }

  void _addTokenRange(xml.XmlElement element) {
    var begin = element.getAttribute('begin');
    var end = element.getAttribute('end');

    if (begin == null || end == null) {
      throw MutationError('Every <token> needs a begin and end attribute!');
    }

    if (begin == r'\n') begin = '\n';
    if (end == r'\n') end = '\n';

    if (begin == r'\t') begin = '\t';
    if (end == r'\t') end = '\t';

    exclusions.add(TokenRange(begin, end));
  }

  LineRange _parseLineRange(xml.XmlElement element) {
    final begin = element.getAttribute('begin');
    final end = element.getAttribute('end');
    if (begin == null || end == null) {
      throw MutationError('Every <lines> needs a begin and end attribute!');
    }
    return LineRange(int.parse(begin), int.parse(end));
  }

  void _addLineRange(xml.XmlElement element) {
    exclusions.add(_parseLineRange(element));
  }

  RegExp _parseRegEx(xml.XmlElement element) {
    final pattern = element.getAttribute('pattern');
    if (pattern == null) {
      throw MutationError('Every <regex> needs a pattern!');
    }

    final tmp = element.getAttribute('dotAll');
    final dotMatchesNewlines = tmp != null && tmp == 'true';

    return RegExp(pattern, multiLine: true, dotAll: dotMatchesNewlines);
  }

  /// Parses a <command> token from [element] and adds it to the interal structure.
  void _addCommand(xml.XmlElement element) {
    final text = element.text.split(' ');
    if (text.isEmpty) {
      throw MutationError('Received empty text for a <command>');
    }
    final process = text[0].trim();
    final args = <String>[];
    args.addAll(text);
    args.removeAt(0);
    final cmd = Command(element.text, process, args);
    final group = element.getAttribute('group');
    if (group != null) {
      cmd.group = group;
    }
    final expected = element.getAttribute('expected');
    if (expected != null) {
      cmd.expectedReturnValue = int.parse(expected);
    }
    final timeout = element.getAttribute('timeout');
    if (timeout != null) {
      cmd.timeout = Duration(seconds: int.parse(timeout));
    }
    cmd.directory = element.getAttribute('working-directory');
    commands.add(cmd);
  }

  /// Adds a literal text replacement rule from [element]
  void _addLiteralRule(xml.XmlElement element) {
    final str = element.getAttribute('text');
    if (str == null) {
      throw MutationError('Each <literal> must have a text attribute!');
    }
    final mutation = Mutation(str);
    for (final child in element.findAllElements('mutation')) {
      final replacement = child.getAttribute('text');
      if (replacement == null) {
        throw MutationError('Each <mutation> must have a text attribute!');
      }
      mutation.replacements.add(LiteralReplacement(replacement));
    }
    if (mutation.replacements.isEmpty) {
      throw MutationError(
        'Each <literal> rule must have at least one <mutation> child!',
      );
    }
    mutations.add(mutation);
  }

  /// Adds a regular expression text replacement rule from [element]
  void _addRegexRule(xml.XmlElement element) {
    final mutation = Mutation(_parseRegEx(element));
    for (final child in element.findAllElements('mutation')) {
      final replacement = child.getAttribute('text');
      if (replacement == null) {
        throw MutationError('Each <mutation> must have a text attribute!');
      }
      mutation.replacements.add(RegexReplacement(replacement));
    }
    if (mutation.replacements.isEmpty) {
      throw MutationError(
        'Each <regex> rule must have at least one <mutation> child!',
      );
    }
    mutations.add(mutation);
  }
}
