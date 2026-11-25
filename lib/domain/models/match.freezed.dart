// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Match {


/// Create a copy of Match
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchCopyWith<Match> get copyWith => _$MatchCopyWithImpl<Match>(this as Match, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Match;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Match&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.config, _this.config) || other.config == _this.config)&&const DeepCollectionEquality().equals(other.sides, _this.sides)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.currentSideIndex, _this.currentSideIndex) || other.currentSideIndex == _this.currentSideIndex)&&(identical(other.winnerIndex, _this.winnerIndex) || other.winnerIndex == _this.winnerIndex)&&(identical(other.effectiveInningsLimit, _this.effectiveInningsLimit) || other.effectiveInningsLimit == _this.effectiveInningsLimit)&&(identical(other.currentRun, _this.currentRun) || other.currentRun == _this.currentRun)&&(identical(other.ballsRemaining, _this.ballsRemaining) || other.ballsRemaining == _this.ballsRemaining)&&(identical(other.isOpeningBreak, _this.isOpeningBreak) || other.isOpeningBreak == _this.isOpeningBreak)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.endedAt, _this.endedAt) || other.endedAt == _this.endedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Match;
  return Object.hash(runtimeType,_this.id,_this.config,const DeepCollectionEquality().hash(_this.sides),_this.status,_this.currentSideIndex,_this.winnerIndex,_this.effectiveInningsLimit,_this.currentRun,_this.ballsRemaining,_this.isOpeningBreak,_this.startedAt,_this.endedAt);
}

@override
String toString() {
  final _this = this as Match;
  return 'Match(id: ${_this.id}, config: ${_this.config}, sides: ${_this.sides}, status: ${_this.status}, currentSideIndex: ${_this.currentSideIndex}, winnerIndex: ${_this.winnerIndex}, effectiveInningsLimit: ${_this.effectiveInningsLimit}, currentRun: ${_this.currentRun}, ballsRemaining: ${_this.ballsRemaining}, isOpeningBreak: ${_this.isOpeningBreak}, startedAt: ${_this.startedAt}, endedAt: ${_this.endedAt})';
}


}

/// @nodoc
abstract mixin class $MatchCopyWith<$Res>  {
  factory $MatchCopyWith(Match value, $Res Function(Match) _then) = _$MatchCopyWithImpl;
@useResult
$Res call({
 String id, MatchConfig config, List<MatchSide> sides, MatchStatus status, int? currentSideIndex, int? winnerIndex, int effectiveInningsLimit, int currentRun, int ballsRemaining, bool isOpeningBreak, DateTime? startedAt, DateTime? endedAt
});


$MatchConfigCopyWith<$Res> get config;

}
/// @nodoc
class _$MatchCopyWithImpl<$Res>
    implements $MatchCopyWith<$Res> {
  _$MatchCopyWithImpl(this._self, this._then);

  final Match _self;
  final $Res Function(Match) _then;

/// Create a copy of Match
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? config = null,Object? sides = null,Object? status = null,Object? currentSideIndex = freezed,Object? winnerIndex = freezed,Object? effectiveInningsLimit = null,Object? currentRun = null,Object? ballsRemaining = null,Object? isOpeningBreak = null,Object? startedAt = freezed,Object? endedAt = freezed,}) {
  return _then(Match(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as MatchConfig,sides: null == sides ? _self.sides : sides // ignore: cast_nullable_to_non_nullable
as List<MatchSide>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MatchStatus,currentSideIndex: freezed == currentSideIndex ? _self.currentSideIndex : currentSideIndex // ignore: cast_nullable_to_non_nullable
as int?,winnerIndex: freezed == winnerIndex ? _self.winnerIndex : winnerIndex // ignore: cast_nullable_to_non_nullable
as int?,effectiveInningsLimit: null == effectiveInningsLimit ? _self.effectiveInningsLimit : effectiveInningsLimit // ignore: cast_nullable_to_non_nullable
as int,currentRun: null == currentRun ? _self.currentRun : currentRun // ignore: cast_nullable_to_non_nullable
as int,ballsRemaining: null == ballsRemaining ? _self.ballsRemaining : ballsRemaining // ignore: cast_nullable_to_non_nullable
as int,isOpeningBreak: null == isOpeningBreak ? _self.isOpeningBreak : isOpeningBreak // ignore: cast_nullable_to_non_nullable
as bool,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Match
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchConfigCopyWith<$Res> get config {
  
  return $MatchConfigCopyWith<$Res>(_self.config, (value) {
    return _then(_self.copyWith(config: value));
  });
}
}


/// Adds pattern-matching-related methods to [Match].
extension MatchPatterns on Match {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({required TResult orElse(),}){
final _that = this;
switch (_that) {
case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({required TResult orElse(),}) {final _that = this;
switch (_that) {
case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
  return null;

}
}

}

// dart format on
