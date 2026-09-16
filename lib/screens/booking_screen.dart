import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../services/auth_provider.dart';
import '../services/event_provider.dart';
import '../services/notification_service.dart';
import 'booking_confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  final Event event;

  const BookingScreen({super.key, required this.event});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _numberOfSeats = 1;
  bool _isBooking = false;

  void _confirmBooking() async {
    setState(() => _isBooking = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final notificationService = Provider.of<NotificationService>(context, listen: false);

      final bookingData = {
        'userId': authProvider.user!.id,
        'eventId': widget.event.id,
        'numberOfSeats': _numberOfSeats,
        'totalPrice': widget.event.price * _numberOfSeats,
      };

      await eventProvider.bookEvent(bookingData);

      await notificationService.showNotification(
        id: 1,
        title: 'Booking Confirmed!',
        body: 'You have successfully booked $_numberOfSeats seats for ${widget.event.name}.',
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmationScreen(
            event: widget.event,
            numberOfSeats: _numberOfSeats,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.event.price * _numberOfSeats;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Event Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[200]!)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.event.image,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(color: Colors.grey[200], width: 90, height: 90),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.event.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(widget.event.date, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(widget.event.location, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text('Select Number of Seats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSeatButton(Icons.remove, _numberOfSeats > 1 ? () => setState(() => _numberOfSeats--) : null),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text('$_numberOfSeats', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  ),
                  _buildSeatButton(Icons.add, _numberOfSeats < widget.event.availableSeats ? () => setState(() => _numberOfSeats++) : null),
                ],
              ),
            ),
            const SizedBox(height: 48),
            const Text('Payment Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildSummaryRow('Price per seat', '\$${widget.event.price.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            _buildSummaryRow('Number of seats', '$_numberOfSeats'),
            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
            _buildSummaryRow('Total Price', '\$${totalPrice.toStringAsFixed(2)}', isTotal: true),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: _isBooking ? null : _confirmBooking,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isBooking
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('CONFIRM & BOOK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatButton(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey[100] : const Color(0xFF0D47A1).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: onTap == null ? Colors.grey : const Color(0xFF0D47A1), size: 28),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 18 : 15, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? Colors.black : Colors.grey[600])),
        Text(value, style: TextStyle(fontSize: isTotal ? 24 : 16, fontWeight: FontWeight.bold, color: isTotal ? const Color(0xFF00B8D4) : Colors.black)),
      ],
    );
  }
}
