import 'package:flutter/material.dart';
import 'package:trip_wise_nepal/features/booking/presentation/pages/booking_detail_screen.dart';
import 'dart:convert';
import 'package:trip_wise_nepal/features/accommodation/domain/entities/room_type_entity.dart';
import 'package:trip_wise_nepal/features/accommodation/data/models/optional_extra_api_model.dart';
import 'package:dio/dio.dart';
import 'package:trip_wise_nepal/features/booking/presentation/pages/esewa_webview_page.dart';
import 'package:trip_wise_nepal/features/dashboard/presentation/pages/bottom_screen_layout.dart';

class BookingFormScreen extends StatefulWidget {
  final String accommodationId;
  final String accommodationName;
  final String accommodationImage;
  final String accommodationLocation;
  final List<RoomTypeEntity> roomTypes;
  final List<OptionalExtraApiModel> optionalExtras;
  final String token;
  final bool isEdit;
  final dynamic booking;

  const BookingFormScreen({
    super.key,
    required this.accommodationId,
    required this.accommodationName,
    required this.accommodationImage,
    required this.accommodationLocation,
    required this.roomTypes,
    required this.optionalExtras,
    required this.token,
    this.isEdit = false,
    this.booking,
  });

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  // ...existing state fields and methods...

  @override
  void initState() {
    super.initState();
    // Prefill form fields when editing an existing booking
    if (widget.isEdit && widget.booking != null) {
      final booking = widget.booking;

      // Prefill selected room type
      RoomTypeEntity? matchedRoomType;
      for (final rt in widget.roomTypes) {
        if (rt.id == booking.roomTypeId) {
          matchedRoomType = rt;
          break;
        }
      }
      _selectedRoomType = matchedRoomType;

      // Prefill dates and basic fields
      _checkInDate = booking.checkIn;
      _checkOutDate = booking.checkOut;
      _guests = booking.guests;
      _roomsBooked = booking.roomsBooked;
      _specialRequest = booking.specialRequest;

      // Prefill optional extras quantities
      try {
        final extras = booking.extras;
        for (final ex in extras) {
          _extraQuantities[ex.id] = ex.quantity;
        }
      } catch (_) {}

      // Recalculate total price after prefill
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateTotalPrice();
      });
    }
  }

  Future<void> _startEsewaPayment({required double amount, required String bookingId, required BuildContext context}) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        'http://10.0.2.2:5050/api/payment/esewa/initiate',
        data: {
          'amount': amount,
          'bookingId': bookingId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${widget.token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200 && response.data['esewaUrl'] != null && response.data['formData'] != null) {
        final esewaUrl = response.data['esewaUrl'] ?? '';
        dynamic formData = response.data['formData'] ?? {};

        // If formData is a String, try to decode as JSON
        if (formData is String) {
          try {
            formData = Map<String, dynamic>.from(jsonDecode(formData));
            print('[DEBUG] Decoded formData: $formData');
            print('[DEBUG] Decoded formData type: ${formData.runtimeType}');
          } catch (e) {
            print('[DEBUG] Failed to decode formData string: $e');
          }
        }

        print('[DEBUG] formData is Map: ${formData is Map}');
        print('[DEBUG] formData.isNotEmpty: ${(formData is Map) ? formData.isNotEmpty : 'N/A'}');

        if (esewaUrl.isNotEmpty && formData is Map && formData.isNotEmpty) {
          if (esewaUrl.contains('localhost') || esewaUrl.contains('127.0.0.1')) {
            await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Warning'),
                content: const Text('The callback URL for eSewa payment is set to localhost. Please use a public URL for real payments.'),
                actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
              ),
            );
          }
          // Convert all formData values to String
          final fields = formData.map((key, value) => MapEntry(key.toString(), value.toString()));
          try {
            final paymentResult = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EsewaWebViewPage(
                  formAction: esewaUrl,
                  fields: fields,
                ),
              ),
            );
            // If paymentResult is true (success), POST to backend and refresh booking
            if (paymentResult == true) {
              try {
                // Always use the latest booking's transaction_uuid
                final latestBooking = widget.booking;
                final transactionUuid = latestBooking?.transactionUuid ?? latestBooking?.transaction_uuid ?? fields['transaction_uuid'] ?? '';
                final productCode = fields['product_code'] ?? 'EPAYTEST';
                final totalAmount = fields['total_amount'] ?? amount.toString();
                if (transactionUuid.isNotEmpty) {
                  final dio = Dio();
                  final response = await dio.get(
                    'http://10.0.2.2:5050/api/payment/esewa/success',
                    queryParameters: {
                      'product_code': productCode,
                      'total_amount': totalAmount,
                      'transaction_uuid': transactionUuid,
                    },
                  );
                  print('[DEBUG] Payment confirmation GET response: statusCode=${response.statusCode}, data=${response.data}');
                } else {
                  print('[DEBUG] transactionUuid is empty, cannot confirm payment');
                }
              } catch (e) {
                print('[DEBUG] Error sending payment confirmation GET: $e');
                if (e is DioException) {
                  print('[DEBUG] DioError details: response=${e.response}, type=${e.type}, message=${e.message}');
                }
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment successful!')),
              );
              // After payment, navigate directly to BookingDetailScreen for this booking
              final bookingId = widget.isEdit
                  ? widget.booking?.id
                  : widget.booking?.id; // fallback to booking id
              if (bookingId != null) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => BookingDetailScreen(bookingId: bookingId)),
                  (route) => false,
                );
              } else {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => BottomScreenLayout(initialIndex: 2)),
                  (route) => false,
                );
              }
            } else if (paymentResult == false) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment failed or cancelled.')),
              );
            }
          } catch (err, stack) {
            print('[DEBUG] Exception while pushing EsewaWebViewPage: $err');
            print('[DEBUG] Stack trace: $stack');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error opening eSewa payment page: $err')),
            );
          }
        } else {
          print('[DEBUG] ENTERED ELSE BLOCK for eSewa payment initiation failure');
          print('[DEBUG] esewaUrl: $esewaUrl');
          print('[DEBUG] formData: $formData');
          print('[DEBUG] formData type: ${formData.runtimeType}');
          print('[DEBUG] esewaUrl.isNotEmpty: ${esewaUrl.isNotEmpty}');
          print('[DEBUG] formData is Map: ${formData is Map}');
          print('[DEBUG] formData.isNotEmpty: ${(formData is Map) ? formData.isNotEmpty : 'N/A'}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to initiate eSewa payment. Please try again.')),
          );
        }
      } else {
        final errorMsg = response.data['message'] ?? 'Failed to initiate eSewa payment.';
        print('[DEBUG] eSewa payment error: $errorMsg');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } catch (e) {
      print('[DEBUG] Exception in _startEsewaPayment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initiating eSewa payment: $e')),
      );
    }
  }

  // ...existing code...
  final _formKey = GlobalKey<FormState>();
  RoomTypeEntity? _selectedRoomType;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guests = 1;
  int _roomsBooked = 1;
  final Map<String, int> _extraQuantities = {};
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

  Future<String?> _submit({required String paymentType}) async {
    if (!_formKey.currentState!.validate() || _selectedRoomType == null || _checkInDate == null || _checkOutDate == null) {
      setState(() { _error = 'Please fill all required fields.'; });
      return null;
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

    // Generate transaction_uuid for new booking
    String transactionUuid;
    if (widget.isEdit && widget.booking != null && widget.booking.transactionUuid != null) {
      transactionUuid = widget.booking.transactionUuid;
    } else {
      transactionUuid = 'booking-${widget.accommodationId}-${DateTime.now().millisecondsSinceEpoch}';
    }
    // Always send paymentStatus: 'pending' for both eSewa and Pay Later
    final payload = {
      "accommodationId": widget.accommodationId,
      "roomTypeId": _selectedRoomType!.id,
      "checkIn": _checkInDate!.toIso8601String(),
      "checkOut": _checkOutDate!.toIso8601String(),
      "guests": _guests,
      "roomsBooked": _roomsBooked,
      "extras": extrasPayload,
      "specialRequest": _specialRequest ?? '',
      "paymentStatus": "pending",
      "transaction_uuid": transactionUuid
    };

    try {
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
      final isSuccess = (widget.isEdit ? response.statusCode == 200 : response.statusCode == 201) && response.data['success'] == true;
      if (isSuccess) {
        final bookingId = widget.isEdit
            ? widget.booking.id
            : response.data['data']?['booking']?['_id']?.toString();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.isEdit ? 'Booking updated!' : 'Booking submitted!')));
        // Always navigate to BottomScreenLayout with booking tab selected so bottom navigation is present
        if (paymentType == 'pending') {
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => BottomScreenLayout(initialIndex: 2),
              ),
              (route) => false,
            );
          });
        }
        return bookingId;
      } else {
        final errorMsg = response.data['message'] ?? (widget.isEdit ? 'Update failed.' : 'Booking failed.');
        setState(() { _error = errorMsg; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
        return null;
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMsg = e.response?.data['message']?.toString() ?? (widget.isEdit ? 'Update failed.' : 'Booking failed.');
        setState(() { _error = errorMsg; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      } else {
        final errorMsg = (widget.isEdit ? 'Update failed: ' : 'Booking failed: ') + e.toString();
        setState(() { _error = errorMsg; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
      return null;
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

    // Determine payment status for edit mode
    String paymentStatusRaw = '';
    if (widget.isEdit && widget.booking != null && widget.booking.paymentStatus != null) {
      paymentStatusRaw = widget.booking.paymentStatus.toString();
    }
    final bool isPaid = paymentStatusRaw == 'paid';

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
                initialValue: _selectedRoomType,
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
              // Check-in Date
              const Text('Check-in Date *', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final now = DateTime.now();
                        final firstDate = now;
                        final initialDate = _checkInDate != null && _checkInDate!.isAfter(firstDate)
                            ? _checkInDate!
                            : firstDate;
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: firstDate,
                          lastDate: now.add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            _checkInDate = picked;
                            if (_checkOutDate != null && _checkOutDate!.isBefore(picked)) {
                              _checkOutDate = null;
                            }
                          });
                          _calculateTotalPrice();
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          hintText: 'mm/dd/yyyy',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _checkInDate != null
                              ? '${_checkInDate!.month.toString().padLeft(2, '0')}/${_checkInDate!.day.toString().padLeft(2, '0')}/${_checkInDate!.year}'
                              : 'mm/dd/yyyy',
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final now = DateTime.now();
                      final firstDate = now;
                      final initialDate = _checkInDate != null && _checkInDate!.isAfter(firstDate)
                          ? _checkInDate!
                          : firstDate;
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: firstDate,
                        lastDate: now.add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          _checkInDate = picked;
                          if (_checkOutDate != null && _checkOutDate!.isBefore(picked)) {
                            _checkOutDate = null;
                          }
                        });
                        _calculateTotalPrice();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Check-out Date
              const Text('Check-out Date *', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final now = DateTime.now();
                        final firstDate = _checkInDate != null ? _checkInDate!.add(const Duration(days: 1)) : now.add(const Duration(days: 1));
                        final initialDate = _checkOutDate != null && _checkOutDate!.isAfter(firstDate)
                            ? _checkOutDate!
                            : firstDate;
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: firstDate,
                          lastDate: now.add(const Duration(days: 366)),
                        );
                        if (picked != null) {
                          setState(() {
                            _checkOutDate = picked;
                          });
                          _calculateTotalPrice();
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          hintText: 'mm/dd/yyyy',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _checkOutDate != null
                              ? '${_checkOutDate!.month.toString().padLeft(2, '0')}/${_checkOutDate!.day.toString().padLeft(2, '0')}/${_checkOutDate!.year}'
                              : 'mm/dd/yyyy',
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final now = DateTime.now();
                      final firstDate = _checkInDate != null ? _checkInDate!.add(const Duration(days: 1)) : now.add(const Duration(days: 1));
                      final initialDate = _checkOutDate != null && _checkOutDate!.isAfter(firstDate)
                          ? _checkOutDate!
                          : firstDate;
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: firstDate,
                        lastDate: now.add(const Duration(days: 366)),
                      );
                      if (picked != null) {
                        setState(() {
                          _checkOutDate = picked;
                        });
                        _calculateTotalPrice();
                      }
                    },
                  ),
                ],
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
                      final extra = e;
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
                                    Text(extra.name, style: const TextStyle(fontWeight: FontWeight.w600)),
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
                    ,
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
              // Payment options: eSewa button, warning, then Pay Later button
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.isEdit) ...[
                    if (isPaid) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withOpacity(0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lock, color: Colors.orange, size: 24),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'This booking has already been paid and can no longer be updated.',
                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                await _submit(paymentType: 'pending');
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF136767),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Center(
                          child: Text(
                            'Update Booking',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ] else ...[
                    ElevatedButton(
                      onPressed: _isLoading ? null : () async {
                        final bookingId = await _submit(paymentType: 'esewa');
                        if (bookingId != null) {
                          await _startEsewaPayment(amount: _totalPrice, bookingId: bookingId, context: context);
                        } else {
                          // Show dialog if booking fails or form is invalid
                          await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Booking Not Created'),
                              content: const Text('Booking could not be created. Please check all required fields and try again.'),
                              actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF136767),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Center(
                        child: Text(
                          'Confirm Booking and Pay with eSewa',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Your booking will expire 2 hours after creation. Please complete payment before expiry.',
                              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : () async {
                        // Confirm Booking & Pay Later
                        final bookingId = await _submit(paymentType: 'pending');
                        if (bookingId != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Booking reserved for 2 hours. Please complete payment before expiry.')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Center(
                        child: Text(
                          'Confirm Booking and Pay Later',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ],
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
                      if (widget.optionalExtras.any((e) => (_extraQuantities[e.id] ?? 0) > 0)) ...[
                        const SizedBox(height: 4),
                        const Text('Optional Extras:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...widget.optionalExtras.where((e) => (_extraQuantities[e.id] ?? 0) > 0).map((e) {
                          final quantity = _extraQuantities[e.id] ?? 0;
                          final price = e.priceType == 'per_person'
                              ? (e.price ?? 0) * _guests * quantity
                              : (e.price ?? 0) * quantity;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0, bottom: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text('${e.name} x$quantity', overflow: TextOverflow.ellipsis)),
                                Text('Rs. ${price.toStringAsFixed(2)}'),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 4),
                        Text('Extras Total: Rs. ${extrasTotal.toStringAsFixed(2)}'),
                      ] else ...[
                        Text('Extras: Rs. 0.00'),
                      ],
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