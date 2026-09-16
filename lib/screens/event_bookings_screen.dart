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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: Text('Bookings: ${widget.event.name}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text('No bookings yet for this event', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[200]!)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF0D47A1),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(booking['userName'] ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(booking['userEmail'] ?? '', style: const TextStyle(fontSize: 13)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${booking['numberOfSeats']} Seats', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00B8D4))),
                            const SizedBox(height: 4),
                            Text(booking['bookingDate']?.toString().split('T')[0] ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
