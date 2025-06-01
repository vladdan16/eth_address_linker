// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransactionRecord {

 int get blockNumber; int get timeStamp; String get hash; int get transactionIndex; String get from; String get to; int get value; int get gas; int get gasPrice; int get isError; String get input; String get contractAddress; int get cumulativeGasUsed; int get gasUsed; int get confirmations; int get methodId; String get functionName;
/// Create a copy of TransactionRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionRecordCopyWith<TransactionRecord> get copyWith => _$TransactionRecordCopyWithImpl<TransactionRecord>(this as TransactionRecord, _$identity);

  /// Serializes this TransactionRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionRecord&&(identical(other.blockNumber, blockNumber) || other.blockNumber == blockNumber)&&(identical(other.timeStamp, timeStamp) || other.timeStamp == timeStamp)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.transactionIndex, transactionIndex) || other.transactionIndex == transactionIndex)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.value, value) || other.value == value)&&(identical(other.gas, gas) || other.gas == gas)&&(identical(other.gasPrice, gasPrice) || other.gasPrice == gasPrice)&&(identical(other.isError, isError) || other.isError == isError)&&(identical(other.input, input) || other.input == input)&&(identical(other.contractAddress, contractAddress) || other.contractAddress == contractAddress)&&(identical(other.cumulativeGasUsed, cumulativeGasUsed) || other.cumulativeGasUsed == cumulativeGasUsed)&&(identical(other.gasUsed, gasUsed) || other.gasUsed == gasUsed)&&(identical(other.confirmations, confirmations) || other.confirmations == confirmations)&&(identical(other.methodId, methodId) || other.methodId == methodId)&&(identical(other.functionName, functionName) || other.functionName == functionName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,blockNumber,timeStamp,hash,transactionIndex,from,to,value,gas,gasPrice,isError,input,contractAddress,cumulativeGasUsed,gasUsed,confirmations,methodId,functionName);

@override
String toString() {
  return 'TransactionRecord(blockNumber: $blockNumber, timeStamp: $timeStamp, hash: $hash, transactionIndex: $transactionIndex, from: $from, to: $to, value: $value, gas: $gas, gasPrice: $gasPrice, isError: $isError, input: $input, contractAddress: $contractAddress, cumulativeGasUsed: $cumulativeGasUsed, gasUsed: $gasUsed, confirmations: $confirmations, methodId: $methodId, functionName: $functionName)';
}


}

/// @nodoc
abstract mixin class $TransactionRecordCopyWith<$Res>  {
  factory $TransactionRecordCopyWith(TransactionRecord value, $Res Function(TransactionRecord) _then) = _$TransactionRecordCopyWithImpl;
@useResult
$Res call({
 int blockNumber, int timeStamp, String hash, int transactionIndex, String from, String to, int value, int gas, int gasPrice, int isError, String input, String contractAddress, int cumulativeGasUsed, int gasUsed, int confirmations, int methodId, String functionName
});




}
/// @nodoc
class _$TransactionRecordCopyWithImpl<$Res>
    implements $TransactionRecordCopyWith<$Res> {
  _$TransactionRecordCopyWithImpl(this._self, this._then);

  final TransactionRecord _self;
  final $Res Function(TransactionRecord) _then;

/// Create a copy of TransactionRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? blockNumber = null,Object? timeStamp = null,Object? hash = null,Object? transactionIndex = null,Object? from = null,Object? to = null,Object? value = null,Object? gas = null,Object? gasPrice = null,Object? isError = null,Object? input = null,Object? contractAddress = null,Object? cumulativeGasUsed = null,Object? gasUsed = null,Object? confirmations = null,Object? methodId = null,Object? functionName = null,}) {
  return _then(_self.copyWith(
blockNumber: null == blockNumber ? _self.blockNumber : blockNumber // ignore: cast_nullable_to_non_nullable
as int,timeStamp: null == timeStamp ? _self.timeStamp : timeStamp // ignore: cast_nullable_to_non_nullable
as int,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,transactionIndex: null == transactionIndex ? _self.transactionIndex : transactionIndex // ignore: cast_nullable_to_non_nullable
as int,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,gas: null == gas ? _self.gas : gas // ignore: cast_nullable_to_non_nullable
as int,gasPrice: null == gasPrice ? _self.gasPrice : gasPrice // ignore: cast_nullable_to_non_nullable
as int,isError: null == isError ? _self.isError : isError // ignore: cast_nullable_to_non_nullable
as int,input: null == input ? _self.input : input // ignore: cast_nullable_to_non_nullable
as String,contractAddress: null == contractAddress ? _self.contractAddress : contractAddress // ignore: cast_nullable_to_non_nullable
as String,cumulativeGasUsed: null == cumulativeGasUsed ? _self.cumulativeGasUsed : cumulativeGasUsed // ignore: cast_nullable_to_non_nullable
as int,gasUsed: null == gasUsed ? _self.gasUsed : gasUsed // ignore: cast_nullable_to_non_nullable
as int,confirmations: null == confirmations ? _self.confirmations : confirmations // ignore: cast_nullable_to_non_nullable
as int,methodId: null == methodId ? _self.methodId : methodId // ignore: cast_nullable_to_non_nullable
as int,functionName: null == functionName ? _self.functionName : functionName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _TransactionRecord implements TransactionRecord {
  const _TransactionRecord({required this.blockNumber, required this.timeStamp, required this.hash, required this.transactionIndex, required this.from, required this.to, required this.value, required this.gas, required this.gasPrice, required this.isError, required this.input, required this.contractAddress, required this.cumulativeGasUsed, required this.gasUsed, required this.confirmations, required this.methodId, required this.functionName});
  factory _TransactionRecord.fromJson(Map<String, dynamic> json) => _$TransactionRecordFromJson(json);

@override final  int blockNumber;
@override final  int timeStamp;
@override final  String hash;
@override final  int transactionIndex;
@override final  String from;
@override final  String to;
@override final  int value;
@override final  int gas;
@override final  int gasPrice;
@override final  int isError;
@override final  String input;
@override final  String contractAddress;
@override final  int cumulativeGasUsed;
@override final  int gasUsed;
@override final  int confirmations;
@override final  int methodId;
@override final  String functionName;

/// Create a copy of TransactionRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionRecordCopyWith<_TransactionRecord> get copyWith => __$TransactionRecordCopyWithImpl<_TransactionRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionRecord&&(identical(other.blockNumber, blockNumber) || other.blockNumber == blockNumber)&&(identical(other.timeStamp, timeStamp) || other.timeStamp == timeStamp)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.transactionIndex, transactionIndex) || other.transactionIndex == transactionIndex)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.value, value) || other.value == value)&&(identical(other.gas, gas) || other.gas == gas)&&(identical(other.gasPrice, gasPrice) || other.gasPrice == gasPrice)&&(identical(other.isError, isError) || other.isError == isError)&&(identical(other.input, input) || other.input == input)&&(identical(other.contractAddress, contractAddress) || other.contractAddress == contractAddress)&&(identical(other.cumulativeGasUsed, cumulativeGasUsed) || other.cumulativeGasUsed == cumulativeGasUsed)&&(identical(other.gasUsed, gasUsed) || other.gasUsed == gasUsed)&&(identical(other.confirmations, confirmations) || other.confirmations == confirmations)&&(identical(other.methodId, methodId) || other.methodId == methodId)&&(identical(other.functionName, functionName) || other.functionName == functionName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,blockNumber,timeStamp,hash,transactionIndex,from,to,value,gas,gasPrice,isError,input,contractAddress,cumulativeGasUsed,gasUsed,confirmations,methodId,functionName);

@override
String toString() {
  return 'TransactionRecord(blockNumber: $blockNumber, timeStamp: $timeStamp, hash: $hash, transactionIndex: $transactionIndex, from: $from, to: $to, value: $value, gas: $gas, gasPrice: $gasPrice, isError: $isError, input: $input, contractAddress: $contractAddress, cumulativeGasUsed: $cumulativeGasUsed, gasUsed: $gasUsed, confirmations: $confirmations, methodId: $methodId, functionName: $functionName)';
}


}

/// @nodoc
abstract mixin class _$TransactionRecordCopyWith<$Res> implements $TransactionRecordCopyWith<$Res> {
  factory _$TransactionRecordCopyWith(_TransactionRecord value, $Res Function(_TransactionRecord) _then) = __$TransactionRecordCopyWithImpl;
@override @useResult
$Res call({
 int blockNumber, int timeStamp, String hash, int transactionIndex, String from, String to, int value, int gas, int gasPrice, int isError, String input, String contractAddress, int cumulativeGasUsed, int gasUsed, int confirmations, int methodId, String functionName
});




}
/// @nodoc
class __$TransactionRecordCopyWithImpl<$Res>
    implements _$TransactionRecordCopyWith<$Res> {
  __$TransactionRecordCopyWithImpl(this._self, this._then);

  final _TransactionRecord _self;
  final $Res Function(_TransactionRecord) _then;

/// Create a copy of TransactionRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? blockNumber = null,Object? timeStamp = null,Object? hash = null,Object? transactionIndex = null,Object? from = null,Object? to = null,Object? value = null,Object? gas = null,Object? gasPrice = null,Object? isError = null,Object? input = null,Object? contractAddress = null,Object? cumulativeGasUsed = null,Object? gasUsed = null,Object? confirmations = null,Object? methodId = null,Object? functionName = null,}) {
  return _then(_TransactionRecord(
blockNumber: null == blockNumber ? _self.blockNumber : blockNumber // ignore: cast_nullable_to_non_nullable
as int,timeStamp: null == timeStamp ? _self.timeStamp : timeStamp // ignore: cast_nullable_to_non_nullable
as int,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,transactionIndex: null == transactionIndex ? _self.transactionIndex : transactionIndex // ignore: cast_nullable_to_non_nullable
as int,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,gas: null == gas ? _self.gas : gas // ignore: cast_nullable_to_non_nullable
as int,gasPrice: null == gasPrice ? _self.gasPrice : gasPrice // ignore: cast_nullable_to_non_nullable
as int,isError: null == isError ? _self.isError : isError // ignore: cast_nullable_to_non_nullable
as int,input: null == input ? _self.input : input // ignore: cast_nullable_to_non_nullable
as String,contractAddress: null == contractAddress ? _self.contractAddress : contractAddress // ignore: cast_nullable_to_non_nullable
as String,cumulativeGasUsed: null == cumulativeGasUsed ? _self.cumulativeGasUsed : cumulativeGasUsed // ignore: cast_nullable_to_non_nullable
as int,gasUsed: null == gasUsed ? _self.gasUsed : gasUsed // ignore: cast_nullable_to_non_nullable
as int,confirmations: null == confirmations ? _self.confirmations : confirmations // ignore: cast_nullable_to_non_nullable
as int,methodId: null == methodId ? _self.methodId : methodId // ignore: cast_nullable_to_non_nullable
as int,functionName: null == functionName ? _self.functionName : functionName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
