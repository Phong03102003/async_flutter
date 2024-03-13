import 'package:async_flutter/article_model.dart'; // Assuming Article model import
import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';

import 'detail_page.dart';

class SavedArticlesScreen extends StatefulWidget {
  const SavedArticlesScreen({Key? key, required List<Article> savedArticles})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SavedArticlesScreenState createState() => _SavedArticlesScreenState();
}

class _SavedArticlesScreenState extends State<SavedArticlesScreen> {
  List<Article> _savedArticles = [];

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    final db = Localstore.instance;
    final likedArticles =
        await db.collection('users').doc('likedArticles').get();

    if (likedArticles != null) {
      final Map<String, dynamic>? savedArticles =
          // ignore: unnecessary_cast
          likedArticles as Map<String, dynamic>?;

      if (savedArticles != null) {
        setState(() {
          _savedArticles = savedArticles.values
              .map((article) => Article.fromMap(article))
              .toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Save'),
      ),
      body: _savedArticles.isEmpty
          ? const Center(child: Text('Chưa có bài báo nào được lưu'))
          : ListView.builder(
              itemCount: _savedArticles.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailPage(news: _savedArticles[index]),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 0.0,
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          _savedArticles[index].urlToImage,
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        _savedArticles[index].title,
                        style: const TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/home');
        },
        child: const Icon(Icons.home),
      ),
    );
  }
}
