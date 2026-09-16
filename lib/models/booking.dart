class Booking {
  final String id;
  final String userId;
  final String eventId;
  final int numberOfSeats;
  final double totalPrice;
  final String bookingDate;
  final String status;
  final String? eventName; // For convenience in UI
  final String? eventImage; // For convenience in UI
  final String? eventDate; // For convenience in UI

  Booking({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.numberOfSeats,
    required this.totalPrice,
    required this.bookingDate,
    required this.status,
    this.eventName,
    this.eventImage,
    this.eventDate,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'].toString(),
      userId: json['userId'].toString(),
      eventId: json['eventId'].toString(),
      numberOfSeats: int.parse(json['numberOfSeats'].toString()),
      totalPrice: double.parse(json['totalPrice'].toString()),
      bookingDate: json['bookingDate'],
      status: json['status'],
      eventName: json['eventName'],
      eventImage: json['eventImage'],
      eventDate: json['eventDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'eventId': eventId,
      'numberOfSeats': numberOfSeats,
      'totalPrice': totalPrice,
      'bookingDate': bookingDate,
      'status': status,
    };
  }
}
