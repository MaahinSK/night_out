class EventModel {
  final String id;
  final String name;
  final String description;
  final String pubId;
  final String? pubName;
  final String eventType;
  final DateTime date;
  final DateTime? endDate;
  final String startTime;
  final String endTime;
  final List<EventImage> images;
  final List<TicketType> ticketTypes;
  final List<Performer> performers;
  final String? specialOffers;
  final int ageRestriction;
  final String dressCode;
  final int capacity;
  final bool isActive;
  final bool featured;

  EventModel({
    required this.id,
    required this.name,
    required this.description,
    required this.pubId,
    this.pubName,
    required this.eventType,
    required this.date,
    this.endDate,
    required this.startTime,
    required this.endTime,
    required this.images,
    required this.ticketTypes,
    required this.performers,
    this.specialOffers,
    required this.ageRestriction,
    required this.dressCode,
    required this.capacity,
    required this.isActive,
    required this.featured,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      pubId: json['pub'] is Map ? (json['pub']['_id'] ?? '') : (json['pub'] ?? ''),
      pubName: json['pub'] is Map ? json['pub']['name'] : null,
      eventType: json['eventType'] ?? 'dj-night',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      startTime: json['startTime'] ?? '21:00',
      endTime: json['endTime'] ?? '02:00',
      images: (json['images'] as List?)?.map((i) => EventImage.fromJson(i)).toList() ?? [],
      ticketTypes: (json['ticketTypes'] as List?)?.map((t) => TicketType.fromJson(t)).toList() ?? [],
      performers: (json['performers'] as List?)?.map((p) => Performer.fromJson(p)).toList() ?? [],
      specialOffers: json['specialOffers'],
      ageRestriction: json['ageRestriction'] ?? 18,
      dressCode: json['dressCode'] ?? 'Smart Casual',
      capacity: json['capacity'] ?? 100,
      isActive: json['isActive'] ?? true,
      featured: json['featured'] ?? false,
    );
  }

  String get primaryImage {
    if (images.isEmpty) return '';
    return images.first.url;
  }
}

class EventImage {
  final String url;
  final String? caption;

  EventImage({required this.url, this.caption});

  factory EventImage.fromJson(Map<String, dynamic> json) {
    return EventImage(
      url: json['url'] ?? '',
      caption: json['caption'],
    );
  }
}

class TicketType {
  final String name;
  final double price;
  final int quantity;
  final int sold;
  final String? description;

  TicketType({
    required this.name,
    required this.price,
    required this.quantity,
    this.sold = 0,
    this.description,
  });

  factory TicketType.fromJson(Map<String, dynamic> json) {
    return TicketType(
      name: json['name'] ?? 'General',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      sold: json['sold'] ?? 0,
      description: json['description'],
    );
  }
}

class Performer {
  final String name;
  final String? role;
  final String? image;
  final String? bio;

  Performer({required this.name, this.role, this.image, this.bio});

  factory Performer.fromJson(Map<String, dynamic> json) {
    return Performer(
      name: json['name'] ?? '',
      role: json['role'],
      image: json['image'],
      bio: json['bio'],
    );
  }
}
