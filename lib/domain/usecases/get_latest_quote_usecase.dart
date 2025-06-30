import 'package:injectable/injectable.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/domain/repositories/home_repository.dart';

@injectable
class GetLatestQuoteUseCase {
  final HomeRepository _repository;
  GetLatestQuoteUseCase(this._repository);

  Future<MotivationalQuote> call() => _repository.getLatestQuote();
}
