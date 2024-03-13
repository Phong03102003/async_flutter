import 'dart:convert';

import 'package:async_flutter/article_model.dart';
import 'package:async_flutter/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'saved_articles_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Article> _articles = [];
  List<Article> _savedArticles = []; // Danh sách các bài viết đã lưu

  @override
  void initState() {
    super.initState();
    _getArticles();
  }

  Future<void> _getArticles() async {
    const url =
        'https://newsapi.org/v2/everything?q=apple&from=2024-03-12&to=2024-03-12&sortBy=popularity&apiKey=65247db2e60541e0887a3251b6cf13c8';
    final res = await http.get(Uri.parse(url));
    final body = json.decode(res.body) as Map<String, dynamic>;

    final articles = (body['articles'] as List).map((article) {
      return Article(
          title: article['title'],
          urlToImage: article['urlToImage'] ??
              'https://via.placeholder.com/1200%20x%20627/',
          content: article['content'] ?? 'Không có dữ liệu',
          url: article['url']);
    }).toList();

    setState(() {
      _articles = articles;
    });
  }

  void _navigateToSavedArticles() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SavedArticlesScreen(savedArticles: _savedArticles),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            Row(
              children: [
                Text(
                  DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
                  style: const TextStyle(color: Colors.grey, fontSize: 14.0),
                ),
              ],
            ),
            const Row(
              children: [
                Text(
                  'Explore',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      body: _articles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _articles.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailPage(news: _articles[index]),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 0.0,
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          _articles[index].urlToImage,
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        _articles[index].title,
                        style: const TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToSavedArticles,
        child: const Icon(Icons.download),
      ),
    );
  }
}
