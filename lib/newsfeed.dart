import 'package:flutter/material.dart';

class NewsfeedPage extends StatefulWidget {
  @override
  _NewsfeedPageState createState() => _NewsfeedPageState();
}

class _NewsfeedPageState extends State<NewsfeedPage> {
  List<Map<String, String>> newsArticles = [
    {
      'title': 'Title here',
      'source': 'Source here',
      'date': 'Date here'
    },
  ];

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
      ),
      body: newsArticles.isEmpty
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
                    title: Text(article['title']!),
                    subtitle: Text('${article['source']} - ${article['date']}'),
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