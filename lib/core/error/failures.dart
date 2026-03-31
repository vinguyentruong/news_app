// lib/core/error/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please check your network.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error. Please try again later.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to load cached data.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'No results found.']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Invalid API key. Please check your configuration.']);
}
