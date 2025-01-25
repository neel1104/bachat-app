import 'package:bachat/services/transaction.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/transaction.dart' as mt;
import '../components/indicator.dart';
import '../components/progress_bar.dart';
import '../components/section_title.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  List<mt.Transaction> _txs = [];

  DashboardState() {
    _initTransactionsState();
  }

  Future<void> _initTransactionsState() async {
    List<mt.Transaction> transactions =
        await TransactionService().fetchAll(limit: 100);
    setState(() {
      _txs = transactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.0),
          TabBarSection(),
          SizedBox(height: 16.0),
          Expanded(
            child: ListView(
              children: [
                SectionTitle(title: 'Monthly Spending vs. Budget'),
                SizedBox(height: 16.0),
                CategorySpendPieChart(transactions: _txs),
                SizedBox(height: 16.0),
                SectionTitle(title: 'Goal Progress'),
                ProgressBar(title: 'Emergency Fund', current: 300, total: 500),
                ProgressBar(title: 'Vacation', current: 150, total: 1000),
                ProgressBar(title: 'Concert Tickets', current: 50, total: 200),
                SizedBox(height: 16.0),
                SectionTitle(title: 'Upcoming Bills'),
                ListTile(
                  title: Text('Internet'),
                  trailing: Text('\$65'),
                ),
                ListTile(
                  title: Text('Mortgage'),
                  trailing: Text('\$1,000'),
                ),
                ListTile(
                  title: Text('Health Insurance'),
                  trailing: Text('\$250'),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.add),
                label: Text('Add Goal'),
              ),
              OutlinedButton(
                onPressed: () {},
                child: Text('Add Transaction'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TabBarSection extends StatelessWidget {
  const TabBarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: 'Spending vs Budget'),
              Tab(text: 'Goal Progress'),
              Tab(text: 'Upcoming Bills'),
            ],
          ),
        ],
      ),
    );
  }
}


class CategorySpendPieChart extends StatelessWidget {
  final List<mt.Transaction> transactions;

  const CategorySpendPieChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final categorySpends = _getCategorySpends(transactions);

    return Row(children: [
      const SizedBox(
        height: 18,
      ),
      Expanded(
          child: AspectRatio(
        aspectRatio: 1.5,
        child: PieChart(
          PieChartData(
            sections: categorySpends.entries.map((entry) {
              final color = _getCategoryColor(entry.key);
              return PieChartSectionData(
                value: entry.value,
                title: "${entry.key}\n${entry.value.toStringAsFixed(2)}",
                color: color,
                radius: 50,
                // titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              );
            }).toList(),
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            borderData: FlBorderData(show: false),
          ),
        ),
      )),
      Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _getLegend(categorySpends)),
      const SizedBox(
        width: 28,
      ),
    ]);
  }

  List<Widget> _getLegend(Map<String, double> categorySpends) {
    return categorySpends.entries.map((entry) {
      final color = _getCategoryColor(entry.key);
      return Indicator(color: color, text: entry.key, isSquare: true);
    }).toList();
  }

  Color _getCategoryColor(String category) {
    // Shades of blue palette
    const bluishPalette = [
      Color(0xFF1565C0), // Blue 800
      Color(0xFF1976D2), // Blue 700
      Color(0xFF1E88E5), // Blue 600
      Color(0xFF42A5F5), // Blue 400
      Color(0xFF64B5F6), // Blue 300
      Color(0xFF90CAF9), // Blue 200
      Color(0xFFBBDEFB), // Blue 100
      Color(0xFFE3F2FD), // Blue 50
    ];
    final index = category.hashCode % bluishPalette.length;
    return bluishPalette[index];
  }

  Map<String, double> _getCategorySpends(List<mt.Transaction> transactions) {
    final Map<String, double> categorySpends = {};

    for (var tx in transactions) {
      final category = tx.category ?? "Uncategorized";
      categorySpends[category] = (categorySpends[category] ?? 0) + tx.amount!;
      if (tx.txDate!.isBefore(DateTime.now().subtract(Duration(days: 7)))) {
        break;
      }
    }
    return categorySpends;
  }
}
