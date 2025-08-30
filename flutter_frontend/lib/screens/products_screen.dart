import 'package:flutter/material.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // Mock data for demonstration
  final List<Map<String, dynamic>> products = [
    {
      'barcode': '123456789012',
      'name': 'Coca Cola Bottle',
      'category': 'Beverage',
      'manufacturer': 'Coca Cola Company',
      'status': 'owned',
      'manufactureDate': '2024-01-15',
    },
    {
      'barcode': '987654321098',
      'name': 'Plastic Water Bottle',
      'category': 'Beverage',
      'manufacturer': 'AquaPure',
      'status': 'disposed',
      'manufactureDate': '2024-02-20',
    },
    {
      'barcode': '456789123456',
      'name': 'Cereal Box',
      'category': 'Food',
      'manufacturer': 'Healthy Grains Co',
      'status': 'owned',
      'manufactureDate': '2024-03-10',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showAddProductDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Add Product',
          ),
        ],
      ),
      body: products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan products to add them to your collection',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddProductDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(product['status']),
                      child: Icon(
                        _getStatusIcon(product['status']),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      product['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Category: ${product['category']}'),
                        Text('Manufacturer: ${product['manufacturer']}'),
                        Text('Barcode: ${product['barcode']}'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(product['status']),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product['status'].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'details') {
                          _showProductDetails(product);
                        } else if (value == 'recycle') {
                          _recycleProduct(product);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'details',
                          child: Row(
                            children: [
                              Icon(Icons.info_outline),
                              SizedBox(width: 8),
                              Text('Details'),
                            ],
                          ),
                        ),
                        if (product['status'] == 'owned')
                          const PopupMenuItem(
                            value: 'recycle',
                            child: Row(
                              children: [
                                Icon(Icons.recycling),
                                SizedBox(width: 8),
                                Text('Recycle'),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'owned':
        return Colors.blue;
      case 'disposed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'owned':
        return Icons.shopping_bag;
      case 'disposed':
        return Icons.recycling;
      default:
        return Icons.help;
    }
  }

  void _showProductDetails(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Barcode', product['barcode']),
            _buildDetailRow('Category', product['category']),
            _buildDetailRow('Manufacturer', product['manufacturer']),
            _buildDetailRow('Manufacture Date', product['manufactureDate']),
            _buildDetailRow('Status', product['status'].toUpperCase()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _recycleProduct(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recycle Product'),
        content: Text(
          'Are you sure you want to recycle "${product['name']}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                product['status'] = 'disposed';
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product['name']} has been recycled! 🎉'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Recycle'),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final barcodeController = TextEditingController();
    final categoryController = TextEditingController();
    final manufacturerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: barcodeController,
                decoration: const InputDecoration(
                  labelText: 'Barcode',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: manufacturerController,
                decoration: const InputDecoration(
                  labelText: 'Manufacturer',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  barcodeController.text.isNotEmpty) {
                setState(() {
                  products.add({
                    'barcode': barcodeController.text,
                    'name': nameController.text,
                    'category': categoryController.text.isEmpty
                        ? 'General'
                        : categoryController.text,
                    'manufacturer': manufacturerController.text.isEmpty
                        ? 'Unknown'
                        : manufacturerController.text,
                    'status': 'owned',
                    'manufactureDate': DateTime.now().toString().split(' ')[0],
                  });
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product added successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
