import 'package:dartz/dartz.dart';
import 'package:pruebatecnica/core/error/failures.dart';
import 'package:pruebatecnica/core/usecases/usecase.dart';
import 'package:pruebatecnica/features/auth/domain/entities/session.dart';
import 'package:pruebatecnica/features/auth/domain/repositories/auth_repository.dart';

class GetSession implements UseCase<Session?, NoParams> {
  GetSession(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, Session?>> call(NoParams params) {
    return repository.currentSession();
  }
}
