// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Player', json, ($checkedConvert) {
      final val = Player(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        countryCode: $checkedConvert('countryCode', (v) => v as String?),
        clubName: $checkedConvert('clubName', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'countryCode': instance.countryCode,
  'clubName': instance.clubName,
};
