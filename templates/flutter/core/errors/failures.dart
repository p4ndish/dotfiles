import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  abstract final String errorMessage;
  @override
  List<Object?> get props => [];
}

class ServerFailure extends Failure {
  final String errorMessage;

  ServerFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class CacheFailure extends Failure {
  @override
  final String errorMessage;
  CacheFailure({this.errorMessage = 'Cache failure'});
}

class NetworkFailure extends Failure {
  @override
  final String errorMessage;
  NetworkFailure({this.errorMessage = 'No internet connection'});
}

class UnauthorizedRequestFailure extends Failure {
  @override
  final String errorMessage;

  UnauthorizedRequestFailure({this.errorMessage = 'User not authenticated'});
}

class AnonymousFailure extends Failure {
  @override
  final String errorMessage;
  AnonymousFailure({this.errorMessage = 'Unknown error happened'});
}

class AuthenticationFailure extends Failure {
  @override
  final String errorMessage;

  AuthenticationFailure({
    required this.errorMessage,
  });
}
class TokenExpireFailure extends Failure {
  @override
  final String errorMessage;

  TokenExpireFailure({
    required this.errorMessage,
  });
}


class BadRequestFailure extends Failure {
  final String errorMessage;

  BadRequestFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class RequestFailure extends Failure {
  final String errorMessage;

  RequestFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

