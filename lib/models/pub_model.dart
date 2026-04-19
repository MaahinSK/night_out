class Pub {
  final String id;
  final String name;
  final String description;
  final Address address;
  final ContactInfo contactInfo;
  final List<PubImage> images;
  final List<Video> videos;
  final OpeningHours openingHours;
  final List<String> amenities;
  final List<String> musicGenre;
  final String? dressCode;
  final int ageRestriction;
  final Pricing pricing;
  final Capacity capacity;
  final List<PubTable> tables; // Changed from Table to PubTable
  final Ratings ratings;
  final bool isActive;
  final bool featured;
  final DateTime createdAt;

  Pub({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.contactInfo,
    required this.images,
    required this.videos,
    required this.openingHours,
    required this.amenities,
    required this.musicGenre,
    this.dressCode,
    required this.ageRestriction,
    required this.pricing,
    required this.capacity,
    required this.tables,
    required this.ratings,
    required this.isActive,
    required this.featured,
    required this.createdAt,
  });

  factory Pub.fromJson(Map<String, dynamic> json) {
    return Pub(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: Address.fromJson(json['address'] ?? {}),
      contactInfo: ContactInfo.fromJson(json['contactInfo'] ?? {}),
      images: (json['images'] as List?)?.map((i) => PubImage.fromJson(i)).toList() ?? [],
      videos: (json['videos'] as List?)?.map((v) => Video.fromJson(v)).toList() ?? [],
      openingHours: OpeningHours.fromJson(json['openingHours'] ?? {}),
      amenities: List<String>.from(json['amenities'] ?? []),
      musicGenre: List<String>.from(json['musicGenre'] ?? []),
      dressCode: json['dressCode'],
      ageRestriction: json['ageRestriction'] ?? 18,
      pricing: Pricing.fromJson(json['pricing'] ?? {}),
      capacity: Capacity.fromJson(json['capacity'] ?? {}),
      tables: (json['tables'] as List?)?.map((t) => PubTable.fromJson(t)).toList() ?? [],
      ratings: Ratings.fromJson(json['ratings'] ?? {}),
      isActive: json['isActive'] ?? true,
      featured: json['featured'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get primaryImage {
    if (images.isEmpty) return '';
    final primary = images.firstWhere((img) => img.isPrimary, orElse: () => images.first);
    return primary.url;
  }
}

class Address {
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  Address({
    this.street = '',
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.country = '',
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      country: json['country'] ?? '',
    );
  }

  String get fullAddress => '$street, $city, $state $zipCode';
}

class ContactInfo {
  final String phone;
  final String email;
  final String website;

  ContactInfo({
    this.phone = '',
    this.email = '',
    this.website = '',
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
    );
  }
}

class PubImage {
  final String url;
  final String caption;
  final bool isPrimary;

  PubImage({
    required this.url,
    this.caption = '',
    this.isPrimary = false,
  });

  factory PubImage.fromJson(Map<String, dynamic> json) {
    return PubImage(
      url: json['url'] ?? '',
      caption: json['caption'] ?? '',
      isPrimary: json['isPrimary'] ?? false,
    );
  }
}

class Video {
  final String url;
  final String thumbnail;
  final String title;

  Video({
    required this.url,
    this.thumbnail = '',
    this.title = '',
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      url: json['url'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      title: json['title'] ?? '',
    );
  }
}

class OpeningHours {
  final DayHours monday;
  final DayHours tuesday;
  final DayHours wednesday;
  final DayHours thursday;
  final DayHours friday;
  final DayHours saturday;
  final DayHours sunday;

  OpeningHours({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  factory OpeningHours.fromJson(Map<String, dynamic> json) {
    return OpeningHours(
      monday: DayHours.fromJson(json['monday'] ?? {}),
      tuesday: DayHours.fromJson(json['tuesday'] ?? {}),
      wednesday: DayHours.fromJson(json['wednesday'] ?? {}),
      thursday: DayHours.fromJson(json['thursday'] ?? {}),
      friday: DayHours.fromJson(json['friday'] ?? {}),
      saturday: DayHours.fromJson(json['saturday'] ?? {}),
      sunday: DayHours.fromJson(json['sunday'] ?? {}),
    );
  }
}

class DayHours {
  final String open;
  final String close;
  final bool isOpen;

  DayHours({
    this.open = '',
    this.close = '',
    this.isOpen = false,
  });

  factory DayHours.fromJson(Map<String, dynamic> json) {
    return DayHours(
      open: json['open'] ?? '',
      close: json['close'] ?? '',
      isOpen: json['isOpen'] ?? false,
    );
  }

  String get hours => isOpen ? '$open - $close' : 'Closed';
}

class Pricing {
  final double entryFee;
  final double averageDrinkPrice;

  Pricing({
    this.entryFee = 0.0,
    this.averageDrinkPrice = 0.0,
  });

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      entryFee: (json['entryFee'] ?? 0).toDouble(),
      averageDrinkPrice: (json['averageDrinkPrice'] ?? 0).toDouble(),
    );
  }
}

class Capacity {
  final int total;
  final int current;

  Capacity({
    this.total = 0,
    this.current = 0,
  });

  factory Capacity.fromJson(Map<String, dynamic> json) {
    return Capacity(
      total: json['total'] ?? 0,
      current: json['current'] ?? 0,
    );
  }

  int get available => total - current;
  double get occupancyRate => total > 0 ? (current / total) * 100 : 0;
}

class PubTable {
  final String id;
  final String tableNumber;
  final int capacity;
  final double minimumSpend;
  final String location;
  final bool isAvailable;

  PubTable({
    this.id = '',
    this.tableNumber = '',
    this.capacity = 0,
    this.minimumSpend = 0.0,
    this.location = '',
    this.isAvailable = true,
  });

  factory PubTable.fromJson(Map<String, dynamic> json) {
    return PubTable(
      id: json['_id'] ?? '',
      tableNumber: json['tableNumber'] ?? '',
      capacity: json['capacity'] ?? 0,
      minimumSpend: (json['minimumSpend'] ?? 0).toDouble(),
      location: json['location'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
    );
  }
}

class Ratings {
  final double average;
  final int count;

  Ratings({
    this.average = 0.0,
    this.count = 0,
  });

  factory Ratings.fromJson(Map<String, dynamic> json) {
    return Ratings(
      average: (json['average'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }
}