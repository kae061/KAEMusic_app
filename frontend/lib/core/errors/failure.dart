import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({required super.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;
  const ValidationFailure({required super.message, this.fieldErrors});

  @override
  List<Object?> get props => [message, fieldErrors];
}

class UnknownFailure extends Failure {
  const UnknownFailure({required super.message});
}
