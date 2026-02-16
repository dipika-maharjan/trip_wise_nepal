import 'package:trip_wise_nepal/features/booking/data/repositories/booking_repository.dart';

class CancelBookingUseCase {
  final BookingRepository _repository;
  CancelBookingUseCase(this._repository);

  Future<void> call(String id) async {
    await _repository.cancelBooking(id);
  }
}
