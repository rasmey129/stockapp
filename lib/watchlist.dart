import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WatchlistPage extends StatefulWidget {
  final String userId;

  const WatchlistPage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _WatchlistPageState createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getWatchlistStream() {
    return _firestore
        .collection('users')
        .doc(widget.userId)
        .collection('watchlist')
        .snapshots();
  }

  void _removeFromWatchlist(String symbol) async {
    try {
      await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('watchlist')
          .doc(symbol)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$symbol removed from watchlist'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      print('Error removing from watchlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove from watchlist'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Watchlist'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getWatchlistStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Your watchlist is empty.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final stockData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final symbol = stockData['symbol'] as String;
              final price = stockData['price'];
              final change = stockData['change'];
              final isPositive = change.toString().startsWith('+');

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Icon(
                    Icons.trending_up,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  title: Text(symbol),
                  subtitle: Text('Price: \$${price} | Change: ${change}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeFromWatchlist(symbol),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}