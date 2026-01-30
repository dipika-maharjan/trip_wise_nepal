import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';

abstract interface class IProfileRepository {
  Future<Either<Failure, String>> uploadProfileImage(File imageFile);

}
