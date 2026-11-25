import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure([this.message = '']);

  final String message;

  @override
  List<Object> get props => [message];
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message]);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message]);
}

final class ValidationFailure extends Failure {
  const ValidationFailure([super.message]);
}

final class NotificationFailure extends Failure {
  const NotificationFailure([super.message]);
}
