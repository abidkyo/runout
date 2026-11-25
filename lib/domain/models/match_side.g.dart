// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_side.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchSide _$MatchSideFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MatchSide', json, ($checkedConvert) {
      final val = MatchSide(
        players: $checkedConvert(
          'players',
          (v) => (v as List<dynamic>)
              .map((e) => Player.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        score: $checkedConvert('score', (v) => (v as num?)?.toInt() ?? 0),
        innings: $checkedConvert('innings', (v) => (v as num?)?.toInt() ?? 0),
        highRun: $checkedConvert('highRun', (v) => (v as num?)?.toInt() ?? 0),
        consecutiveFouls: $checkedConvert(
          'consecutiveFouls',
          (v) => (v as num?)?.toInt() ?? 0,
        ),
      );
      return val;
    });

Map<String, dynamic> _$MatchSideToJson(MatchSide instance) => <String, dynamic>{
  'players': instance.players.map((e) => e.toJson()).toList(),
  'score': instance.score,
  'innings': instance.innings,
  'highRun': instance.highRun,
  'consecutiveFouls': instance.consecutiveFouls,
};
