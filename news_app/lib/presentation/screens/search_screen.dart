import 'package:flutter/material.dart';
import 'package:news_app/data/models/article.dart';
import 'package:news_app/data/repositories/news_repository.dart';
import 'package:news_app/presentation/widgets/article_list_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final NewsRepository _newsRepository = NewsRepository();
  List<Article> _searchResults = [];
  bool _isLoading = false;

  void _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _newsRepository.searchNews(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to search news: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search News'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search news...',
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: _performSearch,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      return ArticleListItem(article: _searchResults[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}