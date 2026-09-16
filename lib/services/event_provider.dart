import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/booking.dart';
import 'api_service.dart';

class EventProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Event> _events = [];
  List<Booking> _userBookings = [];
  bool _isLoading = false;

  List<Event> get events => _events;
  List<Booking> get userBookings => _userBookings;
  bool get isLoading => _isLoading;

  Future<void> fetchEvents() async {
    _isLoading = true;
    notifyListeners();
    try {
      _events = await _apiService.getEvents();
    } catch (e) {
      // Gracefully handle or rethrow to UI
      print('Fetch Events Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserBookings(String userId) async {
    try {
      _userBookings = await _apiService.getUserBookings(userId);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> bookEvent(Map<String, dynamic> bookingData) async {
    await _apiService.createBooking(bookingData);
    await fetchEvents(); // Refresh available seats
    if (bookingData['userId'] != null) {
      await fetchUserBookings(bookingData['userId'].toString());
    }
  }

  Future<void> cancelBooking(String bookingId, String userId) async {
    await _apiService.cancelBooking(bookingId);
    await fetchEvents();
    await fetchUserBookings(userId);
  }

  Future<void> addEvent(Map<String, dynamic> eventData) async {
    await _apiService.createEvent(eventData);
    await fetchEvents();
  }

  Future<void> updateEvent(String id, Map<String, dynamic> eventData) async {
    await _apiService.updateEvent(id, eventData);
    await fetchEvents();
  }

  Future<void> deleteEvent(String id) async {
    await _apiService.deleteEvent(id);
    await fetchEvents();
  }
}
