// lib/data/datasources/remote/journal_api_service.dart

import 'package:dio/dio.dart';
import 'package:dear_flutter/domain/entities/journal.dart';
import 'package:dear_flutter/data/models/requests.dart';
import 'package:injectable/injectable.dart'; // <-- TAMBAHKAN IMPORT INI

@injectable // <-- TAMBAHKAN ANOTASI INI
class JournalApiService {
  final Dio _dio;

  JournalApiService(this._dio);

  Future<List<Journal>> getJournals() async {
    final response = await _dio.get('journals');
    return (response.data as List)
        .map((json) => Journal.fromJson(json))
        .toList();
  }

  Future<Journal> createJournal(CreateJournalRequest request) async {
    final response = await _dio.post(
      'journals',
      data: request.toJson(),
    );
    return Journal.fromJson(response.data);
  }
}