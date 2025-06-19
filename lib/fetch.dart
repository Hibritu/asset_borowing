import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/api.dart';
import '../config.dart';
import '../models/material_model.dart';
import '../providers/auth_provider.dart';
import 'package:asset/edit_material_screen.dart';

class FetchDataScreen extends StatefulWidget {
  const FetchDataScreen({super.key});

  @override
  State<FetchDataScreen> createState() => _FetchDataScreenState();
}

class _FetchDataScreenState extends State<FetchDataScreen> {
  late Future<List<MaterialModel>> _materialsFuture;
  
  get imageUrl => null;

  @override
  void initState() {
    super.initState();
    _materialsFuture = Api.getMaterials();
  }

  void _refreshData() {
    setState(() {
      _materialsFuture = Api.getMaterials();
    });
  }

  void _deleteMaterial(String id, String token) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this material?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await Api.deleteMaterial(id, token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Material deleted successfully.'
              : 'Failed to delete material.'),
        ),
      );
      if (success) _refreshData();
    }
  }

  void _editMaterial(BuildContext context, MaterialModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditMaterialScreen(material: item),
      ),
    ).then((_) => _refreshData());
  }

  void _createRentalRequest(String materialId, String token) async {
    final durationController = TextEditingController();
    final quantityController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create Rental Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Duration (days)'),
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantityText = quantityController.text.trim();
              final duration = durationController.text.trim();
              final notes = notesController.text.trim();

              if (quantityText.isEmpty ||
                  int.tryParse(quantityText) == null ||
                  int.parse(quantityText) <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid quantity.')),
                );
                return;
              }

              if (duration.isEmpty ||
                  int.tryParse(duration) == null ||
                  int.parse(duration) <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid duration.')),
                );
                return;
              }

              final quantity = int.parse(quantityText);

              Navigator.pop(context);

              final success = await Api.createRentalRequest(
                materialId: materialId,
                quantity: quantity,
                rentalDuration: duration,
                notes: notes,
                token: token,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success
                      ? 'Rental request submitted.'
                      : 'Failed to submit rental request.'),
                ),
              );
            },
            child: const Text('Submit'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    return Scaffold(
      appBar: AppBar(title: const Text('Materials')),
      body: FutureBuilder<List<MaterialModel>>(
        future: _materialsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final materials = snapshot.data ?? [];

          if (materials.isEmpty) {
            return const Center(child: Text("No materials found."));
          }

          return ListView.builder(
            itemCount: materials.length,
            itemBuilder: (context, index) {
              final item = materials[index];

              // Fix image URL handling:
              String imageUrlToShow = '';
              if (item.imageUrl.isNotEmpty) {
                if (item.imageUrl.startsWith('http')) {
                  // Full URL returned from backend, use as-is
                  imageUrlToShow = item.imageUrl;
                } else {
                  // Relative filename, prepend base URL
                  imageUrlToShow = '${AppConfig.baseUrl}/uploads/${item.imageUrl}';
                }
              }

              print('Image URL to load: $imageUrlToShow');
              print('Raw imageUrl: ${item.imageUrl}');
               print('Loading image URL: $imageUrl');
              
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imageUrlToShow.isNotEmpty
                            ? Image.network(
                                imageUrlToShow,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.broken_image,
                                    size: 80,
                                    color: Colors.grey),
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const SizedBox(
                                    height: 80,
                                    width: 80,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                },
                              )
                            : const Icon(Icons.image_not_supported,
                                size: 80, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("📦 Type: ${item.type}"),
                            Text("📍 Location: ${item.location}"),
                            Text("📝 Description: ${item.description}"),
                            //Text(" qrDataString: ${item.qrDataString}"),

                            const SizedBox(height: 8),
                            Row(
  children: [
    const Text("🔑 QR: ",
        style: TextStyle(fontWeight: FontWeight.w500)),
    Expanded(
      child: SelectableText(
        item.qrDataString,
        style: const TextStyle(
            fontSize: 14, color: Colors.black87),
      ),
    ),
    IconButton(
      icon: const Icon(Icons.copy, size: 18),
      tooltip: 'Copy QR Data',
      onPressed: () {
        Clipboard.setData(ClipboardData(text: item.qrDataString));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("QR code copied!")),
        );
      },
    ),
  ],
),

                            Row(
                              children: [
                                const Text("🔢 Quantity: ",
                                    style: TextStyle(fontWeight: FontWeight.w500)),
                                Text(item.quantity.toString(),
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.teal)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit'),
                                  onPressed: () => _editMaterial(context, item),
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.delete, size: 18),
                                  label: const Text('Delete'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                  onPressed: () => _deleteMaterial(item.id, token!),
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.shopping_cart, size: 18),
                                  label: const Text('Rental Request'),
                                  onPressed: () =>
                                      _createRentalRequest(item.id, token!),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
