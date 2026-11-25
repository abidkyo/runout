// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MatchConfig {


/// Create a copy of MatchConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchConfigCopyWith<MatchConfig> get copyWith => _$MatchConfigCopyWithImpl<MatchConfig>(this as MatchConfig, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MatchConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchConfig&&(identical(other.matchMode, _this.matchMode) || other.matchMode == _this.matchMode)&&(identical(other.gameType, _this.gameType) || other.gameType == _this.gameType)&&(identical(other.raceTo, _this.raceTo) || other.raceTo == _this.raceTo)&&(identical(other.breakFormat, _this.breakFormat) || other.breakFormat == _this.breakFormat)&&(identical(other.inningsLimit, _this.inningsLimit) || other.inningsLimit == _this.inningsLimit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MatchConfig;
  return Object.hash(runtimeType,_this.matchMode,_this.gameType,_this.raceTo,_this.breakFormat,_this.inningsLimit);
}

@override
String toString() {
  final _this = this as MatchConfig;
  return 'MatchConfig(matchMode: ${_this.matchMode}, gameType: ${_this.gameType}, raceTo: ${_this.raceTo}, breakFormat: ${_this.breakFormat}, inningsLimit: ${_this.inningsLimit})';
}


}

/// @nodoc
abstract mixin class $MatchConfigCopyWith<$Res>  {
  factory $MatchConfigCopyWith(MatchConfig value, $Res Function(MatchConfig) _then) = _$MatchConfigCopyWithImpl;
@useResult
$Res call({
 MatchMode matchMode, GameType gameType, int raceTo, BreakFormat breakFormat, int inningsLimit
});




}
/// @nodoc
class _$MatchConfigCopyWithImpl<$Res>
    implements $MatchConfigCopyWith<$Res> {
  _$MatchConfigCopyWithImpl(this._self, this._then);

  final MatchConfig _self;
  final $Res Function(MatchConfig) _then;

/// Create a copy of MatchConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? matchMode = null,Object? gameType = null,Object? raceTo = null,Object? breakFormat = null,Object? inningsLimit = null,}) {
  return _then(MatchConfig(
matchMode: null == matchMode ? _self.matchMode : matchMode // ignore: cast_nullable_to_non_nullable
as MatchMode,gameType: null == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as GameType,raceTo: null == raceTo ? _self.raceTo : raceTo // ignore: cast_nullable_to_non_nullable
as int,breakFormat: null == breakFormat ? _self.breakFormat : breakFormat // ignore: cast_nullable_to_non_nullable
as BreakFormat,inningsLimit: null == inningsLimit ? _self.inningsLimit : inningsLimit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchConfig].
extension MatchConfigPatterns on MatchConfig {
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
