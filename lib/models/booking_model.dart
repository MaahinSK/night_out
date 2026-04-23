class Booking {
  final String id;
  final String userId;
  final String pubId;
  final String? eventId;
  final String bookingType;
  final DateTime bookingDate;
  final int numberOfPeople;
  final String status;
  final String? tableNumber;
  final double totalAmount;
  final String confirmationCode;
  final String userName;
  final String pubName;
  final String? eventName;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.userId,
    required this.pubId,
    this.eventId,
    required this.bookingType,
    required this.bookingDate,
    required this.numberOfPeople,
    required this.status,
    this.tableNumber,
    required this.totalAmount,
    required this.confirmationCode,
    required this.userName,
    required this.pubName,
    this.eventName,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] ?? '',
      userId: json['user'] is Map ? json['user']['_id'] ?? '' : json['user'] ?? '',
      pubId: json['pub'] is Map ? json['pub']['_id'] ?? '' : json['pub'] ?? '',
      eventId: json['event'] is Map ? json['event']['_id'] : json['event'],
      bookingType: json['bookingType'] ?? 'entry',
      bookingDate: DateTime.parse(json['bookingDate'] ?? DateTime.now().toIso8601String()),
      numberOfPeople: json['numberOfPeople'] ?? 1,
      status: json['status'] ?? 'confirmed',
      tableNumber: json['tableDetails']?['tableNumber'],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      confirmationCode: json['confirmationCode'] ?? '',
      userName: json['user'] is Map ? json['user']['name'] ?? 'User' : 'User',
      pubName: json['pub'] is Map ? json['pub']['name'] ?? 'Pub' : 'Pub',
      eventName: json['event'] is Map ? json['event']['name'] : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'pub': pubId,
      'event': eventId,
      'bookingType': bookingType,
      'bookingDate': bookingDate.toIso8601String(),
      'numberOfPeople': numberOfPeople,
      'status': status,
      'totalAmount': totalAmount,
      'confirmationCode': confirmationCode,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final bookingDay = DateTime(bookingDate.year, bookingDate.month, bookingDate.day);

    if (bookingDay == today) {
      return 'Today';
    } else if (bookingDay == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${bookingDate.day}/${bookingDate.month}/${bookingDate.year}';
    }
  }
}