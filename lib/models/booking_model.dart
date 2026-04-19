class Booking {
  final String id;
  final String userId;
  final String pubId;
  final DateTime bookingDate;
  final String bookingType; // 'entry' or 'table'
  final int numberOfPeople;
  final String status; // 'confirmed', 'cancelled', 'completed'
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.userId,
    required this.pubId,
    required this.bookingDate,
    required this.bookingType,
    required this.numberOfPeople,
    required this.status,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      pubId: json['pubId'] ?? '',
      bookingDate: DateTime.parse(json['bookingDate']),
      bookingType: json['bookingType'] ?? 'entry',
      numberOfPeople: json['numberOfPeople'] ?? 1,
      status: json['status'] ?? 'confirmed',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'pubId': pubId,
      'bookingDate': bookingDate.toIso8601String(),
      'bookingType': bookingType,
      'numberOfPeople': numberOfPeople,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}