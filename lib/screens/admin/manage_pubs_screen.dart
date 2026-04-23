import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pub_provider.dart';
import '../../models/pub_model.dart';

class ManagePubsScreen extends StatefulWidget {
  const ManagePubsScreen({super.key});

  @override
  State<ManagePubsScreen> createState() => _ManagePubsScreenState();
}

class _PubFormDialog extends StatefulWidget {
  final Pub? pub;

  const _PubFormDialog({this.pub});

  @override
  State<_PubFormDialog> createState() => _PubFormDialogState();
}

class _PubFormDialogState extends State<_PubFormDialog> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController cityController;
  late TextEditingController streetController;
  late TextEditingController entryFeeController;
  late TextEditingController capacityController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController websiteController;
  late TextEditingController dressCodeController;
  late TextEditingController imageUrlController;

  List<String> amenities = ['WiFi', 'Parking'];
  List<String> musicGenres = ['Pop', 'Electronic'];
  bool isActive = true;
  bool featured = false;
  int currentStep = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.pub?.name);
    descriptionController = TextEditingController(text: widget.pub?.description);
    cityController = TextEditingController(text: widget.pub?.address.city);
    streetController = TextEditingController(text: widget.pub?.address.street);
    entryFeeController = TextEditingController(
      text: widget.pub?.pricing.entryFee.toString() ?? '20',
    );
    capacityController = TextEditingController(
      text: widget.pub?.capacity.total.toString() ?? '100',
    );
    phoneController = TextEditingController(text: widget.pub?.contactInfo.phone);
    emailController = TextEditingController(text: widget.pub?.contactInfo.email);
    websiteController = TextEditingController(text: widget.pub?.contactInfo.website);
    dressCodeController = TextEditingController(text: widget.pub?.dressCode ?? 'Smart Casual');
    imageUrlController = TextEditingController();

    amenities = List.from(widget.pub?.amenities ?? ['WiFi', 'Parking']);
    musicGenres = List.from(widget.pub?.musicGenre ?? ['Pop', 'Electronic']);
    isActive = widget.pub?.isActive ?? true;
    featured = widget.pub?.featured ?? false;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    cityController.dispose();
    streetController.dispose();
    entryFeeController.dispose();
    capacityController.dispose();
    phoneController.dispose();
    emailController.dispose();
    websiteController.dispose();
    dressCodeController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitPub() async {
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
        'email': emailController.text.trim(),
        'website': websiteController.text.trim(),
      },
      'pricing': {
        'entryFee': double.tryParse(entryFeeController.text) ?? 20.0,
        'averageDrinkPrice': 10.0,
      },
      'capacity': {
        'total': int.tryParse(capacityController.text) ?? 100,
        'current': widget.pub?.capacity.current ?? 0,
      },
      'amenities': amenities,
      'musicGenre': musicGenres,
      'dressCode': dressCodeController.text.trim(),
      'ageRestriction': 21,
      'isActive': isActive,
      'featured': featured,
      'ratings': {
        'average': widget.pub?.ratings.average ?? 0,
        'count': widget.pub?.ratings.count ?? 0,
      },
    };

    if (imageUrlController.text.isNotEmpty) {
      pubData['images'] = [
        {
          'url': imageUrlController.text.trim(),
          'caption': nameController.text.trim(),
          'isPrimary': true,
        }
      ];
    }

    try {
      final pubProvider = Provider.of<PubProvider>(
        context,
        listen: false,
      );

      bool success;
      if (widget.pub == null) {
        success = await pubProvider.createPub(pubData);
      } else {
        success = await pubProvider.updatePub(widget.pub!.id, pubData);
      }

      if (!mounted) return;

      setState(() => isLoading = false);

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.pub == null
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
              pubProvider.error ?? 'Operation failed. Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text(widget.pub == null ? 'Add New Pub' : 'Edit Pub'),
          const Spacer(),
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
      content: Container(
        width: 600,
        height: 500,
        padding: const EdgeInsets.all(8),
        child: Stepper(
          currentStep: currentStep,
          onStepContinue: () {
            if (currentStep < 3) {
              setState(() => currentStep++);
            } else {
              _submitPub();
            }
          },
          onStepCancel: () {
            if (currentStep > 0) {
              setState(() => currentStep--);
            }
          },
          controlsBuilder: (context, details) {
            return Row(
              children: [
                ElevatedButton(
                  onPressed: isLoading ? null : details.onStepContinue,
                  child: Text(currentStep == 3 ? 'Save Pub' : 'Next'),
                ),
                const SizedBox(width: 12),
                if (currentStep > 0)
                  TextButton(
                    onPressed: isLoading ? null : details.onStepCancel,
                    child: const Text('Back'),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
          steps: [
            Step(
              title: const Text('Basic Info'),
              content: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Pub Name *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dressCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Dress Code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Location & Contact'),
              content: Column(
                children: [
                  TextField(
                    controller: streetController,
                    decoration: const InputDecoration(
                      labelText: 'Street Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: 'City *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: websiteController,
                    decoration: const InputDecoration(
                      labelText: 'Website',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Pricing & Capacity'),
              content: Column(
                children: [
                  TextField(
                    controller: entryFeeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Entry Fee (\$)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: capacityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Total Capacity',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Main Image URL (optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.image),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Active'),
                          value: isActive,
                          onChanged: (value) {
                            setState(() => isActive = value!);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Featured'),
                          value: featured,
                          onChanged: (value) {
                            setState(() => featured = value!);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Review'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReviewItem('Name', nameController.text),
                  const Divider(),
                  _buildReviewItem('Description', descriptionController.text),
                  const Divider(),
                  _buildReviewItem('Address', '${streetController.text}, ${cityController.text}'),
                  const Divider(),
                  _buildReviewItem('Contact', phoneController.text),
                  const Divider(),
                  _buildReviewItem('Entry Fee', '\$${entryFeeController.text}'),
                  const Divider(),
                  _buildReviewItem('Capacity', '${capacityController.text} people'),
                  const Divider(),
                  _buildReviewItem('Status', isActive ? 'Active' : 'Inactive'),
                  const Divider(),
                  _buildReviewItem('Featured', featured ? 'Yes' : 'No'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not provided',
              style: TextStyle(
                color: value.isNotEmpty ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _PubFormDialog(pub: pub);
      },
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