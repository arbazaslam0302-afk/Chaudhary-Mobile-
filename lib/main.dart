import 'package:flutter/material.dart';

void main() {
  runApp(const ChaudharyMobileApp());
}

class ChaudharyMobileApp extends StatelessWidget {
  const ChaudharyMobileApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chaudhary Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
      ),
      home: const GoogleLoginScreen(),
    );
  }
}

// ------------------- GOOGLE LOGIN SCREEN -------------------
class GoogleLoginScreen extends StatefulWidget {
  const GoogleLoginScreen({Key? key}) : super(key: key);

  @override
  State<GoogleLoginScreen> createState() => _GoogleLoginScreenState();
}

class _GoogleLoginScreenState extends State<GoogleLoginScreen> {
  bool _isLoading = false;

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    
    // Simulating Google Authentication Delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(
            userEmail: 'chaudhary.mobile@gmail.com',
            userName: 'Chaudhary Owner',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phone_android, size: 64, color: Colors.indigo),
                  const SizedBox(height: 12),
                  const Text(
                    'Chaudhary Mobile',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  const Text('Digikhata & Inventory System', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 30),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.account_circle, color: Colors.red, size: 28),
                          label: const Text(
                            'Sign in with Google',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          onPressed: _handleGoogleSignIn,
                        ),
                  const SizedBox(height: 15),
                  const Text(
                    'Your stock data will be saved securely.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------- MODELS -------------------
class TransactionItem {
  String id;
  bool isStockIn;
  int quantity;
  double price;
  String description;
  DateTime date;

  TransactionItem({
    required this.id,
    required this.isStockIn,
    required this.quantity,
    required this.price,
    required this.description,
    required this.date,
  });
}

class StockModel {
  String id;
  String modelName;
  int quantity;
  double costPrice;
  double sellingPrice;
  List<TransactionItem> history;

  StockModel({
    required this.id,
    required this.modelName,
    required this.quantity,
    required this.costPrice,
    required this.sellingPrice,
    required this.history,
  });
}

// ------------------- DASHBOARD -------------------
class DashboardScreen extends StatefulWidget {
  final String userEmail;
  final String userName;

  const DashboardScreen({
    Key? key,
    required this.userEmail,
    required this.userName,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<StockModel> stocks = [
    StockModel(
      id: '1',
      modelName: 'Samsung A12 Panel',
      quantity: 5,
      costPrice: 2000,
      sellingPrice: 2500,
      history: [
        TransactionItem(
          id: 't1',
          isStockIn: true,
          quantity: 5,
          price: 2000,
          description: 'Initial Purchase',
          date: DateTime.now().subtract(const Duration(hours: 4)),
        )
      ],
    ),
    StockModel(
      id: '2',
      modelName: 'Y20 Panel',
      quantity: 1,
      costPrice: 1620,
      sellingPrice: 1750,
      history: [],
    )
  ];

  String searchQuery = '';

  double get totalStockValue =>
      stocks.fold(0, (sum, item) => sum + (item.quantity * item.costPrice));

  int get lowStockCount =>
      stocks.where((item) => item.quantity <= 2).length;

  String _formatDateTime(DateTime dt) {
    return "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }

  void _addNewStockDialog() {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    final costController = TextEditingController();
    final sellController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Stock Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Item Name / Model'),
              ),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              TextField(
                controller: costController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Purchase Price (Cost)'),
              ),
              TextField(
                controller: sellController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sale Price'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && qtyController.text.isNotEmpty) {
                int qty = int.parse(qtyController.text);
                double cost = double.tryParse(costController.text) ?? 0;
                DateTime now = DateTime.now();

                setState(() {
                  stocks.add(
                    StockModel(
                      id: now.toString(),
                      modelName: nameController.text,
                      quantity: qty,
                      costPrice: cost,
                      sellingPrice: double.tryParse(sellController.text) ?? 0,
                      history: [
                        TransactionItem(
                          id: now.toString(),
                          isStockIn: true,
                          quantity: qty,
                          price: cost,
                          description: 'Stock Added',
                          date: now,
                        )
                      ],
                    ),
                  );
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save Item'),
          ),
        ],
      ),
    );
  }

  void _stockInOutDialog(StockModel item, bool isStockIn) {
    final qtyController = TextEditingController();
    final priceController = TextEditingController(
        text: (isStockIn ? item.costPrice : item.sellingPrice).toString());
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isStockIn ? 'Stock IN (+)' : 'Stock OUT (-)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.modelName, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: isStockIn ? 'Purchase Price' : 'Sale Price'),
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note / Customer Name'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isStockIn ? Colors.green : Colors.red,
            ),
            onPressed: () {
              int qty = int.tryParse(qtyController.text) ?? 0;
              if (qty > 0) {
                if (!isStockIn && qty > item.quantity) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Not enough stock available!')),
                  );
                  return;
                }
                DateTime now = DateTime.now();
                setState(() {
                  if (isStockIn) {
                    item.quantity += qty;
                  } else {
                    item.quantity -= qty;
                  }
                  item.history.add(
                    TransactionItem(
                      id: now.toString(),
                      isStockIn: isStockIn,
                      quantity: qty,
                      price: double.tryParse(priceController.text) ?? 0,
                      description: noteController.text.isEmpty
                          ? (isStockIn ? 'Stock In' : 'Sale / Out')
                          : noteController.text,
                      date: now,
                    ),
                  );
                });
                Navigator.pop(ctx);
              }
            },
            child: Text(isStockIn ? 'Add Stock' : 'Out Stock'),
          )
        ],
      ),
    );
  }

  // EDIT HISTORY ENTRY DIALOG
  void _editHistoryDialog(StockModel item, TransactionItem tx) {
    final qtyController = TextEditingController(text: tx.quantity.toString());
    final priceController = TextEditingController(text: tx.price.toString());
    final noteController = TextEditingController(text: tx.description);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit History Record'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note / Description'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              int oldQty = tx.quantity;
              int newQty = int.tryParse(qtyController.text) ?? oldQty;
              int qtyDifference = newQty - oldQty;

              setState(() {
                tx.quantity = newQty;
                tx.price = double.tryParse(priceController.text) ?? tx.price;
                tx.description = noteController.text;

                // Adjust Main Stock Quantity
                if (tx.isStockIn) {
                  item.quantity += qtyDifference;
                } else {
                  item.quantity -= qtyDifference;
                }
              });

              Navigator.pop(ctx); // Close Edit Dialog
              Navigator.pop(context); // Refresh History Window
              _showHistoryDialog(item);
            },
            child: const Text('Update History'),
          )
        ],
      ),
    );
  }

  void _showHistoryDialog(StockModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${item.modelName} History'),
        content: SizedBox(
          width: double.maxFinite,
          height: 350,
          child: item.history.isEmpty
              ? const Center(child: Text('No transactions recorded yet.'))
              : ListView.builder(
                  itemCount: item.history.length,
                  itemBuilder: (context, index) {
                    final tx = item.history.reversed.toList()[index];
                    return Card(
                      color: tx.isStockIn ? Colors.green.shade50 : Colors.red.shade50,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Icon(
                          tx.isStockIn ? Icons.arrow_downward : Icons.arrow_upward,
                          color: tx.isStockIn ? Colors.green : Colors.red,
                        ),
                        title: Text('${tx.isStockIn ? "IN" : "OUT"}: ${tx.quantity} Pcs @ Rs. ${tx.price}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (tx.description.isNotEmpty) Text('Note: ${tx.description}'),
                            Text(
                              _formatDateTime(tx.date),
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.indigo, size: 20),
                          onPressed: () => _editHistoryDialog(item, tx),
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredStocks = stocks
        .where((s) => s.modelName.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chaudhary Mobile Digikhata'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const GoogleLoginScreen()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.indigo,
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          const Text('Low Stock Alert',
                              style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('$lowStockCount Items',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          const Text('Stock Value',
                              style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('Rs. ${totalStockValue.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search model/item...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredStocks.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                final item = filteredStocks[index];
                bool isLowStock = item.quantity <= 2;

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item.modelName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            if (isLowStock)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('Low Stock',
                                    style: TextStyle(color: Colors.red, fontSize: 10)),
                              )
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Quantity: ${item.quantity} | Cost: Rs. ${item.costPrice} | Sale: Rs. ${item.sellingPrice}',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.history, size: 18),
                              label: const Text('History'),
                              onPressed: () => _showHistoryDialog(item),
                            ),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.add, color: Colors.green, size: 16),
                                  label: const Text('IN', style: TextStyle(color: Colors.green)),
                                  onPressed: () => _stockInOutDialog(item, true),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.remove, color: Colors.red, size: 16),
                                  label: const Text('OUT', style: TextStyle(color: Colors.red)),
                                  onPressed: () => _stockInOutDialog(item, false),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewStockDialog,
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }
}
