import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pub_provider.dart';
import '../../models/pub_model.dart';

class ManagePubsScreen extends StatefulWidget {
  const ManagePubsScreen({super.key});

  @override
  State<ManagePubsScreen> createState() => _ManagePubsScreenState();
}

class _ManagePubsScreenState extends State<ManagePubsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PubProvider>().fetchPubs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pubProvider = Provider.of<PubProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Pubs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => pubProvider.fetchPubs(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search pubs...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    pubProvider.fetchPubs();
                  },
                )
                    : null,
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  pubProvider.searchPubs(value);
                } else {
                  pubProvider.fetchPubs();
                }
              },
            ),
          ),

          // Pub List
          Expanded(
            child: pubProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : pubProvider.pubs.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.nightlife_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pubs found',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pubProvider.pubs.length,
              itemBuilder: (context, index) {
                final pub = pubProvider.pubs[index];
                return _buildPubCard(pub);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPubDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Pub'),
      ),
    );
  }

  Widget _buildPubCard(Pub pub) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: pub.primaryImage.isNotEmpty
                ? DecorationImage(
              image: NetworkImage(pub.primaryImage),
              fit: BoxFit.cover,
            )
                : null,
            color: Colors.grey[300],
          ),
          child: pub.primaryImage.isEmpty
              ? const Icon(Icons.nightlife)
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pub.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    pub.address.city,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: pub.isActive ? Colors.green[50] : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                pub.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: pub.isActive ? Colors.green[700] : Colors.grey[700],
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Quick Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      Icons.people,
                      'Capacity',
                      '${pub.capacity.current}/${pub.capacity.total}',
                    ),
                    _buildStatItem(
                      Icons.star,
                      'Rating',
                      pub.ratings.average.toStringAsFixed(1),
                    ),
                    _buildStatItem(
                      Icons.table_restaurant,
                      'Tables',
                      pub.tables.length.toString(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showPubDialog(pub: pub),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _togglePubStatus(pub),
                      icon: Icon(
                        pub.isActive ? Icons.visibility_off : Icons.visibility,
                        size: 18,
                      ),
                      label: Text(pub.isActive ? 'Disable' : 'Enable'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _confirmDeletePub(pub),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
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

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  void _showPubDialog({Pub? pub}) {
    final nameController = TextEditingController(text: pub?.name);
    final descriptionController = TextEditingController(text: pub?.description);
    final cityController = TextEditingController(text: pub?.address.city);
    final streetController = TextEditingController(text: pub?.address.street);
    final entryFeeController = TextEditingController(
      text: pub?.pricing.entryFee.toString() ?? '20',
    );
    final capacityController = TextEditingController(
      text: pub?.capacity.total.toString() ?? '100',
    );
    final phoneController = TextEditingController(text: pub?.contactInfo.phone);

    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(pub == null ? 'Add New Pub' : 'Edit Pub'),
          content: SingleChildScrollView(
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Pub Name *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: streetController,
                    decoration: const InputDecoration(
                      labelText: 'Street Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: 'City *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: entryFeeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Entry Fee (\$)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: capacityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Capacity',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isLoading) ...[
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                // Validate
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pub name is required'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (cityController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('City is required'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                setState(() => isLoading = true);

                final pubData = {
                  'name': nameController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'address': {
                    'street': streetController.text.trim(),
                    'city': cityController.text.trim(),
                    'state': '',
                    'zipCode': '',
                    'country': 'USA',
                  },
                  'contactInfo': {
                    'phone': phoneController.text.trim(),
                    'email': '',
                    'website': '',
                  },
                  'pricing': {
                    'entryFee': double.tryParse(entryFeeController.text) ?? 20.0,
                    'averageDrinkPrice': 10.0,
                  },
                  'capacity': {
                    'total': int.tryParse(capacityController.text) ?? 100,
                    'current': 0,
                  },
                  'amenities': ['WiFi', 'Parking', 'VIP Area'],
                  'musicGenre': ['Pop', 'Electronic', 'Hip Hop'],
                  'dressCode': 'Smart Casual',
                  'ageRestriction': 21,
                  'isActive': true,
                  'featured': false,
                };

                print('Creating pub with data: $pubData');

                final pubProvider = Provider.of<PubProvider>(
                  context,
                  listen: false,
                );

                bool success;
                if (pub == null) {
                  success = await pubProvider.createPub(pubData);
                } else {
                  success = await pubProvider.updatePub(pub.id, pubData);
                }

                if (!context.mounted) return;

                setState(() => isLoading = false);

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        pub == null
                            ? 'Pub created successfully!'
                            : 'Pub updated successfully!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        pubProvider.error ?? 'Operation failed. Check console for details.',
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              },
              child: Text(pub == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _togglePubStatus(Pub pub) async {
    final pubProvider = Provider.of<PubProvider>(context, listen: false);
    final success = await pubProvider.updatePub(pub.id, {
      'isActive': !pub.isActive,
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            pub.isActive ? 'Pub disabled' : 'Pub enabled',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _confirmDeletePub(Pub pub) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pub'),
        content: Text('Are you sure you want to delete "${pub.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final pubProvider = Provider.of<PubProvider>(
                context,
                listen: false,
              );
              final success = await pubProvider.deletePub(pub.id);

              if (!mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${pub.name} deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(pubProvider.error ?? 'Failed to delete pub'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Pubs'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Active Only'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Featured Only'),
              value: false,
              onChanged: (value) {},
            ),
            const Divider(),
            ListTile(
              title: const Text('Sort by'),
              trailing: DropdownButton<String>(
                value: 'name',
                items: const [
                  DropdownMenuItem(value: 'name', child: Text('Name')),
                  DropdownMenuItem(value: 'rating', child: Text('Rating')),
                  DropdownMenuItem(value: 'date', child: Text('Date Added')),
                ],
                onChanged: (value) {},
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
            onPressed: () {
              Navigator.pop(context);
              // Apply filters
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}