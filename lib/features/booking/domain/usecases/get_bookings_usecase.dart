import 'package:trip_wise_nepal/features/booking/data/repositories/booking_repository.dart';
import 'package:trip_wise_nepal/features/booking/domain/entities/booking_entity.dart';

class GetBookingsUseCase {
  final BookingRepository _repository;
  GetBookingsUseCase(this._repository);

  Future<List<BookingEntity>> call() async {
    return await _repository.getBookings();
  }
}
