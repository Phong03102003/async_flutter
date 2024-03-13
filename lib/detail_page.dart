import 'package:async_flutter/article_model.dart'; // Assuming Article model import
import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
// ignore: library_prefixes
import 'package:html/parser.dart' as htmlParser;

import 'saved_articles_screen.dart';

class DetailPage extends StatefulWidget {
  final Article news;

  const DetailPage({Key? key, required this.news}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isLiked = false;
  String? articleContent;
  // ignore: prefer_final_fields
  List<Article> _savedArticles = []; // Danh sách các bài viết đã thích

  @override
  void initState() {
    super.initState();
    _loadLikedStatus();
    _loadArticleContent();
  }

  Future<void> _loadLikedStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLiked = prefs.getBool(widget.news.title) ?? false;
    });
  }

  Future<void> _toggleLike() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool updatedIsLiked = !isLiked;

    // Lưu trạng thái đã thích mới vào SharedPreferences
    await prefs.setBool(widget.news.title, updatedIsLiked);

    // Cập nhật trạng thái đã thích của bài viết
    setState(() {
      isLiked = updatedIsLiked;
    });

    // Hiển thị thông báo Snackbar
    final snackBar = SnackBar(
      content: Text(
          updatedIsLiked ? 'Bài viết đã được lưu' : 'Bài viết đã được xóa'),
    );
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // Cập nhật danh sách bài viết đã lưu
    if (updatedIsLiked) {
      setState(() {
        _savedArticles.add(widget.news);
      });
    } else {
      setState(() {
        _savedArticles.remove(widget.news);
      });
    }

    // Gọi hàm lưu bài viết đã thích hoặc xóa bài viết đã thích
    if (updatedIsLiked) {
      await saveArticles([widget.news]);
    } else {
      await deleteArticle(widget.news);
    }
  }

  Future<void> _loadArticleContent() async {
    try {
      final content = await fetchArticleContent(widget.news.url);
      setState(() {
        articleContent = content ?? 'Không tìm thấy nội dung bài viết!';
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error loading article content: $e');
    }
  }

  Future<String?> fetchArticleContent(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = htmlParser.parse(response.body);
        // Tìm phần tử chứa nội dung bài viết
        final element = document.querySelector(
            '.article-content'); // Thay ".article-content" bằng class hoặc id của phần tử chứa nội dung bài viết trên trang web thực tế
        if (element != null) {
          return element.text; // Trả về nội dung văn bản của phần tử
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching article: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isLiked ? Icons.download : Icons.download_rounded),
            onPressed: _toggleLike,
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child: Image.network(
                widget.news.urlToImage,
                width: double.infinity,
                height: 200.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.news.title,
                style: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                child: Text(
                  articleContent ?? 'Loading...',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SavedArticlesScreen(savedArticles: _savedArticles),
            ),
          );
        },
        child: const Icon(Icons.download),
      ),
    );
  }
}

Future<void> saveArticles(List<Article> articles) async {
  final db = Localstore.instance;
  final likedArticles = await db.collection('users').doc('likedArticles').get();

  // Kiểm tra nếu likedArticles không null và có dữ liệu, sử dụng dữ liệu từ nó, nếu không, sử dụng một map rỗng
  // ignore: prefer_if_null_operators
  final savedArticles = likedArticles != null ? likedArticles : {};

  // Lưu các bài viết mới
  for (final article in articles) {
    if (!savedArticles.containsKey(article.title)) {
      savedArticles[article.title] = article.toMap();
    }
  }

  // Chuyển đổi kiểu dữ liệu của savedArticles sang Map<String, dynamic>
  final Map<String, dynamic> savedArticlesMap =
      Map<String, dynamic>.from(savedArticles);

  await db.collection('users').doc('likedArticles').set(savedArticlesMap);
}

Future<void> deleteArticle(Article article) async {
  final db = Localstore.instance;
  final likedArticles = await db.collection('users').doc('likedArticles').get();

  if (likedArticles != null) {
    final Map<String, dynamic>? savedArticles =
        // ignore: unnecessary_cast
        likedArticles as Map<String, dynamic>?;

    if (savedArticles != null && savedArticles.containsKey(article.title)) {
      savedArticles.remove(article.title);
      await db.collection('users').doc('likedArticles').set(savedArticles);
    }
  }
}
