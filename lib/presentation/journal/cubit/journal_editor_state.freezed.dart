// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'journal_editor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$JournalEditorState {
  JournalEditorStatus get status => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of JournalEditorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JournalEditorStateCopyWith<JournalEditorState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JournalEditorStateCopyWith<$Res> {
  factory $JournalEditorStateCopyWith(
    JournalEditorState value,
    $Res Function(JournalEditorState) then,
  ) = _$JournalEditorStateCopyWithImpl<$Res, JournalEditorState>;
  @useResult
  $Res call({JournalEditorStatus status, String? errorMessage});
}

/// @nodoc
class _$JournalEditorStateCopyWithImpl<$Res, $Val extends JournalEditorState>
    implements $JournalEditorStateCopyWith<$Res> {
  _$JournalEditorStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JournalEditorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? status = null, Object? errorMessage = freezed}) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as JournalEditorStatus,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JournalEditorStateImplCopyWith<$Res>
    implements $JournalEditorStateCopyWith<$Res> {
  factory _$$JournalEditorStateImplCopyWith(
    _$JournalEditorStateImpl value,
    $Res Function(_$JournalEditorStateImpl) then,
  ) = __$$JournalEditorStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({JournalEditorStatus status, String? errorMessage});
}

/// @nodoc
class __$$JournalEditorStateImplCopyWithImpl<$Res>
    extends _$JournalEditorStateCopyWithImpl<$Res, _$JournalEditorStateImpl>
    implements _$$JournalEditorStateImplCopyWith<$Res> {
  __$$JournalEditorStateImplCopyWithImpl(
    _$JournalEditorStateImpl _value,
    $Res Function(_$JournalEditorStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JournalEditorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? status = null, Object? errorMessage = freezed}) {
    return _then(
      _$JournalEditorStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as JournalEditorStatus,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$JournalEditorStateImpl implements _JournalEditorState {
  const _$JournalEditorStateImpl({
    this.status = JournalEditorStatus.initial,
    this.errorMessage,
  });

  @override
  @JsonKey()
  final JournalEditorStatus status;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'JournalEditorState(status: $status, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JournalEditorStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status, errorMessage);

  /// Create a copy of JournalEditorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JournalEditorStateImplCopyWith<_$JournalEditorStateImpl> get copyWith =>
      __$$JournalEditorStateImplCopyWithImpl<_$JournalEditorStateImpl>(
        this,
        _$identity,
      );
}

abstract class _JournalEditorState implements JournalEditorState {
  const factory _JournalEditorState({
    final JournalEditorStatus status,
    final String? errorMessage,
  }) = _$JournalEditorStateImpl;

  @override
  JournalEditorStatus get status;
  @override
  String? get errorMessage;

  /// Create a copy of JournalEditorState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JournalEditorStateImplCopyWith<_$JournalEditorStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
