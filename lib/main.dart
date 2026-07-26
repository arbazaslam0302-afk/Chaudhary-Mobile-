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
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
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
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.withOpacity(0.08),
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
  double price;
  List<TransactionItem> history;

  StockModel({
    required this.id,
    required this.modelName,
    required this.quantity,
    required this.price,
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
      quantity: 3,
      price: 2500,
      history: [],
    ),
  ];

  String searchQuery = '';

  double get totalStockCost =>
      stocks.fold(0, (sum, item) => sum + (item.quantity * item.price));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chaudhary Mobile Dashboard'), backgroundColor: Colors.indigo),
      body: WatermarkBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                child: ListTile(
                  title: const Text('Total Stock Value'),
                  subtitle: Text('Rs. ${totalStockCost.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: stocks.length,
                  itemBuilder: (context, index) {
                    final item = stocks[index];
                    return Card(
                      child: ListTile(
                        title: Text(item.modelName),
                        subtitle: Text('Qty: ${item.quantity} | Price: Rs. ${item.price}'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
