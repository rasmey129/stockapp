import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'stock_search.dart';

class MarketPage extends StatefulWidget {
  @override
  _MarketPageState createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  final String apiKey = 'cte9chpr01qt478lddkgcte9chpr01qt478lddl0';
  List<dynamic> stocks = [];
  Map<String, dynamic> stockPrices = {};
  bool isLoading = true;

  final List<Map<String, String>> defaultStocks = [
    {'symbol': 'AAPL', 'description': 'Apple Inc'},
    {'symbol': 'MSFT', 'description': 'Microsoft Corporation'},
    {'symbol': 'GOOGL', 'description': 'Alphabet Inc'},
    {'symbol': 'AMZN', 'description': 'Amazon.com Inc'},
    {'symbol': 'META', 'description': 'Meta Platforms Inc'},
    {'symbol': 'TSLA', 'description': 'Tesla Inc'},
    {'symbol': 'NVDA', 'description': 'NVIDIA Corporation'},
    {'symbol': 'WMT', 'description': 'Walmart Inc'},
  ];

  @override
  void initState() {
    super.initState();
    loadDefaultStocks();
  }

  Future<void> loadDefaultStocks() async {
    setState(() {
      isLoading = true;
      stocks = List.from(defaultStocks);
    });

    try {
      for (var stock in defaultStocks) {
        final String symbol = stock['symbol'] ?? '';
        if (symbol.isNotEmpty) {
          final priceResponse = await http.get(
            Uri.parse('https://finnhub.io/api/v1/quote?symbol=$symbol&token=$apiKey'),
          );
          
          if (priceResponse.statusCode == 200) {
            final priceData = json.decode(priceResponse.body);
            setState(() {
              stockPrices[symbol] = priceData;
            });
          }
        }
      }
    } catch (e) {
      showError('Failed to fetch stock prices: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> searchStocks(String query) async {
    if (query.isEmpty) {
      loadDefaultStocks();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://finnhub.io/api/v1/search?q=$query&token=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> searchResults = data['result'] ?? [];
        
        setState(() {
          stocks = searchResults;
        });

        for (var stock in searchResults) {
          final String symbol = stock['symbol'];
          final priceResponse = await http.get(
            Uri.parse('https://finnhub.io/api/v1/quote?symbol=$symbol&token=$apiKey'),
          );
          
          if (priceResponse.statusCode == 200) {
            final priceData = json.decode(priceResponse.body);
            setState(() {
              stockPrices[symbol] = priceData;
            });
          }
        }
      } else {
        throw Exception('Failed to search stocks');
      }
    } catch (e) {
      showError('Failed to search stocks: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
                searchStocks(value);
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
                        final price = stockPrices[stock['symbol']];
                        final currentPrice = price != null ? price['c']?.toStringAsFixed(2) : 'N/A';
                        final priceChange = price != null ? price['dp']?.toStringAsFixed(2) : 'N/A';
                        final isPositive = price != null ? (price['dp'] ?? 0) >= 0 : false;

                        return ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StockSearchPage(
                                  initialSymbol: stock['symbol'] ?? '',
                                ),
                              ),
                            );
                          },
                          leading: Icon(
                            isPositive ? Icons.trending_up : Icons.trending_down,
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                          title: Text(stock['description'] ?? 'N/A'),
                          subtitle: Text('Symbol: ${stock['symbol'] ?? 'N/A'}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$$currentPrice',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '$priceChange%',
                                style: TextStyle(
                                  color: isPositive ? Colors.green : Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ],
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