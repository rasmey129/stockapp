import 'package:flutter/material.dart';

class WatchlistPage extends StatefulWidget {
  @override
  _WatchlistPageState createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  List<Map<String, dynamic>> watchlist = [
    {'symbol': 'AAPL', 'price': 175.00, 'change': '+1.2%'},
    {'symbol': 'GOOGL', 'price': 2800.50, 'change': '-0.8%'},
  ];

  void _removeFromWatchlist(int index) {
    setState(() {
      watchlist.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Watchlist'),
      ),
      body: watchlist.isEmpty
          ? Center(
              child: Text(
                'Your watchlist is empty.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: watchlist.length,
              itemBuilder: (context, index) {
                final stock = watchlist[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Icon(
                      Icons.trending_up,
                      color: stock['change'].startsWith('+') ? Colors.green : Colors.red,
                    ),
                    title: Text(stock['symbol']),
                    subtitle: Text('Price: \$${stock['price']} | Change: ${stock['change']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeFromWatchlist(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}