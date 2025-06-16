import 'dart:io';

import 'package:address_linker/address_linker.dart';
import 'package:args/args.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  final parser = ArgParser()
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
    ..addFlag('version', negatable: false, help: 'Print the tool version.');

  final runCommand = ArgParser()
    ..addOption(
      'start-timestamp',
      help: 'Start timestamp for transaction analysis (Unix timestamp)',
      valueHelp: 'timestamp',
    )
    ..addOption(
      'end-timestamp',
      help: 'End timestamp for transaction analysis (Unix timestamp)',
      valueHelp: 'timestamp',
    )
    ..addOption(
      'algorithm',
      help: 'Graph algorithm to use for finding connections',
      valueHelp: 'algorithm',
      allowed: ['unionfind', 'bfs'],
      defaultsTo: 'unionfind',
      allowedHelp: {
        'unionfind': 'Union-Find algorithm (faster for connectivity checks)',
        'bfs':
            'Breadth-First Search (respects max depth in connectivity checks)',
      },
    )
    ..addOption(
      'max-depth',
      help: 'Maximum depth for graph traversal when checking connections',
      valueHelp: 'depth',
      defaultsTo: '4',
    );

  parser
    ..addCommand('run', runCommand)
    ..addCommand('process_transitive');

  final tagCommand = ArgParser()
    ..addOption(
      'address',
      abbr: 'a',
      help: 'Ethereum address to get nametag for',
      mandatory: true,
    );

  parser.addCommand('tag', tagCommand);

  return parser;
}

void printUsage(ArgParser argParser) {
  print('Usage: dart address_linker.dart <flags> [arguments]');
  print(argParser.usage);
  print('\nCommands:');
  print('  run                  Runs construction of pairs');
  print('    --start-timestamp  Optional start timestamp (Unix timestamp)');
  print('    --end-timestamp    Optional end timestamp (Unix timestamp)');
  print('    --algorithm        Graph algorithm to use (unionfind or bfs)');
  print(
    '    --max-depth        Maximum depth for graph traversal (default: 4)',
  );
  print('  process_transitive   Process top transitive addresses');
  print('  tag                  Gets the nametag for an Ethereum address');
  print('    --address, -a      Ethereum address to get nametag for');
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

    final algorithm = results.command?['algorithm'] as String?;
    final addressLinker = AddressLinker();
    await addressLinker.init(algorithm: algorithm);

    final command = results.command?.name;
    if (command == null) {
      printUsage(argParser);
      return;
    }

    try {
      switch (command) {
        case 'run':
          final runCommand = results.command!;
          int? startTimestamp;
          int? endTimestamp;
          final maxDepth = int.tryParse(runCommand['max-depth'] as String) ?? 4;

          if (runCommand['start-timestamp'] != null) {
            startTimestamp = int.tryParse(
              runCommand['start-timestamp'] as String,
            );
            if (startTimestamp == null) {
              print('''
Error: Invalid start timestamp format. Please provide a valid Unix timestamp.
''');
              exit(1);
            }
          }

          if (runCommand['end-timestamp'] != null) {
            endTimestamp = int.tryParse(runCommand['end-timestamp'] as String);
            if (endTimestamp == null) {
              print('''
Error: Invalid end timestamp format. Please provide a valid Unix timestamp.
''');
              exit(1);
            }
          }

          await addressLinker.run(
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp,
            maxDepth: maxDepth,
          );
        case 'process_transitive':
          await addressLinker.processTopTransitiveAddresses();
        case 'tag':
          final tagCommand = results.command!;
          final address = tagCommand['address'] as String;

          if (address.isEmpty) {
            print('Error: Address is required');
            exit(1);
          }

          print('Getting nametag for address: $address');
          final nametag = await addressLinker.getAddressNametag(address);

          if (nametag == null || nametag.isEmpty) {
            print('No nametag found for address: $address');
          } else {
            print('Nametag: $nametag');
          }
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
    print(e.message);
    print('');
    printUsage(argParser);
  }
}
