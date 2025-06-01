import 'dart:io';

import 'package:address_linker/address_linker.dart';
import 'package:args/args.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag('version', negatable: false, help: 'Print the tool version.')
    ..addCommand('run');
}

void printUsage(ArgParser argParser) {
  print('Usage: dart address_linker.dart <flags> [arguments]');
  print(argParser.usage);
  print('\nCommands:');
  print('  run      Runs construction of pairs');
}

/// Main entry point for the application
void main(List<String> arguments) async {
  final argParser = buildParser();
  try {
    final results = argParser.parse(arguments);
    var verbose = false;

    // Process the parsed arguments.
    if (results.flag('help')) {
      printUsage(argParser);
      return;
    }
    if (results.flag('version')) {
      print('untitled version: $version');
      return;
    }
    if (results.flag('verbose')) {
      verbose = true;
    }

    final addressLinker = AddressLinker();
    await addressLinker.init();

    // Process commands
    final command = results.command?.name;
    if (command == null) {
      printUsage(argParser);
      return;
    }

    try {
      switch (command) {
        case 'run':
          await addressLinker.run();
        default:
          print('Unknown command: $command');
          printUsage(argParser);
      }
    } on Object catch (e, stackTrace) {
      print('Error: $e');
      if (verbose) {
        print('Stack trace: $stackTrace');
      }
      exit(1);
    }
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }
}
