import 'package:flutter/material.dart';
import 'package:trip_wise_nepal/features/booking/presentation/pages/booking_list_screen.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/entities/room_type_entity.dart';
import 'package:trip_wise_nepal/features/accommodation/data/models/optional_extra_api_model.dart';
import 'package:dio/dio.dart';

class BookingFormScreen extends StatefulWidget {
  final String accommodationId;
  final String accommodationName;
  final String accommodationImage;
  final String accommodationLocation;
  final List<RoomTypeEntity> roomTypes;
  final List<OptionalExtraApiModel> optionalExtras;
  final String token; // JWT for Authorization
  final dynamic booking;
  final bool isEdit;

  const BookingFormScreen({
    required this.accommodationId,
    required this.accommodationName,
    required this.accommodationImage,
    required this.accommodationLocation,
    required this.roomTypes,
    required this.optionalExtras,
    required this.token,
    this.booking,
    this.isEdit = false,
    super.key,
  });

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.booking != null) {
      final booking = widget.booking;
      _checkInDate = booking.checkIn;
      _checkOutDate = booking.checkOut;
      _guests = booking.guests;
      _roomsBooked = booking.roomsBooked;
      // _specialRequest = booking.specialRequest; // Uncomment if BookingEntity has this field
      // Prefill selected room type
      try {
        _selectedRoomType = widget.roomTypes.firstWhere((rt) => rt.id == booking.roomTypeId);
      } catch (_) {}
      // Prefill extras
      if (booking.extras is List && booking.extras.isNotEmpty) {
        for (final extra in booking.extras) {
          _extraQuantities[extra.id] = extra.quantity;
        }
      }
    }
    _calculateTotalPrice();
  }
  final _formKey = GlobalKey<FormState>();
  RoomTypeEntity? _selectedRoomType;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guests = 1;
  int _roomsBooked = 1;
  Map<String, int> _extraQuantities = {};
  String? _specialRequest;
  double _totalPrice = 0.0;
  String? _error;
  bool _isLoading = false;

  static const double TAX_PERCENT = 13.0;

  void _calculateTotalPrice() {
    double basePriceTotal = 0.0;
    double extrasTotal = 0.0;
    double tax = 0.0;
    double total = 0.0;
    int nights = 0;
    if (_selectedRoomType != null && _checkInDate != null && _checkOutDate != null) {
      nights = _checkOutDate!.difference(_checkInDate!).inDays;
      basePriceTotal = (_selectedRoomType?.pricePerNight ?? 0) * nights * _roomsBooked;
    }
    for (var extra in widget.optionalExtras) {
      int quantity = _extraQuantities[extra.id] ?? 0;
      if (quantity > 0) {
        if (extra.priceType == 'per_person') {
          extrasTotal += (extra.price ?? 0) * _guests * quantity;
        } else {
          extrasTotal += (extra.price ?? 0) * quantity;
        }
      }
    }
    tax = (basePriceTotal + extrasTotal) * (TAX_PERCENT / 100);
    total = basePriceTotal + extrasTotal + tax;
    setState(() {
      _totalPrice = total;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedRoomType == null || _checkInDate == null || _checkOutDate == null) {
      setState(() { _error = 'Please fill all required fields.'; });
      return;
    }
    setState(() { _isLoading = true; _error = null; });

    // Prepare extras payload
    List<Map<String, dynamic>> extrasPayload = [];
    for (var extra in widget.optionalExtras) {
      int quantity = _extraQuantities[extra.id] ?? 0;
      if (quantity > 0) {
        extrasPayload.add({
          "extraId": extra.id,
          "quantity": quantity,
        });
      }
    }

    final payload = {
      "accommodationId": widget.accommodationId,
      "roomTypeId": _selectedRoomType!.id,
      "checkIn": _checkInDate!.toIso8601String(),
      "checkOut": _checkOutDate!.toIso8601String(),
      "guests": _guests,
      "roomsBooked": _roomsBooked,
      "extras": extrasPayload,
      "specialRequest": _specialRequest ?? '',
      "paymentStatus": "pending"
    };

    try {
      print('[DEBUG] Booking payload: $payload');
      final dio = Dio();
      late Response response;
      if (widget.isEdit && widget.booking != null && widget.booking.id != null) {
        // Update booking (PATCH)
        response = await dio.patch(
          "http://10.0.2.2:5050/api/bookings/${widget.booking.id}",
          data: payload,
          options: Options(
            headers: {
              "Authorization": "Bearer ${widget.token}",
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
          ),
        );
      } else {
        // Create booking (POST)
        response = await dio.post(
          "http://10.0.2.2:5050/api/bookings",
          data: payload,
          options: Options(
            headers: {
              "Authorization": "Bearer ${widget.token}",
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
          ),
        );
      }
      print('[DEBUG] Booking response: ${response.statusCode} ${response.data}');
      final isSuccess = (widget.isEdit ? response.statusCode == 200 : response.statusCode == 201) && response.data['success'] == true;
      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.isEdit ? 'Booking updated!' : 'Booking submitted!')));
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => BookingListScreen()),
            (route) => false,
          );
        });
      } else {
        setState(() { _error = response.data['message'] ?? (widget.isEdit ? 'Update failed.' : 'Booking failed.'); });
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        print('[DEBUG] Booking error response: ${e.response?.data}');
        setState(() { _error = (widget.isEdit ? 'Update failed: ' : 'Booking failed: ') + (e.response?.data?.toString() ?? e.toString()); });
      } else {
        print('[DEBUG] Booking error: $e');
        setState(() { _error = (widget.isEdit ? 'Update failed: ' : 'Booking failed: ') + e.toString(); });
      }
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    double basePriceTotal = 0.0;
    double extrasTotal = 0.0;
    double tax = 0.0;
    int nights = 0;
    if (_selectedRoomType != null && _checkInDate != null && _checkOutDate != null) {
      nights = _checkOutDate!.difference(_checkInDate!).inDays;
      basePriceTotal = (_selectedRoomType?.pricePerNight ?? 0) * nights * _roomsBooked;
    }
    for (var extra in widget.optionalExtras) {
      int quantity = _extraQuantities[extra.id] ?? 0;
      if (quantity > 0) {
        if (extra.priceType == 'per_person') {
          extrasTotal += (extra.price ?? 0) * _guests * quantity;
        } else {
          extrasTotal += (extra.price ?? 0) * quantity;
        }
      }
    }
    tax = (basePriceTotal + extrasTotal) * (TAX_PERCENT / 100);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Booking' : 'Complete Your Booking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_isLoading)
                const Center(child: CircularProgressIndicator()),
              // Accommodation image
              Center(
                child: widget.accommodationImage.isNotEmpty &&
                        (widget.accommodationImage.startsWith('http://') ||
                            widget.accommodationImage.startsWith('https://'))
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.accommodationImage,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                      ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  widget.accommodationName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  widget.accommodationLocation,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
              // Room type
              const Text('Select Room Type *', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<RoomTypeEntity>(
                isExpanded: true,
                decoration: const InputDecoration(hintText: 'Choose a room type'),
                value: _selectedRoomType,
                items: widget.roomTypes
                    .where((rt) => rt.isActive == true && rt.pricePerNight > 0)
                    .map((rt) => DropdownMenuItem<RoomTypeEntity>(
                          value: rt,
                          child: Text('${rt.name} (Rs. ${rt.pricePerNight.toStringAsFixed(2)})'),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() { _selectedRoomType = val; });
                  _calculateTotalPrice();
                },
                validator: (val) => val == null ? 'Select a room type' : null,
              ),
              const SizedBox(height: 16),
              // Number of guests
              const Text('Number of Guests *', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _guests > 1
                      ? () => setState(() {
                          _guests--;
                          _calculateTotalPrice();
                        })
                      : null,
                  ),
                  Text('$_guests', style: const TextStyle(fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() {
                      _guests++;
                      _calculateTotalPrice();
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Number of Rooms
              const Text('Number of Rooms *', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _roomsBooked > 1
                      ? () => setState(() {
                          _roomsBooked--;
                          _calculateTotalPrice();
                        })
                      : null,
                  ),
                  Text('$_roomsBooked', style: const TextStyle(fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() {
                      _roomsBooked++;
                      _calculateTotalPrice();
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Optional extras
              if (widget.optionalExtras.isNotEmpty) ...[
                const Text('Optional Extras', style: TextStyle(fontWeight: FontWeight.bold)),
                ...widget.optionalExtras
                    .where((e) => e.isActive == true)
                    .map((e) {
                      final extra = e as OptionalExtraApiModel;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: (_extraQuantities[extra.id] ?? 0) > 0,
                                onChanged: (checked) {
                                  setState(() {
                                    _extraQuantities[extra.id] = checked! ? 1 : 0;
                                    _calculateTotalPrice();
                                  });
                                },
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${extra.name}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text('Rs. ${extra.price.toStringAsFixed(2)} per ${extra.priceType == 'per_person' ? 'person' : 'booking'}'),
                                    if (extra.description.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(extra.description, style: const TextStyle(color: Colors.grey)),
                                      ),
                                  ],
                                ),
                              ),
                              if ((_extraQuantities[extra.id] ?? 0) > 0)
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: (_extraQuantities[extra.id] ?? 1) > 1
                                          ? () => setState(() {
                                                _extraQuantities[extra.id] = (_extraQuantities[extra.id] ?? 1) - 1;
                                                _calculateTotalPrice();
                                              })
                                          : null,
                                    ),
                                    Text('${_extraQuantities[extra.id] ?? 1}', style: const TextStyle(fontSize: 16)),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () => setState(() {
                                        _extraQuantities[extra.id] = (_extraQuantities[extra.id] ?? 1) + 1;
                                        _calculateTotalPrice();
                                      }),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    })
                    .toList(),
              ]
              else if (widget.isEdit) ...[
                const Text('No optional extras available for this booking.', style: TextStyle(color: Colors.grey)),
              ]
              else ...[
                const Text('No optional extras available.', style: TextStyle(color: Colors.grey)),
              ],
              const SizedBox(height: 16),
              // Special requests
              const Text('Special Requests (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Any special requests or requirements...'),
                maxLines: 2,
                onChanged: (val) {
                  _specialRequest = val;
                  _calculateTotalPrice();
                },
              ),
              const SizedBox(height: 24),
              // Confirm booking
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF136767),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    widget.isEdit ? 'Update Booking' : 'Confirm Booking',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Booking summary
              const Text('Booking Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Base Price: Rs. ${basePriceTotal.toStringAsFixed(2)}'),
                      Text('Extras: Rs. ${extrasTotal.toStringAsFixed(2)}'),
                      Text('Tax (13%): Rs. ${tax.toStringAsFixed(2)}'),
                      const Divider(),
                      Text('Total Price: Rs. ${_totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}