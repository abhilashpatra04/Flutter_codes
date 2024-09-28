import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:news_app/core/constants.dart';
import 'package:news_app/data/models/article.dart';

class NewsApiService {
  final String _baseUrl = 'https://newsapi.org/v2';
  final String _apiKey = API_KEY;

  Future<List<Article>> getTopHeadlines({String category = ''}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/top-headlines?country=us&category=$category&apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> articles = jsonData['articles'];
      return articles.map((article) => Article.fromJson(article)).toList();
    } else {
      throw Exception('Failed to load news');
    }
  }
}