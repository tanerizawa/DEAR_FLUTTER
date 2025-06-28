// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginRequestImpl _$$LoginRequestImplFromJson(Map<String, dynamic> json) =>
    _$LoginRequestImpl(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$$LoginRequestImplToJson(_$LoginRequestImpl instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

_$RegisterRequestImpl _$$RegisterRequestImplFromJson(
  Map<String, dynamic> json,
) => _$RegisterRequestImpl(
  username: json['username'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$$RegisterRequestImplToJson(
  _$RegisterRequestImpl instance,
) => <String, dynamic>{
  'username': instance.username,
  'email': instance.email,
  'password': instance.password,
};

_$CreateJournalRequestImpl _$$CreateJournalRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateJournalRequestImpl(
  title: json['title'] as String,
  content: json['content'] as String,
  mood: json['mood'] as String,
);

Map<String, dynamic> _$$CreateJournalRequestImplToJson(
  _$CreateJournalRequestImpl instance,
) => <String, dynamic>{
  'title': instance.title,
  'content': instance.content,
  'mood': instance.mood,
};
