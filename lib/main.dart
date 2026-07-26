import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      home: const DashboardScreen(),
    );
  }
}

class WatermarkBackground extends StatelessWidget {
  final Widget child;
  const WatermarkBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Center(
            child: Transform.rotate(
              angle: -0.4,
              child: Text(
                'Chaudhary Mobile',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.withOpacity(0.06),
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

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
          description: 'Initial Stock In',
          date: DateTime.now().subtract(const Duration(days: 1)),
        )
      ],
    ),
  ];

  String searchQuery = '';

  double get totalStockValue =>
      stocks.fold(0, (sum, item) => sum + (item.quantity * item.costPrice));

  int get totalItemsCount =>
      stocks.fold(0, (sum, item) => sum + item.quantity);

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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  qtyController.text.isNotEmpty) {
                setState(() {
                  stocks.add(
                    StockModel(
                      id: DateTime.now().toString(),
                      modelName: nameController.text,
                      quantity: int.parse(qtyController.text),
                      costPrice: double.tryParse(costController.text) ?? 0,
                      sellingPrice: double.tryParse(sellController.text) ?? 0,
                      history: [
                        TransactionItem(
                          id: DateTime.now().toString(),
                          isStockIn: true,
                          quantity: int.parse(qtyController.text),
                          price: double.tryParse(costController.text) ?? 0,
                          description: 'Stock Added',
                          date: DateTime.now(),
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
              decoration: const InputDecoration(labelText: 'Note / Description (Optional)'),
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
                setState(() {
                  if (isStockIn) {
                    item.quantity += qty;
                  } else {
                    item.quantity -= qty;
                  }
                  item.history.add(
                    TransactionItem(
                      id: DateTime.now().toString(),
                      isStockIn: isStockIn,
                      quantity: qty,
                      price: double.tryParse(priceController.text) ?? 0,
                      description: noteController.text.isEmpty
                          ? (isStockIn ? 'Stock In' : 'Stock Out/Sale')
                          : noteController.text,
                      date: DateTime.now(),
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

  @override
  Widget build(BuildContext context) {
    final filteredStocks = stocks
        .where((s) => s.modelName.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chaudhary Mobile Digikhata'),
        elevation: 0,
        backgroundColor: Colors.indigo,
      ),
      body: WatermarkBackground(
        child: Column(
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
                            const Text('Total Items',
                                style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('$totalItemsCount',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo)),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item.modelName,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              if (isLowStock)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('Low Stock',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 10)),
                                )
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Quantity: ${item.quantity} | Cost: Rs. ${item.costPrice} | Sale: Rs. ${item.sellingPrice}',
                              style: TextStyle(color: Colors.grey.shade700)),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
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
