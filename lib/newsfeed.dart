import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class NewsfeedPage extends StatefulWidget {
  @override
  _NewsfeedPageState createState() => _NewsfeedPageState();
}

class _NewsfeedPageState extends State<NewsfeedPage> {
  final String apiKey = 'cte9chpr01qt478lddkgcte9chpr01qt478lddl0'; 
  List<Map<String, dynamic>> newsArticles = []; 
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      final response = await http.get(
        Uri.parse('https://finnhub.io/api/v1/news?category=general&token=$apiKey'),
        headers: {'X-Finnhub-Token': apiKey},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          newsArticles = data.map((article) {
            final DateTime date = DateTime.fromMillisecondsSinceEpoch(
              article['datetime'] * 1000
            );
            return {
              'title': article['headline'],
              'source': article['source'],
              'date': DateFormat('MMM d, yyyy').format(date),
              'summary': article['summary'],
              'url': article['url']
            };
          }).cast<Map<String, dynamic>>().toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error fetching news: $e');
      setState(() {
        isLoading = false;
        newsArticles = []; 
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load news. Please try again later.')),
      );
    }
  }

  void _bookmarkArticle(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bookmarked: ${newsArticles[index]['title']}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Newsfeed'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : newsArticles.isEmpty
              ? Center(
                  child: Text(
                    'No news available.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: newsArticles.length,
                  itemBuilder: (context, index) {
                    final article = newsArticles[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(article['title'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${article['source']} - ${article['date']}'),
                            SizedBox(height: 4),
                            Text(
                              article['summary'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: Icon(Icons.bookmark_border),
                          onPressed: () => _bookmarkArticle(index),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}