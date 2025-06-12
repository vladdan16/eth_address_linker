// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'predicted_pair.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PredictedPair {

 int get index; String get depHash; String get witHash; String get sender; String get receiver;
/// Create a copy of PredictedPair
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PredictedPairCopyWith<PredictedPair> get copyWith => _$PredictedPairCopyWithImpl<PredictedPair>(this as PredictedPair, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PredictedPair&&(identical(other.index, index) || other.index == index)&&(identical(other.depHash, depHash) || other.depHash == depHash)&&(identical(other.witHash, witHash) || other.witHash == witHash)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.receiver, receiver) || other.receiver == receiver));
}


@override
int get hashCode => Object.hash(runtimeType,index,depHash,witHash,sender,receiver);

@override
String toString() {
  return 'PredictedPair(index: $index, depHash: $depHash, witHash: $witHash, sender: $sender, receiver: $receiver)';
}


}

/// @nodoc
abstract mixin class $PredictedPairCopyWith<$Res>  {
  factory $PredictedPairCopyWith(PredictedPair value, $Res Function(PredictedPair) _then) = _$PredictedPairCopyWithImpl;
@useResult
$Res call({
 int index, String depHash, String witHash, String sender, String receiver
});




}
/// @nodoc
class _$PredictedPairCopyWithImpl<$Res>
    implements $PredictedPairCopyWith<$Res> {
  _$PredictedPairCopyWithImpl(this._self, this._then);

  final PredictedPair _self;
  final $Res Function(PredictedPair) _then;

/// Create a copy of PredictedPair
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? index = null,Object? depHash = null,Object? witHash = null,Object? sender = null,Object? receiver = null,}) {
  return _then(PredictedPair(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,depHash: null == depHash ? _self.depHash : depHash // ignore: cast_nullable_to_non_nullable
as String,witHash: null == witHash ? _self.witHash : witHash // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as String,receiver: null == receiver ? _self.receiver : receiver // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


// dart format on
