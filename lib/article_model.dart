// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Article {
  String title;
  String urlToImage;
  String content;
  String url;

  Article({
    required this.title,
    required this.urlToImage,
    required this.content,
    required this.url,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'urlToImage': urlToImage,
      'content': content,
      'url': url,
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      title: map['title'] as String,
      urlToImage: map['urlToImage'] as String,
      content: map['content'] as String,
      url: map['url'] as String,
    );
  }

  Article copyWith({
    String? title,
    String? urlToImage,
    String? content,
    String? url,
  }) {
    return Article(
      title: title ?? this.title,
      urlToImage: urlToImage ?? this.urlToImage,
      content: content ?? this.content,
      url: url ?? this.url,
    );
  }

  String toJson() => json.encode(toMap());

  factory Article.fromJson(String source) =>
      Article.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Article(title: $title, urlToImage: $urlToImage, content: $content, url: $url)';
  }

  @override
  bool operator ==(covariant Article other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.urlToImage == urlToImage &&
        other.content == content &&
        other.url == url;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        urlToImage.hashCode ^
        content.hashCode ^
        url.hashCode;
  }
}
