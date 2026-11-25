// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Match _$MatchFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('Match', json, ($checkedConvert) {
  final val = Match(
    id: $checkedConvert('id', (v) => v as String),
    config: $checkedConvert(
      'config',
      (v) => MatchConfig.fromJson(v as Map<String, dynamic>),
    ),
    sides: $checkedConvert(
      'sides',
      (v) => (v as List<dynamic>)
          .map((e) => MatchSide.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$MatchStatusEnumMap, v),
    ),
    currentSideIndex: $checkedConvert(
      'currentSideIndex',
      (v) => (v as num?)?.toInt(),
    ),
    winnerIndex: $checkedConvert('winnerIndex', (v) => (v as num?)?.toInt()),
    effectiveInningsLimit: $checkedConvert(
      'effectiveInningsLimit',
      (v) => (v as num?)?.toInt() ?? 0,
    ),
    currentRun: $checkedConvert('currentRun', (v) => (v as num?)?.toInt() ?? 0),
    ballsRemaining: $checkedConvert(
      'ballsRemaining',
      (v) => (v as num?)?.toInt() ?? MatchDefaults.ballsPerRack,
    ),
    isOpeningBreak: $checkedConvert(
      'isOpeningBreak',
      (v) => v as bool? ?? true,
    ),
    startedAt: $checkedConvert(
      'startedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    endedAt: $checkedConvert(
      'endedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
  );
  return val;
});

Map<String, dynamic> _$MatchToJson(Match instance) => <String, dynamic>{
  'id': instance.id,
  'config': instance.config.toJson(),
  'sides': instance.sides.map((e) => e.toJson()).toList(),
  'status': _$MatchStatusEnumMap[instance.status]!,
  'currentSideIndex': instance.currentSideIndex,
  'winnerIndex': instance.winnerIndex,
  'effectiveInningsLimit': instance.effectiveInningsLimit,
  'currentRun': instance.currentRun,
  'ballsRemaining': instance.ballsRemaining,
  'isOpeningBreak': instance.isOpeningBreak,
  'startedAt': instance.startedAt?.toUtc().toIso8601String(),
  'endedAt': instance.endedAt?.toUtc().toIso8601String(),
};

const _$MatchStatusEnumMap = {
  MatchStatus.created: 'created',
  MatchStatus.playing: 'playing',
  MatchStatus.finished: 'finished',
};
