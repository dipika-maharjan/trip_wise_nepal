import 'package:trip_wise_nepal/features/booking/data/repositories/booking_repository.dart';
import 'package:trip_wise_nepal/features/booking/domain/entities/booking_entity.dart';

class CreateBookingUseCase {
  final BookingRepository _repository;
  CreateBookingUseCase(this._repository);

  Future<BookingEntity?> call(Map<String, dynamic> bookingData) async {
    return await _repository.createBooking(bookingData);
  }
}
