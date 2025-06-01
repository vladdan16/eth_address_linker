import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_record.freezed.dart';

part 'transaction_record.g.dart';

@freezed
abstract class TransactionRecord with _$TransactionRecord {
  const factory TransactionRecord({
    required int blockNumber,
    required int timeStamp,
    required String hash,
    required int transactionIndex,
    required String from,
    required String to,
    required int value,
    required int gas,
    required int gasPrice,
    required int isError,
    required String input,
    required String contractAddress,
    required int cumulativeGasUsed,
    required int gasUsed,
    required int confirmations,
    required int methodId,
    required String functionName,
  }) = _TransactionRecord;

  factory TransactionRecord.fromJson(Map<String, Object?> json) =>
      _$TransactionRecordFromJson(json);
}
