import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  TicketType? selectedTicket;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    if (widget.event.ticketTypes.isNotEmpty) {
      selectedTicket = widget.event.ticketTypes.first;
    }
  }

  void _bookEvent() async {
    if (selectedTicket == null) return;

    final bookingProvider = context.read<BookingProvider>();
    final authProvider = context.read<AuthProvider>();

    final bookingData = {
      'event': widget.event.id,
      if (widget.event.pubId.isNotEmpty) 'pub': widget.event.pubId,
      'bookingType': 'event',
      'bookingDate': widget.event.date.toIso8601String(),
      'numberOfPeople': quantity,
      'totalAmount': (selectedTicket!.price * quantity).toDouble(),
      'ticketDetails': {
        'name': selectedTicket!.name,
        'price': selectedTicket!.price,
        'quantity': quantity,
      }
    };

    final success = await bookingProvider.createBooking(bookingData);

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Booking Successful!'),
          content: const Text('Your spot at the event is reserved.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Great!'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(bookingProvider.error ?? 'Booking failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.event.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 10)])),
              background: widget.event.primaryImage.isNotEmpty
                  ? Image.network(widget.event.primaryImage, fit: BoxFit.cover)
                  : Container(color: Colors.deepPurple, child: const Icon(Icons.event, size: 100, color: Colors.white)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: Text(widget.event.eventType.toUpperCase(), style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow(Icons.calendar_today, 'Date', dateFormat.format(widget.event.date)),
                  _buildInfoRow(Icons.access_time, 'Time', '${widget.event.startTime} - ${widget.event.endTime}'),
                  _buildInfoRow(Icons.location_on, 'Location', widget.event.pubName ?? 'External Venue'),
                  const SizedBox(height: 24),
                  const Text('About this event', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.event.description, style: TextStyle(color: Colors.grey[600], height: 1.5)),
                  const SizedBox(height: 32),
                  const Text('Select Tickets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...widget.event.ticketTypes.map((t) => _buildTicketOption(t)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBookingBar(),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: Colors.grey[600])),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ]),
        ],
      ),
    );
  }

  Widget _buildTicketOption(TicketType ticket) {
    bool isSelected = selectedTicket == ticket;
    return GestureDetector(
      onTap: () => setState(() => selectedTicket = ticket),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? Colors.deepPurple : Colors.grey[300]!, width: 2),
        ),
        child: Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ticket.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(ticket.description ?? 'Standard access', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ])),
            Text('\$${ticket.price}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple)),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingBar() {
    if (selectedTicket == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: Row(
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text('Total Price', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text('\$${(selectedTicket!.price * quantity).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          ]),
          const Spacer(),
          ElevatedButton(
            onPressed: _bookEvent,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
