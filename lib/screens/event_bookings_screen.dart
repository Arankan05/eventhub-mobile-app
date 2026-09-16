import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/api_service.dart';

class EventBookingsScreen extends StatefulWidget {
  final Event event;

  const EventBookingsScreen({super.key, required this.event});

  @override
  State<EventBookingsScreen> createState() => _EventBookingsScreenState();
}

class _EventBookingsScreenState extends State<EventBookingsScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      final data = await _apiService.getEventBookings(widget.event.id);
      setState(() {
        _bookings = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bookings: ${widget.event.name}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(child: Text('No bookings yet for this event.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(booking['userName'] ?? 'Anonymous'),
                        subtitle: Text(booking['userEmail'] ?? ''),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${booking['numberOfSeats']} Seats', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(booking['bookingDate']?.toString().split('T')[0] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
