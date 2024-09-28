import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:news_app/core/constants.dart';
import 'package:news_app/data/models/article.dart';

class NewsRepository {
  final String _baseUrl = 'https://newsapi.org/v2';
  final String _apiKey = API_KEY;

  Future<List<Article>> getTopHeadlines({String category = '', int page = 1, int pageSize = 20}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/top-headlines?country=us&category=$category&page=$page&pageSize=$pageSize&apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> articles = jsonData['articles'];
      final List<Article> parsedArticles = articles.map((article) => Article.fromJson(article)).toList();
      return _updateBookmarkStatus(parsedArticles);
    } else {
      throw Exception('Failed to load news');
    }
  }

  Future<List<Article>> searchNews(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/everything?q=$query&apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> articles = jsonData['articles'];
      final List<Article> parsedArticles = articles.map((article) => Article.fromJson(article)).toList();
      return _updateBookmarkStatus(parsedArticles);
    } else {
      throw Exception('Failed to search news');
    }
  }

  Future<void> toggleBookmark(Article article) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarks') ?? [];

    if (article.isBookmarked) {
      bookmarks.remove(article.url);
    } else {
      bookmarks.add(article.url);
    }

    article.isBookmarked = !article.isBookmarked;
    await prefs.setStringList('bookmarks', bookmarks);

    // Store the full article data
    final articleData = json.encode(article.toJson());
    await prefs.setString('article_${article.url}', articleData);
  }

  Future<List<Article>> getBookmarkedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarks') ?? [];
    final List<Article> bookmarkedArticles = [];

    for (String url in bookmarks) {
      final articleData = prefs.getString('article_$url');
      if (articleData != null) {
        final article = Article.fromJson(json.decode(articleData));
        article.isBookmarked = true;
        bookmarkedArticles.add(article);
      }
    }

    return bookmarkedArticles;
  }

  Future<List<Article>> _updateBookmarkStatus(List<Article> articles) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarks') ?? [];

    for (var article in articles) {
      article.isBookmarked = bookmarks.contains(article.url);
    }

    return articles;
  }
}