import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MarketPage extends StatefulWidget {
  @override
  _MarketPageState createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  List<dynamic> stocks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }
  void showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Market'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Search for stocks',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
              },
            ),
            SizedBox(height: 16),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: stocks.length,
                      itemBuilder: (context, index) {
                        final stock = stocks[index];
                        return ListTile(
                          leading: Icon(Icons.trending_up, color: Colors.green),
                          title: Text(stock['description'] ?? 'N/A'),
                          subtitle: Text('Symbol: ${stock['symbol'] ?? 'N/A'}'),
                          trailing: ElevatedButton(
                            onPressed: () {
                            },
                            child: Text('Add'),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}