import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10,0,10,10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TextField(
          //   decoration: InputDecoration(
          //     hintText: 'Search transactions...',
          //     prefixIcon: Icon(Icons.search),
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(8.0),
          //     ),
          //   ),
          // ),
          SizedBox(height: 16.0),
          TabBarSection(),
          SizedBox(height: 16.0),
          Expanded(
            child: ListView(
              children: [
                SectionTitle(title: 'Monthly Spending vs. Budget'),
                Placeholder(fallbackHeight: 150),
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

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final String title;
  final int current;
  final int total;

  const ProgressBar({super.key, required this.title, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        SizedBox(height: 4.0),
        LinearProgressIndicator(
          value: current / total,
          backgroundColor: Colors.grey[300],
          color: Colors.blue,
        ),
        SizedBox(height: 8.0),
      ],
    );
  }
}