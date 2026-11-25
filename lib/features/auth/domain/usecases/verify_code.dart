import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:pruebatecnica/core/error/failures.dart';
import 'package:pruebatecnica/core/usecases/usecase.dart';
import 'package:pruebatecnica/features/auth/domain/entities/session.dart';
import 'package:pruebatecnica/features/auth/domain/repositories/auth_repository.dart';

class VerifyCodeParams extends Equatable {
  const VerifyCodeParams({required this.phone, required this.code});

  final String phone;
  final String code;

  @override
  List<Object> get props => [phone, code];
}

class VerifyCode implements UseCase<Session, VerifyCodeParams> {
  VerifyCode(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, Session>> call(VerifyCodeParams params) {
    return repository.verifyCode(phone: params.phone, code: params.code);
  }
}
