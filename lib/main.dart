import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      home: const AuthWrapper(),
    );
  }
}

// ------------------- AUTH WRAPPER -------------------
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return DashboardScreen(user: snapshot.data!);
        }
        return const GoogleLoginScreen();
      },
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
  bool _isSigningIn = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isSigningIn = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
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
                  const Text('Cloud Digikhata System', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 30),
                  _isSigningIn
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
                          onPressed: _signInWithGoogle,
                        ),
                  const SizedBox(height: 15),
                  const Text(
                    'Data will sync across all connected devices.',
                    textAlign: TextAlign.center,
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

// ------------------- DASHBOARD -------------------
class DashboardScreen extends StatefulWidget {
  final User user;
  const DashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String searchQuery = '';

  CollectionReference get _userStockRef => FirebaseFirestore.instance
      .collection('users')
      .doc(widget.user.uid)
      .collection('stocks');

  String _formatDate(DateTime dt) {
    return "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }

  // DATE PICKER HELPER
  Future<DateTime?> _pickDate(BuildContext context, DateTime initialDate) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
  }

  // ADD NEW ITEM DIALOG
  void _addNewStockDialog() {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    final costController = TextEditingController();
    final sellController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Item / Model Name')),
                TextField(controller: qtyController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity')),
                TextField(controller: costController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cost Price')),
                TextField(controller: sellController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sale Price')),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date: ${_formatDate(selectedDate)}', style: const TextStyle(fontSize: 12)),
                    TextButton(
                      child: const Text('Change Date'),
                      onPressed: () async {
                        DateTime? picked = await _pickDate(context, selectedDate);
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                    )
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && qtyController.text.isNotEmpty) {
                  int qty = int.parse(qtyController.text);
                  double cost = double.tryParse(costController.text) ?? 0;

                  DocumentReference docRef = _userStockRef.doc();
                  await docRef.set({
                    'modelName': nameController.text,
                    'quantity': qty,
                    'costPrice': cost,
                    'sellingPrice': double.tryParse(sellController.text) ?? 0,
                    'createdAt': Timestamp.fromDate(selectedDate),
                  });

                  await docRef.collection('history').add({
                    'isStockIn': true,
                    'quantity': qty,
                    'price': cost,
                    'description': 'Initial Stock',
                    'date': Timestamp.fromDate(selectedDate),
                  });

                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save Item'),
            ),
          ],
        ),
      ),
    );
  }

  // EDIT ITEM DIALOG
  void _editStockDialog(String docId, Map<String, dynamic> data) {
    final nameController = TextEditingController(text: data['modelName']);
    final costController = TextEditingController(text: data['costPrice'].toString());
    final sellController = TextEditingController(text: data['sellingPrice'].toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Item Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Item / Model Name')),
            TextField(controller: costController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cost Price')),
            TextField(controller: sellController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sale Price')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _userStockRef.doc(docId).update({
                'modelName': nameController.text,
                'costPrice': double.tryParse(costController.text) ?? data['costPrice'],
                'sellingPrice': double.tryParse(sellController.text) ?? data['sellingPrice'],
              });
              Navigator.pop(ctx);
            },
            child: const Text('Update'),
          )
        ],
      ),
    );
  }

  // DELETE ITEM CONFIRMATION
  void _deleteStockDialog(String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item completely?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _userStockRef.doc(docId).delete();
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          )
        ],
      ),
    );
  }

  // STOCK IN / OUT DIALOG WITH DATE SELECTION
  void _stockInOutDialog(String docId, int currentQty, bool isStockIn, double defaultPrice) {
    final qtyController = TextEditingController();
    final priceController = TextEditingController(text: defaultPrice.toString());
    final noteController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isStockIn ? 'Stock IN (+)' : 'Stock OUT (-)'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: qtyController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity')),
                TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price')),
                TextField(controller: noteController, decoration: const InputDecoration(labelText: 'Note / Customer Name')),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date: ${_formatDate(selectedDate)}', style: const TextStyle(fontSize: 12)),
                    TextButton(
                      child: const Text('Change Date'),
                      onPressed: () async {
                        DateTime? picked = await _pickDate(context, selectedDate);
                        if (picked != null) setDialogState(() => selectedDate = picked);
                      },
                    )
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: isStockIn ? Colors.green : Colors.red),
              onPressed: () async {
                int qty = int.tryParse(qtyController.text) ?? 0;
                if (qty > 0) {
                  int newQty = isStockIn ? (currentQty + qty) : (currentQty - qty);
                  await _userStockRef.doc(docId).update({'quantity': newQty});

                  await _userStockRef.doc(docId).collection('history').add({
                    'isStockIn': isStockIn,
                    'quantity': qty,
                    'price': double.tryParse(priceController.text) ?? 0,
                    'description': noteController.text.isEmpty ? (isStockIn ? 'Stock In' : 'Sale/Out') : noteController.text,
                    'date': Timestamp.fromDate(selectedDate),
                  });

                  Navigator.pop(ctx);
                }
              },
              child: Text(isStockIn ? 'Add Stock' : 'Out Stock'),
            )
          ],
        ),
      ),
    );
  }

  // SHOW HISTORY & EDIT/DELETE HISTORY ENTRY
  void _showHistoryDialog(String docId, String modelName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$modelName History'),
        content: SizedBox(
          width: double.maxFinite,
          height: 350,
          child: StreamBuilder<QuerySnapshot>(
            stream: _userStockRef.doc(docId).collection('history').orderBy('date', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              var docs = snapshot.data!.docs;

              if (docs.isEmpty) return const Center(child: Text('No transaction history found.'));

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var tx = docs[index].data() as Map<String, dynamic>;
                  String historyId = docs[index].id;
                  DateTime dt = (tx['date'] as Timestamp).toDate();

                  return Card(
                    color: tx['isStockIn'] ? Colors.green.shade50 : Colors.red.shade50,
                    child: ListTile(
                      title: Text('${tx['isStockIn'] ? "IN" : "OUT"}: ${tx['quantity']} Pcs @ Rs. ${tx['price']}'),
                      subtitle: Text('Note: ${tx['description']}\nDate: ${_formatDate(dt)}', style: const TextStyle(fontSize: 11)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () async {
                              await _userStockRef.doc(docId).collection('history').doc(historyId).delete();
                            },
                          )
                        ],
                      ),
                    ),
                  );
                },
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chaudhary Mobile Digikhata'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await GoogleSignIn().signOut();
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _userStockRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var docs = snapshot.data!.docs;
          double totalStockValue = 0;
          int lowStockCount = 0;

          for (var doc in docs) {
            var data = doc.data() as Map<String, dynamic>;
            int qty = data['quantity'] ?? 0;
            double cost = (data['costPrice'] ?? 0).toDouble();
            totalStockValue += (qty * cost);
            if (qty <= 2) lowStockCount++;
          }

          var filteredDocs = docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String name = (data['modelName'] ?? '').toString().toLowerCase();
            return name.contains(searchQuery.toLowerCase());
          }).toList();

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.indigo,
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              const Text('Low Stock Alert', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text('$lowStockCount Items', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              const Text('Stock Value', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text('Rs. ${totalStockValue.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredDocs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, index) {
                    var doc = filteredDocs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    String docId = doc.id;
                    int qty = data['quantity'] ?? 0;

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
                                Text(data['modelName'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.indigo, size: 20),
                                      onPressed: () => _editStockDialog(docId, data),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                      onPressed: () => _deleteStockDialog(docId),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Text('Quantity: $qty | Cost: Rs. ${data['costPrice']} | Sale: Rs. ${data['sellingPrice']}'),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.history, size: 18),
                                  label: const Text('History'),
                                  onPressed: () => _showHistoryDialog(docId, data['modelName'] ?? ''),
                                ),
                                Row(
                                  children: [
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.add, color: Colors.green, size: 16),
                                      label: const Text('IN', style: TextStyle(color: Colors.green)),
                                      onPressed: () => _stockInOutDialog(docId, qty, true, (data['costPrice'] ?? 0).toDouble()),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.remove, color: Colors.red, size: 16),
                                      label: const Text('OUT', style: TextStyle(color: Colors.red)),
                                      onPressed: () => _stockInOutDialog(docId, qty, false, (data['sellingPrice'] ?? 0).toDouble()),
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
          );
        },
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
