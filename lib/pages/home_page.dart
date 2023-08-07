import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemListWidget extends StatefulWidget {
  @override
  _ItemListWidgetState createState() => _ItemListWidgetState();
}

class _ItemListWidgetState extends State<ItemListWidget> {
  List<String> expenses = [];
  TextEditingController _expenseController = TextEditingController();
  TextEditingController _moneyController = TextEditingController();
  String selectedCategory = 'Food'; // Update the selected category.

  List<String> categories = [
    'Food',
    'Transportation',
    'Housing',
    'Entertainment',
    'Other',
  ];

  Map<String, double> items = {};
  double total = 0.0;

  double getTotalAmount() {
    double totalAmount = 0.0;
    for (String expense in expenses) {
      final moneyPart = expense.split(' - ').last;
      final money = double.parse(moneyPart);
      totalAmount += money;
    }
    return totalAmount;
  }

  void addExpense(String expense, String category, double money) {
    setState(() {
      expenses.add('${expense} (${category}) - ${money.toStringAsFixed(2)}');
    });

    // Save the expense to Firestore
    saveExpenseToFirestore(expense, category, money);
  }

  void removeExpense(String expense) {
    setState(() {
      expenses.remove(expense);
    });
  }

  void fetchUserData() {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('expenses')
          .get()
          .then((querySnapshot) {
        setState(() {
          items = {};
          total = 0.0;
          querySnapshot.docs.forEach((doc) {
            String name = doc['expense'];
            String category = doc['category'];
            double money = doc['amount'].toDouble();
            items[name] = money;
            total = total + money;
            expenses.add('$name ($category) - ${money.toStringAsFixed(2)}');
          });
        });
      }).catchError((error) {
        print("Error fetching data: $error");
      });
    }
  }

  void saveExpenseToFirestore(String expense, String category, double money) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('expenses')
          .add({
        'expense': expense,
        'category': category,
        'amount': money,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((_) {
        print('Expense saved to Firestore successfully!');
      }).catchError((error) {
        print("Error saving expense to Firestore: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Expense Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _expenseController,
              decoration: InputDecoration(
                labelText: 'Expense',
                suffixIcon: IconButton(
                  onPressed: () {
                    _expenseController.clear();
                  },
                  icon: Icon(Icons.clear),
                ),
              ),
            ),
            DropdownButton(
              items: categories
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              value: selectedCategory,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value as String; // Update the selected category if value is not null.
                });
              },
            ),
            TextField(
              controller: _moneyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Money',
                suffixIcon: IconButton(
                  onPressed: () {
                    _moneyController.clear();
                  },
                  icon: Icon(Icons.clear),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                String expense = _expenseController.text.trim();
                double money = 0;

                try {
                  money = double.parse(_moneyController.text);
                } catch (e) {
                  // Handle parsing error gracefully (e.g., show a dialog).
                  return;
                }

                if (expense.isNotEmpty && money > 0) {
                  addExpense(expense, selectedCategory, money);
                  _expenseController.clear();
                  _moneyController.clear();
                }
              },
              child: Text('Add Expense'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  String expense = expenses[index];
                  return Dismissible(
                    key: Key(expense),
                    onDismissed: (direction) {
                      removeExpense(expense);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$expense removed.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Text(expense),
                      trailing: IconButton(
                        onPressed: () {
                          removeExpense(expense);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$expense removed.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: Icon(Icons.delete),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Total Amount: \$${getTotalAmount().toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
