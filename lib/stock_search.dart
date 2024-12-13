import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StockSearchPage extends StatefulWidget {
  final String initialSymbol;

  const StockSearchPage({Key? key, required this.initialSymbol}) : super(key: key);

  @override
  _StockSearchPageState createState() => _StockSearchPageState();
}

class _StockSearchPageState extends State<StockSearchPage> {
  final String apiKey = 'cte9chpr01qt478lddkgcte9chpr01qt478lddl0';
  TextEditingController searchController = TextEditingController();
  Map<String, dynamic>? stockQuote;
  List<FlSpot> candleData = [];
  bool isLoading = false;
  DateTime? lastRequestTime;
  int requestCount = 0;
  static const int MAX_REQUESTS_PER_MINUTE = 30; 

  @override
  void initState() {
    super.initState();
    searchController.text = widget.initialSymbol;
    if (widget.initialSymbol.isNotEmpty) {
      fetchStockData(widget.initialSymbol);
    }
  }

  Future<bool> checkRateLimit() async {
    final now = DateTime.now();
    
    if (lastRequestTime != null && 
        now.difference(lastRequestTime!).inMinutes >= 1) {
      requestCount = 0;
    }
    if (requestCount >= MAX_REQUESTS_PER_MINUTE) {
      throw Exception('Rate limit reached. Please wait a minute before trying again.');
    }
    if (lastRequestTime != null) {
      final difference = now.difference(lastRequestTime!);
      if (difference.inSeconds < 1) {
        await Future.delayed(Duration(seconds: 1));
      }
    }

    lastRequestTime = now;
    requestCount++;
    return true;
  }

  bool isValidUSSymbol(String symbol) {
    final pattern = RegExp(r'^[A-Z]{1,5}$');
    return pattern.hasMatch(symbol);
  }

  Future<void> fetchStockData(String symbol) async {
    symbol = symbol.trim().toUpperCase();
    
    if (symbol.isEmpty) {
      showErrorSnackBar('Please enter a stock symbol');
      return;
    }

    if (!isValidUSSymbol(symbol)) {
      showErrorSnackBar('Invalid symbol format. Please enter a valid US stock symbol (1-5 letters)');
      return;
    }

    setState(() {
      isLoading = true;
      stockQuote = null;
      candleData = [];
    });

    try {
      await checkRateLimit();

      final headers = {
        'X-Finnhub-Token': apiKey,
      };

      final quoteResponse = await http.get(
        Uri.parse('https://finnhub.io/api/v1/quote?symbol=$symbol'),
        headers: headers,
      );

      if (quoteResponse.statusCode == 429) {
        throw Exception('Free API limit reached. Please try again in a minute.');
      }

      final quoteData = json.decode(quoteResponse.body);
      
      if (quoteData['c'] == 0 && quoteData['h'] == 0 && quoteData['l'] == 0) {
        throw Exception('Symbol not found or not supported in free tier. Please enter a valid US stock symbol.');
      }

      await checkRateLimit();
      final companyResponse = await http.get(
        Uri.parse('https://finnhub.io/api/v1/search?q=$symbol'),
        headers: headers,
      );

      String companyName = symbol;
      if (companyResponse.statusCode == 200) {
        final companyData = json.decode(companyResponse.body);
        if (companyData['result'] != null && companyData['result'].isNotEmpty) {
          companyName = companyData['result'][0]['description'] ?? symbol;
        }
      }
      await checkRateLimit();
      final now = DateTime.now();
      final fiveDaysAgo = now.subtract(Duration(days: 5));
      final candleResponse = await http.get(
        Uri.parse(
          'https://finnhub.io/api/v1/stock/candle?symbol=$symbol'
          '&resolution=D'
          '&from=${fiveDaysAgo.millisecondsSinceEpoch ~/ 1000}'
          '&to=${now.millisecondsSinceEpoch ~/ 1000}',
        ),
        headers: headers,
      );

      final candleResponseData = json.decode(candleResponse.body);

      setState(() {
        stockQuote = {
          ...quoteData,
          'name': companyName,
        };

        if (candleResponseData['s'] == 'ok' && candleResponseData['c'] != null) {
          candleData = List.generate(
            candleResponseData['c'].length,
            (index) => FlSpot(
              index.toDouble(),
              candleResponseData['c'][index].toDouble(),
            ),
          );
        }
      });
    } catch (e) {
      print('Error: $e');
      showErrorSnackBar(e.toString());
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
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('US Stock Search (Free)'),
        backgroundColor: Colors.blue,
        elevation: 0,
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
                  onPressed: () => fetchStockData(searchController.text),
                ),
                hintText: '',
                helperText: 'Free tier: US stocks only, limited to 60 requests/minute',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
              onSubmitted: (value) => fetchStockData(value),
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
                    searchController.text.toUpperCase(),
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
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Change: ${(stockQuote!['dp'] ?? 0).toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: (stockQuote!['dp'] ?? 0) >= 0 ? Colors.green[100] : Colors.red[100],
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
                      'Enter a US stock symbol to view data.',
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