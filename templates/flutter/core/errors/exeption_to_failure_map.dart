

import 'package:dime_mobile/core/errors/exceptions.dart';
import 'package:dime_mobile/core/errors/failures.dart';

Failure mapExceptionToFailure(dynamic e) {
  if (e is ServerException) {
    return ServerFailure("Server Error");
  } else if (e is UnauthorizedRequestException) {
    return UnauthorizedRequestFailure();
  } else if (e is CacheException) {
    return CacheFailure();
  } else {
    return AnonymousFailure();
  }
}
