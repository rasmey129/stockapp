import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class StockDetailsPage extends StatefulWidget {
  final String symbol;
  final String userId;

  const StockDetailsPage({
    Key? key, 
    required this.symbol,
    required this.userId,
  }) : super(key: key);

  @override
  _StockDetailsPageState createState() => _StockDetailsPageState();
}

class _StockDetailsPageState extends State<StockDetailsPage> {
  Map<String, dynamic> companyProfile = {};
  Map<String, dynamic> stockQuote = {};
  bool isLoading = true;
  String errorMessage = '';
  bool isInWatchlist = false;

  @override
  void initState() {
    super.initState();
    fetchStockDetails();
    checkWatchlistStatus();
  }

  Future<void> checkWatchlistStatus() async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('watchlist')
        .doc(widget.symbol);

    final docSnapshot = await docRef.get();
    setState(() {
      isInWatchlist = docSnapshot.exists;
    });
  }

  Future<void> toggleWatchlist() async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('watchlist')
        .doc(widget.symbol);

    try {
      if (isInWatchlist) {
        await docRef.delete();
        setState(() {
          isInWatchlist = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed from watchlist')),
        );
      } else {
        await docRef.set({
          'symbol': widget.symbol,
          'name': companyProfile['name'] ?? widget.symbol,
          'price': stockQuote['c']?.toStringAsFixed(2),
          'change': '${stockQuote['dp'] >= 0 ? '+' : ''}${stockQuote['dp'].toStringAsFixed(2)}%',
          'updatedAt': FieldValue.serverTimestamp(),
        });
        setState(() {
          isInWatchlist = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added to watchlist')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update watchlist')),
      );
    }
  }

  Future<void> fetchStockDetails() async {
    const String apiKey = 'cte9chpr01qt478lddkgcte9chpr01qt478lddl0'; 
    try {
      final headers = {
        'X-Finnhub-Token': apiKey,
      };

      final profileResponse = await http.get(
        Uri.parse('https://finnhub.io/api/v1/stock/profile2?symbol=${widget.symbol}'),
        headers: headers,
      );

      final quoteResponse = await http.get(
        Uri.parse('https://finnhub.io/api/v1/quote?symbol=${widget.symbol}'),
        headers: headers,
      );

      if (profileResponse.statusCode == 200 && quoteResponse.statusCode == 200) {
        setState(() {
          companyProfile = json.decode(profileResponse.body);
          stockQuote = json.decode(quoteResponse.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load stock details';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isInWatchlist ? Icons.star : Icons.star_border,
              color: isInWatchlist ? Colors.amber : null,
            ),
            onPressed: toggleWatchlist,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (stockQuote.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '\$${stockQuote['c']?.toStringAsFixed(2) ?? '--'}',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            (stockQuote['dp'] ?? 0) >= 0 
                                                ? Icons.arrow_upward 
                                                : Icons.arrow_downward,
                                            color: (stockQuote['dp'] ?? 0) >= 0 
                                                ? Colors.green 
                                                : Colors.red,
                                            size: 20,
                                          ),
                                          Text(
                                            '${(stockQuote['dp'] ?? 0).toStringAsFixed(2)}%',
                                            style: TextStyle(
                                              color: (stockQuote['dp'] ?? 0) >= 0 
                                                  ? Colors.green 
                                                  : Colors.red,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: (stockQuote['dp'] ?? 0) >= 0 
                                        ? Colors.green.withOpacity(0.1) 
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    (stockQuote['dp'] ?? 0) >= 0 
                                        ? Icons.trending_up 
                                        : Icons.trending_down,
                                    color: (stockQuote['dp'] ?? 0) >= 0 
                                        ? Colors.green 
                                        : Colors.red,
                                    size: 32,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('High: \$${stockQuote['h']?.toStringAsFixed(2) ?? '--'}'),
                                Text('Low: \$${stockQuote['l']?.toStringAsFixed(2) ?? '--'}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  SizedBox(height: 16),

                  if (companyProfile.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          
                              if (companyProfile['logo'] != null && companyProfile['logo'].toString().isNotEmpty)
                                Container(
                                  width: 50,
                                  height: 50,
                                  margin: EdgeInsets.only(right: 16, bottom: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(companyProfile['logo']),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  companyProfile['name'] ?? widget.symbol,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text('Industry: ${companyProfile['finnhubIndustry'] ?? 'N/A'}'),
                          SizedBox(height: 4),
                          Text('Country: ${companyProfile['country'] ?? 'N/A'}'),
                          SizedBox(height: 8),
                          Text(
                            companyProfile['description'] ?? 'No description available.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}