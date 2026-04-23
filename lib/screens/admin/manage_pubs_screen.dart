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

  List<String> amenities = [];
  List<String> musicGenres = [];
  List<String> categories = [];
  bool isActive = true;
  bool featured = false;
  int currentStep = 0;
  bool isLoading = false;

  final List<String> availableCategories = [
    'Bar', 'Club', 'Pub', 'Lounge', 'Rooftop', 'Underground', 'Live Music', 'Cocktail Bar', 'Gastropub'
  ];
  
  final List<String> availableAmenities = [
    'WiFi', 'Parking', 'Smoking Area', 'Outdoor Seating', 'Live Sports', 'Dance Floor', 'VIP Area', 'Kitchen'
  ];

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
    imageUrlController = TextEditingController(text: widget.pub?.primaryImage);

    amenities = List.from(widget.pub?.amenities ?? ['WiFi', 'Parking']);
    musicGenres = List.from(widget.pub?.musicGenre ?? ['Pop', 'Electronic']);
    categories = List.from(widget.pub?.category ?? ['Bar']);
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
      _showError('Pub name is required');
      return;
    }
    if (cityController.text.isEmpty) {
      _showError('City is required');
      return;
    }
    if (categories.isEmpty) {
      _showError('At least one category is required');
      return;
    }

    setState(() => isLoading = true);

    final pubData = {
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'category': categories,
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
      final pubProvider = Provider.of<PubProvider>(context, listen: false);
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
          SnackBar(content: Text(widget.pub == null ? 'Pub created!' : 'Pub updated!'), backgroundColor: Colors.green),
        );
      } else {
        _showError(pubProvider.error ?? 'Operation failed');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
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
                Icon(widget.pub == null ? Icons.add_business : Icons.edit_road, size: 28, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.pub == null ? 'Add New Venue' : 'Edit Venue',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isLoading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: Stepper(
                type: isSmallScreen ? StepperType.vertical : StepperType.horizontal,
                currentStep: currentStep,
                elevation: 0,
                physics: const ClampingScrollPhysics(),
                onStepContinue: () {
                  if (currentStep < 4) setState(() => currentStep++);
                  else _submitPub();
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
                          OutlinedButton(
                            onPressed: details.onStepCancel,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Back'),
                          ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: isLoading ? null : details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(currentStep == 4 ? (widget.pub == null ? 'Create' : 'Save') : 'Next'),
                        ),
                      ],
                    ),
                  );
                },
                steps: [
                  _buildStep('General', 0, Icons.info_outline, _buildGeneralInfo()),
                  _buildStep('Category', 1, Icons.category_outlined, _buildCategorySelection()),
                  _buildStep('Location', 2, Icons.location_on_outlined, _buildLocationInfo()),
                  _buildStep('Details', 3, Icons.payments_outlined, _buildPricingInfo()),
                  _buildStep('Review', 4, Icons.rate_review_outlined, _buildReview()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Step _buildStep(String title, int index, IconData icon, Widget content) {
    return Step(
      isActive: currentStep >= index,
      state: currentStep > index ? StepState.complete : StepState.indexed,
      title: Text(title, style: const TextStyle(fontSize: 12)),
      content: content,
    );
  }

  Widget _buildGeneralInfo() {
    return Column(
      children: [
        _buildTextField(nameController, 'Venue Name', Icons.business, isRequired: true),
        const SizedBox(height: 16),
        _buildTextField(descriptionController, 'Description', Icons.description, maxLines: 3),
        const SizedBox(height: 16),
        _buildTextField(dressCodeController, 'Dress Code', Icons.checkroom),
        const SizedBox(height: 16),
        _buildTextField(imageUrlController, 'Cover Image URL', Icons.image),
      ],
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 0,
          children: availableCategories.map((cat) {
            final isSelected = categories.contains(cat);
            return FilterChip(
              label: Text(cat, style: const TextStyle(fontSize: 12)),
              selected: isSelected,
              onSelected: (val) {
                setState(() => val ? categories.add(cat) : categories.remove(cat));
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              padding: EdgeInsets.zero,
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        const Text('Amenities', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 0,
          children: availableAmenities.map((amn) {
            final isSelected = amenities.contains(amn);
            return FilterChip(
              label: Text(amn, style: const TextStyle(fontSize: 12)),
              selected: isSelected,
              onSelected: (val) {
                setState(() => val ? amenities.add(amn) : amenities.remove(amn));
              },
              padding: EdgeInsets.zero,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Column(
      children: [
        _buildTextField(streetController, 'Street Address', Icons.map),
        const SizedBox(height: 16),
        _buildTextField(cityController, 'City', Icons.location_city, isRequired: true),
        const SizedBox(height: 16),
        _buildTextField(phoneController, 'Phone', Icons.phone),
        const SizedBox(height: 16),
        _buildTextField(emailController, 'Email', Icons.email),
      ],
    );
  }

  Widget _buildPricingInfo() {
    return Column(
      children: [
        _buildTextField(entryFeeController, 'Entry Fee (\$)', Icons.attach_money, keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildTextField(capacityController, 'Capacity', Icons.people, keyboardType: TextInputType.number),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Active', style: TextStyle(fontSize: 14)),
          value: isActive,
          onChanged: (v) => setState(() => isActive = v),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Featured', style: TextStyle(fontSize: 14)),
          value: featured,
          onChanged: (v) => setState(() => featured = v),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewSection('General', [
          _buildReviewItem('Name', nameController.text),
          _buildReviewItem('Categories', categories.join(', ')),
        ]),
        const SizedBox(height: 12),
        _buildReviewSection('Pricing & Status', [
          _buildReviewItem('Entry Fee', '\$${entryFeeController.text}'),
          _buildReviewItem('Active', isActive ? 'Yes' : 'No'),
          _buildReviewItem('Featured', featured ? 'Yes' : 'No'),
        ]),
      ],
    );
  }

  Widget _buildReviewSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not set' : value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isRequired = false, int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Manage Venues'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => pubProvider.fetchPubs(),
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
                hintText: 'Search venues...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) pubProvider.searchPubs(value);
                else pubProvider.fetchPubs();
              },
            ),
          ),
          Expanded(
            child: pubProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : pubProvider.pubs.isEmpty
                    ? const Center(child: Text('No venues found'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: pubProvider.pubs.length,
                        itemBuilder: (context, index) => _buildVenueCard(pubProvider.pubs[index]),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPubDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Venue'),
      ),
    );
  }

  Widget _buildVenueCard(Pub pub) {
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
            child: pub.primaryImage.isNotEmpty
                ? Image.network(pub.primaryImage, fit: BoxFit.cover)
                : const Icon(Icons.business),
          ),
        ),
        title: Text(pub.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(pub.category.join(', '), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(Icons.people, 'Capacity', '${pub.capacity.total}'),
                    _statItem(Icons.payments, 'Entry', '\$${pub.pricing.entryFee.toInt()}'),
                    _statItem(Icons.star, 'Rating', '${pub.ratings.average}'),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _confirmDelete(pub),
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showPubDialog(pub: pub),
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
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
  
  Widget _statItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  void _showPubDialog({Pub? pub}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PubFormDialog(pub: pub),
    );
  }

  void _confirmDelete(Pub pub) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Venue'),
        content: Text('Are you sure you want to delete ${pub.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await context.read<PubProvider>().deletePub(pub.id);
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