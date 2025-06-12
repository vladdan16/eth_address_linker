import 'package:freezed_annotation/freezed_annotation.dart';

part 'predicted_pair.freezed.dart';

@freezed
class PredictedPair with _$PredictedPair {
  const PredictedPair({
    required this.index,
    required this.depHash,
    required this.witHash,
    required this.sender,
    required this.receiver,
  });

  @override
  final int index;
  @override
  final String depHash;
  @override
  final String witHash;
  @override
  final String sender;
  @override
  final String receiver;
}
