class Event {
  final String id;
  final String organizerId;
  final String name;
  final String image;
  final String description;
  final String date;
  final String time;
  final String location;
  final String category;
  final double price;
  final int availableSeats;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.organizerId,
    required this.name,
    required this.image,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.category,
    required this.price,
    required this.availableSeats,
    required this.createdAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'].toString(),
      organizerId: json['organizerId'].toString(),
      name: json['name'],
      image: json['image'],
      description: json['description'],
      date: json['date'],
      time: json['time'],
      location: json['location'],
      category: json['category'],
      price: double.parse(json['price'].toString()),
      availableSeats: int.parse(json['availableSeats'].toString()),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizerId': organizerId,
      'name': name,
      'image': image,
      'description': description,
      'date': date,
      'time': time,
      'location': location,
      'category': category,
      'price': price,
      'availableSeats': availableSeats,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
