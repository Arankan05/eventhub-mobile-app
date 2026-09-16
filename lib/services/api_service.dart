import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/event.dart';
import '../models/booking.dart';

class ApiService {
  // CHANGE THIS TO YOUR COMPUTER'S IP ADDRESS FOR PHYSICAL DEVICE TESTING
  // Example: static const String baseUrl = 'http://192.168.1.10:3000/api';
  static const String baseUrl = 'http://127.0.0.1:3000/api'; // ADB reverse port forwarding

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Login failed');
      }
    } catch (e) {
      // For demo purposes, if API fails, we could mock it, but let's throw for now
      // and handle it in the UI with a fallback or error message.
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Registration failed');
    }
  }

  // User Profile
  Future<User> updateUser(String id, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to update profile');
    }
  }

  // Events
  Future<List<Event>> getEvents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/events'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Event.fromJson(e)).toList();
      } else {
        return _getSampleEvents();
      }
    } catch (e) {
      print('API Error: $e');
      return _getSampleEvents();
    }
  }

  Future<Event> createEvent(Map<String, dynamic> eventData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/events'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(eventData),
    );

    if (response.statusCode == 201) {
      return Event.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to create event');
    }
  }

  Future<void> updateEvent(String id, Map<String, dynamic> eventData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/events/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(eventData),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to update event');
    }
  }

  Future<void> deleteEvent(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/events/$id'));
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to delete event');
    }
  }

  // Bookings
  Future<Booking> createBooking(Map<String, dynamic> bookingData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bookingData),
    );

    if (response.statusCode == 201) {
      return Booking.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Booking failed');
    }
  }

  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/bookings/user/$userId'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Booking.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    final response = await http.put(Uri.parse('$baseUrl/bookings/$bookingId/cancel'));
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Cancellation failed');
    }
  }

  Future<List<Map<String, dynamic>>> getEventBookings(String eventId) async {
    final response = await http.get(Uri.parse('$baseUrl/events/$eventId/bookings'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  List<Event> _getSampleEvents() {
    return [
      Event(
        id: '1',
        organizerId: '101',
        name: 'Summer Music Festival',
        image: 'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=500&q=80',
        description: 'Join us for a day of live music from top artists across multiple genres.',
        date: '2026-07-15',
        time: '14:00',
        location: 'Central Park, NY',
        category: 'Music',
        price: 45.0,
        availableSeats: 500,
        createdAt: DateTime.now(),
      ),
      Event(
        id: '2',
        organizerId: '102',
        name: 'Tech Innovators Conference',
        image: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=500&q=80',
        description: 'Explore the latest trends in technology and network with industry leaders.',
        date: '2026-08-10',
        time: '09:00',
        location: 'Convention Center, SF',
        category: 'Technology',
        price: 150.0,
        availableSeats: 200,
        createdAt: DateTime.now(),
      ),
      Event(
        id: '3',
        organizerId: '101',
        name: 'Gourmet Food Fair',
        image: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=500&q=80',
        description: 'Sample delicious dishes from local chefs and international cuisines.',
        date: '2026-06-20',
        time: '11:00',
        location: 'Town Square, Chicago',
        category: 'Community',
        price: 15.0,
        availableSeats: 1000,
        createdAt: DateTime.now(),
      ),
      Event(
        id: '4',
        organizerId: '103',
        name: 'Championship Basketball',
        image: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=500&q=80',
        description: 'Watch the top teams compete for the regional championship title.',
        date: '2026-05-25',
        time: '19:00',
        location: 'Arena, Boston',
        category: 'Sports',
        price: 60.0,
        availableSeats: 300,
        createdAt: DateTime.now(),
      ),
      Event(
        id: '5',
        organizerId: '104',
        name: 'Digital Art Workshop',
        image: 'https://images.unsplash.com/photo-1547826039-bfc35e0f1ea8?w=500&q=80',
        description: 'Learn the fundamentals of digital painting and illustration from experts.',
        date: '2026-09-05',
        time: '10:00',
        location: 'Art Studio, Seattle',
        category: 'Workshop',
        price: 30.0,
        availableSeats: 50,
        createdAt: DateTime.now(),
      ),
      Event(
        id: '6',
        organizerId: '105',
        name: 'Global Business Summit',
        image: 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=500&q=80',
        description: 'Discuss global economic trends and business strategies for the future.',
        date: '2026-10-12',
        time: '08:30',
        location: 'Grand Ballroom, London',
        category: 'Business',
        price: 250.0,
        availableSeats: 150,
        createdAt: DateTime.now(),
      ),
      Event(
        id: '7',
        organizerId: '101',
        name: 'Photography Walk',
        image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=500&q=80',
        description: 'A guided tour of the city\'s most photogenic spots for amateur photographers.',
        date: '2026-11-01',
        time: '15:30',
        location: 'City Center, Paris',
        category: 'Education',
        price: 20.0,
        availableSeats: 40,
        createdAt: DateTime.now(),
      ),
      Event(
        id: '8',
        organizerId: '102',
        name: 'Stand-up Comedy Night',
        image: 'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=500&q=80',
        description: 'Laugh your heart out with the funniest comedians in the country.',
        date: '2026-12-15',
        time: '20:00',
        location: 'Comedy Club, LA',
        category: 'Entertainment',
        price: 25.0,
        availableSeats: 100,
        createdAt: DateTime.now(),
      ),
    ];
  }
}
