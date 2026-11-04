import 'package:equatable/equatable.dart';

enum FailureKind { noConnection, timeout, clientError, serverError, unexpected }

class AppFailure extends Equatable implements Exception {
  const AppFailure(this.kind, {this.statusCode});
  final FailureKind kind;
  final int? statusCode;

  @override
  List<Object?> get props => [kind, statusCode];
}
