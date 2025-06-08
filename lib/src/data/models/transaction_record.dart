import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_record.freezed.dart';

part 'transaction_record.g.dart';

@freezed
abstract class TransactionRecord with _$TransactionRecord {
  const factory TransactionRecord({
    required String blockNumber,
    required String timeStamp,
    required String hash,
    required String transactionIndex,
    required String from,
    required String to,
    required String value,
    required String gas,
    required String gasPrice,
    required String isError,
    required String input,
    required String contractAddress,
    required String cumulativeGasUsed,
    required String gasUsed,
    required String confirmations,
    required String methodId,
    required String functionName,
  }) = _TransactionRecord;

  factory TransactionRecord.fromJson(Map<String, Object?> json) =>
      _$TransactionRecordFromJson(json);
}
