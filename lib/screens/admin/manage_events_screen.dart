import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/event_provider.dart';
import '../../providers/pub_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/event_model.dart';
import '../../models/pub_model.dart';

class ManageEventsScreen extends StatefulWidget {
  const ManageEventsScreen({super.key});

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().fetchEvents();
      context.read<PubProvider>().fetchPubs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Manage Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => eventProvider.fetchEvents(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                // Implement local search if needed or filter provider
              },
            ),
          ),
          Expanded(
            child: eventProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : eventProvider.events.isEmpty
                    ? const Center(child: Text('No events found'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: eventProvider.events.length,
                        itemBuilder: (context, index) => _buildEventCard(eventProvider.events[index]),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEventDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    final dateFormat = DateFormat('MMM d, yyyy');
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 50,
            height: 50,
            color: Colors.grey[200],
            child: event.primaryImage.isNotEmpty
                ? Image.network(event.primaryImage, fit: BoxFit.cover)
                : const Icon(Icons.event),
          ),
        ),
        title: Text(event.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${event.eventType.toUpperCase()} • ${dateFormat.format(event.date)}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(Icons.people, 'Capacity', '${event.capacity}'),
                    _buildStat(Icons.payments, 'Tickets', event.ticketTypes.length.toString()),
                    _buildStat(Icons.place, 'Venue', event.pubName ?? 'External'),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _confirmDelete(event),
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showEventDialog(event: event),
                      icon: const Icon(Icons.edit, size: 20),
                      label: const Text('Edit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis),
      ],
    );
  }

  void _showEventDialog({EventModel? event}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EventFormDialog(event: event),
    );
  }

  void _confirmDelete(EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete ${event.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await context.read<EventProvider>().deleteEvent(event.id);
              if (!mounted) return;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _EventFormDialog extends StatefulWidget {
  final EventModel? event;

  const _EventFormDialog({this.event});

  @override
  State<_EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<_EventFormDialog> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;
  late TextEditingController imageUrlController;
  late TextEditingController capacityController;

  String? selectedPubId;
  String selectedType = 'Concert';
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  List<TicketType> ticketTypes = [];
  int currentStep = 0;
  bool isLoading = false;

  final List<String> eventTypes = ['Concert', 'Fest', 'Rave', 'Club Night', 'Other'];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.event?.name);
    descriptionController = TextEditingController(text: widget.event?.description);
    startTimeController = TextEditingController(text: widget.event?.startTime ?? '20:00');
    endTimeController = TextEditingController(text: widget.event?.endTime ?? '02:00');
    imageUrlController = TextEditingController(text: widget.event?.primaryImage);
    capacityController = TextEditingController(text: widget.event?.capacity.toString() ?? '500');

    selectedPubId = widget.event?.pubId;
    selectedType = widget.event?.eventType ?? 'Concert';
    selectedDate = widget.event?.date ?? DateTime.now().add(const Duration(days: 1));
    ticketTypes = List.from(widget.event?.ticketTypes ?? [
      TicketType(name: 'General', price: 20, quantity: 400),
      TicketType(name: 'VIP', price: 50, quantity: 100),
    ]);
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    imageUrlController.dispose();
    capacityController.dispose();
    super.dispose();
  }

  Future<void> _submitEvent() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }

    setState(() => isLoading = true);

    final eventData = {
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'pub': selectedPubId,
      'eventType': selectedType,
      'date': selectedDate.toIso8601String(),
      'startTime': startTimeController.text.trim(),
      'endTime': endTimeController.text.trim(),
      'capacity': int.tryParse(capacityController.text) ?? 500,
      'ticketTypes': ticketTypes.map((t) => {
        'name': t.name,
        'price': t.price,
        'quantity': t.quantity,
      }).toList(),
      'images': imageUrlController.text.isNotEmpty ? [{'url': imageUrlController.text.trim()}] : [],
    };

    final eventProvider = context.read<EventProvider>();

    bool success;
    if (widget.event == null) {
      success = await eventProvider.createEvent(eventData);
    } else {
      success = await eventProvider.updateEvent(widget.event!.id, eventData);
    }

    if (!mounted) return;
    setState(() => isLoading = false);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(eventProvider.error ?? 'Error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: isSmallScreen ? size.width : 800,
        height: isSmallScreen ? size.height : 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.event_note, size: 28, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Expanded(child: Text(widget.event == null ? 'Add New Event' : 'Edit Event', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: Stepper(
                type: isSmallScreen ? StepperType.vertical : StepperType.horizontal,
                currentStep: currentStep,
                onStepContinue: () {
                  if (currentStep < 3) setState(() => currentStep++);
                  else _submitEvent();
                },
                onStepCancel: () {
                  if (currentStep > 0) setState(() => currentStep--);
                },
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Row(
                      children: [
                        if (currentStep > 0)
                          OutlinedButton(onPressed: details.onStepCancel, child: const Text('Back')),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: isLoading ? null : details.onStepContinue,
                          child: Text(currentStep == 3 ? 'Finish' : 'Next'),
                        ),
                      ],
                    ),
                  );
                },
                steps: [
                  _buildStep('Basic Info', 0, _buildBasicInfo()),
                  _buildStep('Venue & Time', 1, _buildVenueAndTime()),
                  _buildStep('Tickets', 2, _buildTicketsInfo()),
                  _buildStep('Review', 3, _buildReview()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Step _buildStep(String title, int index, Widget content) {
    return Step(
      isActive: currentStep >= index,
      state: currentStep > index ? StepState.complete : StepState.indexed,
      title: Text(title, style: const TextStyle(fontSize: 10)),
      content: content,
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      children: [
        _buildTextField(nameController, 'Event Name', Icons.event),
        const SizedBox(height: 16),
        _buildTextField(descriptionController, 'Description', Icons.description, maxLines: 3),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: selectedType,
          decoration: const InputDecoration(labelText: 'Event Type', border: OutlineInputBorder()),
          items: eventTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (v) => setState(() => selectedType = v!),
        ),
      ],
    );
  }

  Widget _buildVenueAndTime() {
    final pubProvider = Provider.of<PubProvider>(context);
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: selectedPubId,
          decoration: const InputDecoration(labelText: 'Hosting Venue', border: OutlineInputBorder()),
          items: pubProvider.pubs.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
          onChanged: (v) => setState(() => selectedPubId = v),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: Text('Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
            if (picked != null) setState(() => selectedDate = picked);
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField(startTimeController, 'Start Time', Icons.access_time)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(endTimeController, 'End Time', Icons.access_time)),
          ],
        ),
      ],
    );
  }

  Widget _buildTicketsInfo() {
    return Column(
      children: [
        _buildTextField(capacityController, 'Total Capacity', Icons.people, keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildTextField(imageUrlController, 'Poster Image URL', Icons.image),
        const SizedBox(height: 16),
        const Text('Ticket Categories', style: TextStyle(fontWeight: FontWeight.bold)),
        ...ticketTypes.map((t) => ListTile(
          title: Text(t.name),
          subtitle: Text('\$${t.price} - Qty: ${t.quantity}'),
          trailing: IconButton(icon: const Icon(Icons.delete, size: 20), onPressed: () => setState(() => ticketTypes.remove(t))),
        )),
        TextButton.icon(onPressed: () => _addTicketType(), icon: const Icon(Icons.add), label: const Text('Add Ticket Type')),
      ],
    );
  }

  void _addTicketType() {
    // Simplified for brevity, usually shows another dialog or inline inputs
    setState(() => ticketTypes.add(TicketType(name: 'VIP', price: 100, quantity: 50)));
  }

  Widget _buildReview() {
    return Column(
      children: [
        ListTile(title: const Text('Event Name'), subtitle: Text(nameController.text)),
        ListTile(title: const Text('Venue'), subtitle: Text(selectedPubId ?? 'External')),
        ListTile(title: const Text('Date'), subtitle: Text(DateFormat('MMM d, yyyy').format(selectedDate))),
        ListTile(title: const Text('Type'), subtitle: Text(selectedType)),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
    );
  }
}