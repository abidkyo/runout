// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_side.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MatchSide {


/// Create a copy of MatchSide
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchSideCopyWith<MatchSide> get copyWith => _$MatchSideCopyWithImpl<MatchSide>(this as MatchSide, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MatchSide;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchSide&&const DeepCollectionEquality().equals(other.players, _this.players)&&(identical(other.score, _this.score) || other.score == _this.score)&&(identical(other.innings, _this.innings) || other.innings == _this.innings)&&(identical(other.highRun, _this.highRun) || other.highRun == _this.highRun)&&(identical(other.consecutiveFouls, _this.consecutiveFouls) || other.consecutiveFouls == _this.consecutiveFouls));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MatchSide;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.players),_this.score,_this.innings,_this.highRun,_this.consecutiveFouls);
}

@override
String toString() {
  final _this = this as MatchSide;
  return 'MatchSide(players: ${_this.players}, score: ${_this.score}, innings: ${_this.innings}, highRun: ${_this.highRun}, consecutiveFouls: ${_this.consecutiveFouls})';
}


}

/// @nodoc
abstract mixin class $MatchSideCopyWith<$Res>  {
  factory $MatchSideCopyWith(MatchSide value, $Res Function(MatchSide) _then) = _$MatchSideCopyWithImpl;
@useResult
$Res call({
 List<Player> players, int score, int innings, int highRun, int consecutiveFouls
});




}
/// @nodoc
class _$MatchSideCopyWithImpl<$Res>
    implements $MatchSideCopyWith<$Res> {
  _$MatchSideCopyWithImpl(this._self, this._then);

  final MatchSide _self;
  final $Res Function(MatchSide) _then;

/// Create a copy of MatchSide
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? players = null,Object? score = null,Object? innings = null,Object? highRun = null,Object? consecutiveFouls = null,}) {
  return _then(MatchSide(
players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as List<Player>,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,innings: null == innings ? _self.innings : innings // ignore: cast_nullable_to_non_nullable
as int,highRun: null == highRun ? _self.highRun : highRun // ignore: cast_nullable_to_non_nullable
as int,consecutiveFouls: null == consecutiveFouls ? _self.consecutiveFouls : consecutiveFouls // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchSide].
extension MatchSidePatterns on MatchSide {
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
