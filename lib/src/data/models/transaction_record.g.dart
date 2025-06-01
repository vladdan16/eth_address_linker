// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransactionRecord _$TransactionRecordFromJson(Map<String, dynamic> json) =>
    _TransactionRecord(
      blockNumber: (json['blockNumber'] as num).toInt(),
      timeStamp: (json['timeStamp'] as num).toInt(),
      hash: json['hash'] as String,
      transactionIndex: (json['transactionIndex'] as num).toInt(),
      from: json['from'] as String,
      to: json['to'] as String,
      value: (json['value'] as num).toInt(),
      gas: (json['gas'] as num).toInt(),
      gasPrice: (json['gasPrice'] as num).toInt(),
      isError: (json['isError'] as num).toInt(),
      input: json['input'] as String,
      contractAddress: json['contractAddress'] as String,
      cumulativeGasUsed: (json['cumulativeGasUsed'] as num).toInt(),
      gasUsed: (json['gasUsed'] as num).toInt(),
      confirmations: (json['confirmations'] as num).toInt(),
      methodId: (json['methodId'] as num).toInt(),
      functionName: json['functionName'] as String,
    );

Map<String, dynamic> _$TransactionRecordToJson(_TransactionRecord instance) =>
    <String, dynamic>{
      'blockNumber': instance.blockNumber,
      'timeStamp': instance.timeStamp,
      'hash': instance.hash,
      'transactionIndex': instance.transactionIndex,
      'from': instance.from,
      'to': instance.to,
      'value': instance.value,
      'gas': instance.gas,
      'gasPrice': instance.gasPrice,
      'isError': instance.isError,
      'input': instance.input,
      'contractAddress': instance.contractAddress,
      'cumulativeGasUsed': instance.cumulativeGasUsed,
      'gasUsed': instance.gasUsed,
      'confirmations': instance.confirmations,
      'methodId': instance.methodId,
      'functionName': instance.functionName,
    };
