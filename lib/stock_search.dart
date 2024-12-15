import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'watchlist.dart';

class StockSearchPage extends StatefulWidget {
  final String userId;
  final String initialSymbol;

  const StockSearchPage({
    Key? key,
    required this.userId,
    required this.initialSymbol,
  }) : super(key: key);

  @override
  _StockSearchPageState createState() => _StockSearchPageState();
}

class _StockSearchPageState extends State<StockSearchPage> {
  final String apiKey = 'cte9chpr01qt478lddkgcte9chpr01qt478lddl0';  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();
  Map<String, dynamic>? stockQuote;
  List<FlSpot> candleData = [];
  bool isLoading = false;
  bool isInWatchlist = false;

  @override
  void initState() {
    super.initState();
    searchController.text = widget.initialSymbol;
    if (widget.initialSymbol.isNotEmpty) {
      fetchStockData(widget.initialSymbol);
    }
  }

  Future<void> checkWatchlistStatus(String symbol) async {
    final docRef = _firestore
        .collection('users')
        .doc(widget.userId)
        .collection('watchlist')
        .doc(symbol.toUpperCase());

    final docSnapshot = await docRef.get();
    setState(() {
      isInWatchlist = docSnapshot.exists;
    });
  }

  Future<void> toggleWatchlist() async {
    if (stockQuote == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(widget.userId)
        .collection('watchlist')
        .doc(stockQuote!['symbol']);

    try {
      if (isInWatchlist) {
        // Remove from watchlist
        await docRef.delete();
        setState(() {
          isInWatchlist = false;
        });
        showSnackBar('Removed from watchlist');
      } else {
        // Add to watchlist
        await docRef.set({
          'symbol': stockQuote!['symbol'],
          'name': stockQuote!['name'] ?? stockQuote!['symbol'],
          'price': stockQuote!['c'].toStringAsFixed(2),
          'change': '${stockQuote!['dp'] >= 0 ? '+' : ''}${stockQuote!['dp'].toStringAsFixed(2)}%',
          'updatedAt': FieldValue.serverTimestamp(),
        });
        setState(() {
          isInWatchlist = true;
        });
        showSnackBar('Added to watchlist');
      }
    } catch (e) {
      print('Error toggling watchlist: $e');
      showErrorSnackBar('Failed to update watchlist');
    }
  }

  Future<void> fetchStockData(String symbol) async {
    setState(() {
      isLoading = true;
      stockQuote = null;
      candleData = [];
    });

    try {
      final headers = {
        'X-Finnhub-Token': apiKey,
      };

      // Fetch quote
      final quoteResponse = await http.get(
        Uri.parse('https://finnhub.io/api/v1/quote?symbol=${symbol.toUpperCase()}'),
        headers: headers,
      );

      // Fetch company info
      final companyResponse = await http.get(
        Uri.parse('https://finnhub.io/api/v1/search?q=${symbol.toUpperCase()}'),
        headers: headers,
      );

      if (quoteResponse.statusCode == 200 && companyResponse.statusCode == 200) {
        final quoteData = json.decode(quoteResponse.body);
        final companyData = json.decode(companyResponse.body);

        String companyName = symbol.toUpperCase();
        if (companyData['result'] != null && companyData['result'].isNotEmpty) {
          companyName = companyData['result'][0]['description'] ?? symbol.toUpperCase();
        }

        await checkWatchlistStatus(symbol);

        setState(() {
          stockQuote = {
            ...quoteData,
            'symbol': symbol.toUpperCase(),
            'name': companyName,
          };
        });

        // Fetch candle data
        final now = DateTime.now();
        final fiveDaysAgo = now.subtract(Duration(days: 5));
        final candleResponse = await http.get(
          Uri.parse(
            'https://finnhub.io/api/v1/stock/candle?symbol=${symbol.toUpperCase()}'
            '&resolution=D'
            '&from=${fiveDaysAgo.millisecondsSinceEpoch ~/ 1000}'
            '&to=${now.millisecondsSinceEpoch ~/ 1000}',
          ),
          headers: headers,
        );

        if (candleResponse.statusCode == 200) {
          final candleResponseData = json.decode(candleResponse.body);
          if (candleResponseData['c'] != null) {
            setState(() {
              candleData = List.generate(
                candleResponseData['c'].length,
                (index) => FlSpot(
                  index.toDouble(),
                  candleResponseData['c'][index].toDouble(),
                ),
              );
            });
          }
        }
      } else {
        throw Exception('Failed to fetch stock data');
      }
    } catch (e) {
      print('Error: $e');
      showErrorSnackBar('An error occurred while fetching data');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Search'),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WatchlistPage(userId: widget.userId),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => fetchStockData(searchController.text.trim()),
                ),
                hintText: 'Enter US stock symbol (e.g., AAPL)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
              onSubmitted: (value) => fetchStockData(value.trim()),
            ),
            SizedBox(height: 16),

            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (stockQuote != null) ...[
              Row(
                children: [
                  Icon(Icons.show_chart),
                  SizedBox(width: 8),
                  Text(
                    stockQuote!['symbol'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      stockQuote!['name'] ?? '',
                      style: TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isInWatchlist ? Icons.star : Icons.star_border,
                      color: isInWatchlist ? Colors.amber : null,
                    ),
                    onPressed: toggleWatchlist,
                  ),
                ],
              ),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${stockQuote!['c']?.toStringAsFixed(2) ?? '--'}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Change: ${(stockQuote!['dp'] ?? 0).toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: (stockQuote!['dp'] ?? 0) >= 0
                            ? Colors.green[100]
                            : Colors.red[100],
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Updated: ${DateTime.now().toString().split('.')[0]}',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),

              if (candleData.isNotEmpty)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price History (5 Days)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Container(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: candleData,
                                  isCurved: true,
                                  color: Colors.blue,
                                  barWidth: 2,
                                  dotData: FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.blue.withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ] else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Enter a stock symbol to view data.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Examples: AAPL, MSFT, GOOGL',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}