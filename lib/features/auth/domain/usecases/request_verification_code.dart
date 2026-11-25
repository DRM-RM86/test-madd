import 'package:dartz/dartz.dart';
import 'package:pruebatecnica/core/error/failures.dart';
import 'package:pruebatecnica/core/usecases/usecase.dart';
import 'package:pruebatecnica/features/auth/domain/repositories/auth_repository.dart';

class RequestVerificationCode implements UseCase<String, String> {
  RequestVerificationCode(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, String>> call(String params) {
    return repository.requestCode(params);
  }
}
