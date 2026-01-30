import 'package:dartz/dartz.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

abstract class UsecaseWithParms<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}
