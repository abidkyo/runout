// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchConfig _$MatchConfigFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MatchConfig', json, ($checkedConvert) {
      final val = MatchConfig(
        matchMode: $checkedConvert(
          'matchMode',
          (v) => $enumDecode(_$MatchModeEnumMap, v),
        ),
        gameType: $checkedConvert(
          'gameType',
          (v) => $enumDecode(_$GameTypeEnumMap, v),
        ),
        raceTo: $checkedConvert('raceTo', (v) => (v as num).toInt()),
        breakFormat: $checkedConvert(
          'breakFormat',
          (v) => $enumDecode(_$BreakFormatEnumMap, v),
        ),
        inningsLimit: $checkedConvert(
          'inningsLimit',
          (v) => (v as num?)?.toInt() ?? 0,
        ),
      );
      return val;
    });

Map<String, dynamic> _$MatchConfigToJson(MatchConfig instance) =>
    <String, dynamic>{
      'matchMode': _$MatchModeEnumMap[instance.matchMode]!,
      'gameType': _$GameTypeEnumMap[instance.gameType]!,
      'raceTo': instance.raceTo,
      'breakFormat': _$BreakFormatEnumMap[instance.breakFormat]!,
      'inningsLimit': instance.inningsLimit,
    };

const _$MatchModeEnumMap = {
  MatchMode.singles: 'singles',
  MatchMode.doubles: 'doubles',
  MatchMode.threePlayer: 'threePlayer',
};

const _$GameTypeEnumMap = {
  GameType.eightBall: 'eightBall',
  GameType.nineBall: 'nineBall',
  GameType.tenBall: 'tenBall',
  GameType.straightPool: 'straightPool',
};

const _$BreakFormatEnumMap = {
  BreakFormat.winnerBreak: 'winnerBreak',
  BreakFormat.alternateBreak: 'alternateBreak',
};
