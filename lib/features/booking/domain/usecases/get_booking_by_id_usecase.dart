import 'package:trip_wise_nepal/features/booking/data/repositories/booking_repository.dart';
import 'package:trip_wise_nepal/features/booking/domain/entities/booking_entity.dart';

class GetBookingByIdUseCase {
  final BookingRepository _repository;
  GetBookingByIdUseCase(this._repository);

  Future<BookingEntity?> call(String id) async {
    return await _repository.getBookingById(id);
  }
}
