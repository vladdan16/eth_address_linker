// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransactionRecord _$TransactionRecordFromJson(Map<String, dynamic> json) =>
    _TransactionRecord(
      blockNumber: json['blockNumber'] as String,
      timeStamp: json['timeStamp'] as String,
      hash: json['hash'] as String,
      transactionIndex: json['transactionIndex'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
      value: json['value'] as String,
      gas: json['gas'] as String,
      gasPrice: json['gasPrice'] as String,
      isError: json['isError'] as String,
      input: json['input'] as String,
      contractAddress: json['contractAddress'] as String,
      cumulativeGasUsed: json['cumulativeGasUsed'] as String,
      gasUsed: json['gasUsed'] as String,
      confirmations: json['confirmations'] as String,
      methodId: json['methodId'] as String,
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
