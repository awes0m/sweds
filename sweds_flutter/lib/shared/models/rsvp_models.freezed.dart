// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rsvp_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RsvpSubmission {

 String get name; String get email; String get phone; Attendance get attendance; int get guests; String get message;
/// Create a copy of RsvpSubmission
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RsvpSubmissionCopyWith<RsvpSubmission> get copyWith => _$RsvpSubmissionCopyWithImpl<RsvpSubmission>(this as RsvpSubmission, _$identity);

  /// Serializes this RsvpSubmission to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RsvpSubmission&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.attendance, attendance) || other.attendance == attendance)&&(identical(other.guests, guests) || other.guests == guests)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email,phone,attendance,guests,message);

@override
String toString() {
  return 'RsvpSubmission(name: $name, email: $email, phone: $phone, attendance: $attendance, guests: $guests, message: $message)';
}


}

/// @nodoc
abstract mixin class $RsvpSubmissionCopyWith<$Res>  {
  factory $RsvpSubmissionCopyWith(RsvpSubmission value, $Res Function(RsvpSubmission) _then) = _$RsvpSubmissionCopyWithImpl;
@useResult
$Res call({
 String name, String email, String phone, Attendance attendance, int guests, String message
});




}
/// @nodoc
class _$RsvpSubmissionCopyWithImpl<$Res>
    implements $RsvpSubmissionCopyWith<$Res> {
  _$RsvpSubmissionCopyWithImpl(this._self, this._then);

  final RsvpSubmission _self;
  final $Res Function(RsvpSubmission) _then;

/// Create a copy of RsvpSubmission
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? email = null,Object? phone = null,Object? attendance = null,Object? guests = null,Object? message = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,attendance: null == attendance ? _self.attendance : attendance // ignore: cast_nullable_to_non_nullable
as Attendance,guests: null == guests ? _self.guests : guests // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RsvpSubmission].
extension RsvpSubmissionPatterns on RsvpSubmission {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RsvpSubmission value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RsvpSubmission() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RsvpSubmission value)  $default,){
final _that = this;
switch (_that) {
case _RsvpSubmission():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RsvpSubmission value)?  $default,){
final _that = this;
switch (_that) {
case _RsvpSubmission() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String email,  String phone,  Attendance attendance,  int guests,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RsvpSubmission() when $default != null:
return $default(_that.name,_that.email,_that.phone,_that.attendance,_that.guests,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String email,  String phone,  Attendance attendance,  int guests,  String message)  $default,) {final _that = this;
switch (_that) {
case _RsvpSubmission():
return $default(_that.name,_that.email,_that.phone,_that.attendance,_that.guests,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String email,  String phone,  Attendance attendance,  int guests,  String message)?  $default,) {final _that = this;
switch (_that) {
case _RsvpSubmission() when $default != null:
return $default(_that.name,_that.email,_that.phone,_that.attendance,_that.guests,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RsvpSubmission implements RsvpSubmission {
  const _RsvpSubmission({required this.name, required this.email, required this.phone, required this.attendance, required this.guests, this.message = ''});
  factory _RsvpSubmission.fromJson(Map<String, dynamic> json) => _$RsvpSubmissionFromJson(json);

@override final  String name;
@override final  String email;
@override final  String phone;
@override final  Attendance attendance;
@override final  int guests;
@override@JsonKey() final  String message;

/// Create a copy of RsvpSubmission
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RsvpSubmissionCopyWith<_RsvpSubmission> get copyWith => __$RsvpSubmissionCopyWithImpl<_RsvpSubmission>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RsvpSubmissionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RsvpSubmission&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.attendance, attendance) || other.attendance == attendance)&&(identical(other.guests, guests) || other.guests == guests)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email,phone,attendance,guests,message);

@override
String toString() {
  return 'RsvpSubmission(name: $name, email: $email, phone: $phone, attendance: $attendance, guests: $guests, message: $message)';
}


}

/// @nodoc
abstract mixin class _$RsvpSubmissionCopyWith<$Res> implements $RsvpSubmissionCopyWith<$Res> {
  factory _$RsvpSubmissionCopyWith(_RsvpSubmission value, $Res Function(_RsvpSubmission) _then) = __$RsvpSubmissionCopyWithImpl;
@override @useResult
$Res call({
 String name, String email, String phone, Attendance attendance, int guests, String message
});




}
/// @nodoc
class __$RsvpSubmissionCopyWithImpl<$Res>
    implements _$RsvpSubmissionCopyWith<$Res> {
  __$RsvpSubmissionCopyWithImpl(this._self, this._then);

  final _RsvpSubmission _self;
  final $Res Function(_RsvpSubmission) _then;

/// Create a copy of RsvpSubmission
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? email = null,Object? phone = null,Object? attendance = null,Object? guests = null,Object? message = null,}) {
  return _then(_RsvpSubmission(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,attendance: null == attendance ? _self.attendance : attendance // ignore: cast_nullable_to_non_nullable
as Attendance,guests: null == guests ? _self.guests : guests // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$RsvpFormState {

 String get name; String get email; String get phone; Attendance get attendance; int get guests; String get message; RsvpStatus get status; bool get showErrors;
/// Create a copy of RsvpFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RsvpFormStateCopyWith<RsvpFormState> get copyWith => _$RsvpFormStateCopyWithImpl<RsvpFormState>(this as RsvpFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RsvpFormState&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.attendance, attendance) || other.attendance == attendance)&&(identical(other.guests, guests) || other.guests == guests)&&(identical(other.message, message) || other.message == message)&&(identical(other.status, status) || other.status == status)&&(identical(other.showErrors, showErrors) || other.showErrors == showErrors));
}


@override
int get hashCode => Object.hash(runtimeType,name,email,phone,attendance,guests,message,status,showErrors);

@override
String toString() {
  return 'RsvpFormState(name: $name, email: $email, phone: $phone, attendance: $attendance, guests: $guests, message: $message, status: $status, showErrors: $showErrors)';
}


}

/// @nodoc
abstract mixin class $RsvpFormStateCopyWith<$Res>  {
  factory $RsvpFormStateCopyWith(RsvpFormState value, $Res Function(RsvpFormState) _then) = _$RsvpFormStateCopyWithImpl;
@useResult
$Res call({
 String name, String email, String phone, Attendance attendance, int guests, String message, RsvpStatus status, bool showErrors
});




}
/// @nodoc
class _$RsvpFormStateCopyWithImpl<$Res>
    implements $RsvpFormStateCopyWith<$Res> {
  _$RsvpFormStateCopyWithImpl(this._self, this._then);

  final RsvpFormState _self;
  final $Res Function(RsvpFormState) _then;

/// Create a copy of RsvpFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? email = null,Object? phone = null,Object? attendance = null,Object? guests = null,Object? message = null,Object? status = null,Object? showErrors = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,attendance: null == attendance ? _self.attendance : attendance // ignore: cast_nullable_to_non_nullable
as Attendance,guests: null == guests ? _self.guests : guests // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RsvpStatus,showErrors: null == showErrors ? _self.showErrors : showErrors // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RsvpFormState].
extension RsvpFormStatePatterns on RsvpFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RsvpFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RsvpFormState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RsvpFormState value)  $default,){
final _that = this;
switch (_that) {
case _RsvpFormState():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RsvpFormState value)?  $default,){
final _that = this;
switch (_that) {
case _RsvpFormState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String email,  String phone,  Attendance attendance,  int guests,  String message,  RsvpStatus status,  bool showErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RsvpFormState() when $default != null:
return $default(_that.name,_that.email,_that.phone,_that.attendance,_that.guests,_that.message,_that.status,_that.showErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String email,  String phone,  Attendance attendance,  int guests,  String message,  RsvpStatus status,  bool showErrors)  $default,) {final _that = this;
switch (_that) {
case _RsvpFormState():
return $default(_that.name,_that.email,_that.phone,_that.attendance,_that.guests,_that.message,_that.status,_that.showErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String email,  String phone,  Attendance attendance,  int guests,  String message,  RsvpStatus status,  bool showErrors)?  $default,) {final _that = this;
switch (_that) {
case _RsvpFormState() when $default != null:
return $default(_that.name,_that.email,_that.phone,_that.attendance,_that.guests,_that.message,_that.status,_that.showErrors);case _:
  return null;

}
}

}

/// @nodoc


class _RsvpFormState extends RsvpFormState {
  const _RsvpFormState({this.name = '', this.email = '', this.phone = '', this.attendance = Attendance.accepts, this.guests = 1, this.message = '', this.status = RsvpStatus.editing, this.showErrors = false}): super._();
  

@override@JsonKey() final  String name;
@override@JsonKey() final  String email;
@override@JsonKey() final  String phone;
@override@JsonKey() final  Attendance attendance;
@override@JsonKey() final  int guests;
@override@JsonKey() final  String message;
@override@JsonKey() final  RsvpStatus status;
@override@JsonKey() final  bool showErrors;

/// Create a copy of RsvpFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RsvpFormStateCopyWith<_RsvpFormState> get copyWith => __$RsvpFormStateCopyWithImpl<_RsvpFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RsvpFormState&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.attendance, attendance) || other.attendance == attendance)&&(identical(other.guests, guests) || other.guests == guests)&&(identical(other.message, message) || other.message == message)&&(identical(other.status, status) || other.status == status)&&(identical(other.showErrors, showErrors) || other.showErrors == showErrors));
}


@override
int get hashCode => Object.hash(runtimeType,name,email,phone,attendance,guests,message,status,showErrors);

@override
String toString() {
  return 'RsvpFormState(name: $name, email: $email, phone: $phone, attendance: $attendance, guests: $guests, message: $message, status: $status, showErrors: $showErrors)';
}


}

/// @nodoc
abstract mixin class _$RsvpFormStateCopyWith<$Res> implements $RsvpFormStateCopyWith<$Res> {
  factory _$RsvpFormStateCopyWith(_RsvpFormState value, $Res Function(_RsvpFormState) _then) = __$RsvpFormStateCopyWithImpl;
@override @useResult
$Res call({
 String name, String email, String phone, Attendance attendance, int guests, String message, RsvpStatus status, bool showErrors
});




}
/// @nodoc
class __$RsvpFormStateCopyWithImpl<$Res>
    implements _$RsvpFormStateCopyWith<$Res> {
  __$RsvpFormStateCopyWithImpl(this._self, this._then);

  final _RsvpFormState _self;
  final $Res Function(_RsvpFormState) _then;

/// Create a copy of RsvpFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? email = null,Object? phone = null,Object? attendance = null,Object? guests = null,Object? message = null,Object? status = null,Object? showErrors = null,}) {
  return _then(_RsvpFormState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,attendance: null == attendance ? _self.attendance : attendance // ignore: cast_nullable_to_non_nullable
as Attendance,guests: null == guests ? _self.guests : guests // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RsvpStatus,showErrors: null == showErrors ? _self.showErrors : showErrors // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
