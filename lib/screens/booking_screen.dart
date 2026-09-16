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
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.event.image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.event.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Text('${widget.event.date} at ${widget.event.time}', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Number of Seats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _numberOfSeats > 1 ? () => setState(() => _numberOfSeats--) : null,
                  icon: const Icon(Icons.remove_circle_outline, size: 32),
                  color: Theme.of(context).colorScheme.primary,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('$_numberOfSeats', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  onPressed: _numberOfSeats < widget.event.availableSeats
                      ? () => setState(() => _numberOfSeats++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline, size: 32),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 48),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Price per seat', style: TextStyle(fontSize: 16)),
                Text('\$${widget.event.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Price', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
            const SizedBox(height: 64),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isBooking ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isBooking
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('CONFIRM BOOKING', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
