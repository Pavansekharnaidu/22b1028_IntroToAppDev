import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Tracker',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> expenses = [
    Expense(description: 'Food', amount: 100.0, category: 'Food'),
    Expense(description: 'Transportation', amount: 50.0, category: 'Transportation'),
    Expense(description: 'Housing', amount: 300.0, category: 'Housing'),
    Expense(description: 'Entertainment', amount: 200.0, category: 'Entertainment'),
    Expense(description: 'Other', amount: 150.0, category: 'Other'),
  ];

  Future<void> _navigateToExpenseScreen() async {
    final updatedExpenses = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExpenseScreen(expenses: expenses)),
    );

    if (updatedExpenses != null) {
      setState(() {
        expenses = updatedExpenses;
      });
    }
  }

  double calculateTotalExpense() {
    return expenses.fold(0.0, (previous, current) => previous + current.amount);
  }

  @override
  Widget build(BuildContext context) {
    double totalExpense = calculateTotalExpense();

    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Tracker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pavan Sekhar Naidu',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.0),
            Text(
              'Total Expenses',
              style: TextStyle(fontSize: 20.0),
            ),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: _navigateToExpenseScreen,
        child: Text('Show All Expenses'),
      ),
    );
  }
}

class Expense {
  String description;
  double amount;
  String category;

  Expense({
    required this.description,
    required this.amount,
    required this.category,
  });
}

class ExpenseScreen extends StatefulWidget {
  final List<Expense> expenses;

  ExpenseScreen({required this.expenses});

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  void _addExpense() {
    showDialog(
      context: context,
      builder: (context) {
        String description = '';
        double amount = 0.0;

        return AlertDialog(
          title: Text('Add Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(hintText: 'Enter expense description'),
                onChanged: (value) {
                  description = value;
                },
              ),
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(hintText: 'Enter expense amount'),
                onChanged: (value) {
                  amount = double.tryParse(value) ?? 0.0;
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.expenses.add(Expense(description: description, amount: amount, category: 'Other'));
                  Navigator.pop(context, widget.expenses);
                });
              },
              child: Text('Save'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _editExpense(int index) {
    showDialog(
      context: context,
      builder: (context) {
        String description = widget.expenses[index].description;
        double amount = widget.expenses[index].amount;

        return AlertDialog(
          title: Text('Edit Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(hintText: 'Enter expense description'),
                controller: TextEditingController(text: description),
                onChanged: (value) {
                  description = value;
                },
              ),
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(hintText: 'Enter expense amount'),
                controller: TextEditingController(text: amount.toString()),
                onChanged: (value) {
                  amount = double.tryParse(value) ?? 0.0;
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.expenses[index].description = description;
                  widget.expenses[index].amount = amount;
                  Navigator.pop(context, widget.expenses);
                });
              },
              child: Text('Save'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteExpense(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Expense'),
          content: Text('Are you sure you want to delete this expense?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.expenses.removeAt(index);
                  Navigator.pop(context, widget.expenses);
                });
              },
              child: Text('Delete'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalExpense = widget.expenses.fold(0.0, (previous, current) => previous + current.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Screen'),
      ),
      body: Column(
        children: [
          Text('Total of all expenses: \$${totalExpense.toStringAsFixed(2)}', style: TextStyle(fontSize: 20.0)),
          Expanded(
            child: ListView.builder(
              itemCount: widget.expenses.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(widget.expenses[index].description),
                  subtitle: Text(widget.expenses[index].category),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('\$${widget.expenses[index].amount.toStringAsFixed(2)}'),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editExpense(index);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteExpense(index);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addExpense();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
