import 'package:dartz/dartz.dart';
import 'package:pruebatecnica/core/error/failures.dart';
import 'package:pruebatecnica/features/auth/domain/entities/session.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> requestCode(String phone);

  Future<Either<Failure, Session>> verifyCode({
    required String phone,
    required String code,
  });

  Future<Either<Failure, Session?>> currentSession();

  Future<Either<Failure, Unit>> signOut();
}
