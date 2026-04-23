import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pub_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/pub_model.dart';
import '../../providers/booking_provider.dart';
import '../../services/api_service.dart'; // Add this import
import '../../config/app_config.dart';

class PubDetailScreen extends StatefulWidget {
  final String pubId;

  const PubDetailScreen({super.key, required this.pubId});

  @override
  State<PubDetailScreen> createState() => _PubDetailScreenState();
}

class _PubDetailScreenState extends State<PubDetailScreen> {
  bool _isFavorite = false;
  int _selectedTab = 0;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PubProvider>().fetchPubById(widget.pubId);
      _checkIfFavorite();
    });
  }

  void _showRatingDialog(Pub pub) {
    double rating = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Rate this Venue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How was your experience at ${pub.name}?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        rating = index + 1.0;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 10),
              Text(
                rating > 0 ? '${rating.toInt()} Star${rating > 1 ? 's' : ''}' : 'Tap to rate',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: rating == 0
                  ? null
                  : () async {
                Navigator.pop(context);

                // Submit rating
                try {
                  final response = await _apiService.post(
                    '/pubs/${pub.id}/rate',
                    {'rating': rating},
                  );

                  if (response['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you for your rating!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Refresh pub details
                    if (mounted) {
                      context.read<PubProvider>().fetchPubById(pub.id);
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }


  void _checkIfFavorite() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      _isFavorite = userProvider.favoriteIds.contains(widget.pubId);
    });
  }

  Future<void> _toggleFavorite() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (_isFavorite) {
      await userProvider.removeFromFavorites(widget.pubId);
    } else {
      await userProvider.addToFavorites(widget.pubId);
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pubProvider = Provider.of<PubProvider>(context);
    final pub = pubProvider.selectedPub;

    if (pubProvider.isLoading || pub == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  pub.primaryImage.isNotEmpty
                      ? Image.network(
                    pub.primaryImage,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.nightlife, size: 80),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),


            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {},
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pub.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pub.address.fullAddress,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber[600], size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  pub.ratings.average.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${pub.ratings.count} reviews',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Quick Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          Icons.people_outline,
                          'Capacity',
                          '${pub.capacity.available}/${pub.capacity.total}',
                          pub.capacity.occupancyRate > 80
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          Icons.attach_money,
                          'Entry Fee',
                          '\$${pub.pricing.entryFee.toStringAsFixed(0)}',
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          Icons.local_bar,
                          'Avg Drink',
                          '\$${pub.pricing.averageDrinkPrice.toStringAsFixed(0)}',
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildTab('About', 0),
                        _buildTab('Gallery', 1),
                        _buildTab('Tables', 2),
                        _buildTab('Events', 3),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tab Content
                  if (_selectedTab == 0) _buildAboutTab(pub),
                  if (_selectedTab == 1) _buildGalleryTab(pub),
                  if (_selectedTab == 2) _buildTablesTab(pub),
                  if (_selectedTab == 3) _buildEventsTab(),
                ],
              ),
            ),
          ),
        ],
      ),

      // Booking Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ready to party?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Book your spot now',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _showBookingDialog(pub);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutTab(Pub pub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          pub.description,
          style: TextStyle(color: Colors.grey[700], height: 1.5),
        ),
        const SizedBox(height: 24),

        Text(
          'Opening Hours',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _buildOpeningHours(pub.openingHours),
        const SizedBox(height: 24),

        Text(
          'Amenities',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: pub.amenities.map((amenity) {
            return Chip(
              label: Text(amenity),
              avatar: const Icon(Icons.check_circle, size: 18),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        Text(
          'Music Genre',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: pub.musicGenre.map((genre) {
            return Chip(
              label: Text(genre),
              avatar: const Icon(Icons.music_note, size: 18),
              backgroundColor: Colors.purple[50],
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        if (pub.dressCode != null) ...[
          Text(
            'Dress Code',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.checkroom, color: Colors.orange[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    pub.dressCode!,
                    style: TextStyle(color: Colors.orange[900]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOpeningHours(OpeningHours hours) {
    final days = [
      {'name': 'Monday', 'hours': hours.monday},
      {'name': 'Tuesday', 'hours': hours.tuesday},
      {'name': 'Wednesday', 'hours': hours.wednesday},
      {'name': 'Thursday', 'hours': hours.thursday},
      {'name': 'Friday', 'hours': hours.friday},
      {'name': 'Saturday', 'hours': hours.saturday},
      {'name': 'Sunday', 'hours': hours.sunday},
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: days.map((day) {
          final dayHours = day['hours'] as DayHours;
          final isToday = DateTime.now().weekday == days.indexOf(day) + 1;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isToday ? Colors.blue[50] : null,
              border: day != days.last
                  ? Border(bottom: BorderSide(color: Colors.grey[300]!))
                  : null,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    day['name'] as String,
                    style: TextStyle(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                Text(
                  dayHours.hours,
                  style: TextStyle(
                    color: dayHours.isOpen ? Colors.green[700] : Colors.red[700],
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGalleryTab(Pub pub) {
    if (pub.images.isEmpty && pub.videos.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 48),
            Icon(Icons.image_not_supported, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No images available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pub.images.isNotEmpty) ...[
          Text(
            'Photos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: pub.images.length,
            itemBuilder: (context, index) {
              final image = pub.images[index];
              return GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(image.url),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ],

        if (pub.videos.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Videos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...pub.videos.map((video) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: video.thumbnail.isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(video.thumbnail),
                      fit: BoxFit.cover,
                    )
                        : null,
                    color: Colors.grey[300],
                  ),
                  child: video.thumbnail.isEmpty
                      ? const Icon(Icons.play_circle_outline)
                      : null,
                ),
                title: Text(video.title),
                trailing: const Icon(Icons.play_arrow),
                onTap: () {},
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildTablesTab(Pub pub) {
    if (pub.tables.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 48),
            Icon(Icons.table_restaurant, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tables available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: pub.tables.map((table) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Table ${table.tableNumber}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            table.location,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: table.isAvailable
                            ? Colors.green[50]
                            : Colors.red[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        table.isAvailable ? 'Available' : 'Booked',
                        style: TextStyle(
                          color: table.isAvailable
                              ? Colors.green[700]
                              : Colors.red[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${table.capacity} people',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Min spend: \$${table.minimumSpend.toStringAsFixed(0)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (table.isAvailable) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showTableBookingDialog(pub, table);
                      },
                      child: const Text('Book This Table'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEventsTab() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 48),
          Icon(Icons.event, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No upcoming events',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later!',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(Pub pub) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return BookingBottomSheet(pub: pub);
          },
        );
      },
    );
  }

  void _showTableBookingDialog(Pub pub, PubTable table) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return TableBookingBottomSheet(pub: pub, table: table);
          },
        );
      },
    );
  }
}

// Booking Bottom Sheet Widget
class BookingBottomSheet extends StatefulWidget {
  final Pub pub;

  const BookingBottomSheet({super.key, required this.pub});

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int _numberOfPeople = 2;
  String _bookingType = 'entry';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Book at ${widget.pub.name}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'Booking Type',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SegmentedButton(
            segments: const [
              ButtonSegment(
                value: 'entry',
                label: Text('Entry Only'),
                icon: Icon(Icons.meeting_room),
              ),
              ButtonSegment(
                value: 'table',
                label: Text('Table'),
                icon: Icon(Icons.table_restaurant),
              ),
            ],
            selected: {_bookingType},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _bookingType = newSelection.first;
              });
            },
          ),
          const SizedBox(height: 24),

          Text(
            'Select Date',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Number of People',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: _numberOfPeople > 1
                    ? () => setState(() => _numberOfPeople--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_numberOfPeople',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              IconButton(
                onPressed: _numberOfPeople < 20
                    ? () => setState(() => _numberOfPeople++)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Entry Fee'),
                    Text('\$${widget.pub.pricing.entryFee} x $_numberOfPeople'),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${(widget.pub.pricing.entryFee * _numberOfPeople).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final bookingData = {
                  'pubId': widget.pub.id,
                  'bookingType': _bookingType,
                  'bookingDate': _selectedDate.toIso8601String(),
                  'numberOfPeople': _numberOfPeople,
                  'totalAmount': widget.pub.pricing.entryFee * _numberOfPeople,
                };
                
                final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
                final success = await bookingProvider.createBooking(bookingData);
                
                if (!mounted) return;
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking confirmed!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(bookingProvider.error ?? 'Failed to create booking'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Confirm Booking',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TableBookingBottomSheet extends StatefulWidget {
  final Pub pub;
  final PubTable table;

  const TableBookingBottomSheet({
    super.key,
    required this.pub,
    required this.table,
  });

  @override
  State<TableBookingBottomSheet> createState() => _TableBookingBottomSheetState();
}

class _TableBookingBottomSheetState extends State<TableBookingBottomSheet> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 21, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Book Table ${widget.table.tableNumber}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.pub.name,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          Text(
            'Select Date',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Select Time',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 12),
                Text(
                  _selectedTime.format(context),
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (time != null) {
                      setState(() => _selectedTime = time);
                    }
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Table Capacity'),
                    Text('${widget.table.capacity} people'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Minimum Spend'),
                    Text('\$${widget.table.minimumSpend.toStringAsFixed(0)}'),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Deposit Required',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${(widget.table.minimumSpend * 0.3).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final bookingDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  _selectedTime.hour,
                  _selectedTime.minute,
                );
                
                final bookingData = {
                  'pubId': widget.pub.id,
                  'bookingType': 'table',
                  'tableDetails': {
                    'tableNumber': widget.table.tableNumber,
                  },
                  'bookingDate': bookingDate.toIso8601String(),
                  'numberOfPeople': widget.table.capacity,
                  'totalAmount': widget.table.minimumSpend,
                };
                
                final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
                final success = await bookingProvider.createBooking(bookingData);
                
                if (!mounted) return;
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Table booked successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(bookingProvider.error ?? 'Failed to book table'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Confirm Table Booking',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}