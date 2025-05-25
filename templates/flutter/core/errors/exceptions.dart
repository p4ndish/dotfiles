class ServerException implements Exception {
  final String message;

  ServerException({required this.message});
}

class BadRequestException implements Exception {
  final String message;

  BadRequestException({required this.message});
}

class CacheException implements Exception {}

class NetworkConnectionException implements Exception {}

class UnauthorizedRequestException implements Exception {}

class ClientException implements Exception {
  final String message;

  ClientException({required this.message});
}

class AuthenticationException implements Exception {
  final String errorMessage;

  AuthenticationException({required this.errorMessage});
}

class TokenExpiredException implements Exception {
  final String message;

  TokenExpiredException({required this.message});
}

class NetworkException implements Exception {
  final String message;
  NetworkException({required this.message});
}

class UnexpectedException implements Exception {
  final String message;
  UnexpectedException({required this.message});
}

class RequestCancelledException implements Exception {
  final String message;
  RequestCancelledException({required this.message});
}
