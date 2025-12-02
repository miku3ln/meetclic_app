sealed class Failure implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
  const Failure(this.message, {this.cause, this.stackTrace});
  @override
  String toString() => '$runtimeType: $message';
}

class PermissionFailure extends Failure {
  const PermissionFailure(String message, {Object? cause, StackTrace? stackTrace})
      : super(message, cause: cause, stackTrace: stackTrace);
}

class ServiceDisabledFailure extends Failure {
  const ServiceDisabledFailure(String message, {Object? cause, StackTrace? stackTrace})
      : super(message, cause: cause, stackTrace: stackTrace);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure(String message, {Object? cause, StackTrace? stackTrace})
      : super(message, cause: cause, stackTrace: stackTrace);
}

class UnknownFailure extends Failure {
  const UnknownFailure(String message, {Object? cause, StackTrace? stackTrace})
      : super(message, cause: cause, stackTrace: stackTrace);
}
