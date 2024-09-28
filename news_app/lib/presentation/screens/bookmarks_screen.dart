import 'package:flutter/material.dart';
import 'package:news_app/data/models/article.dart';
import 'package:news_app/data/repositories/news_repository.dart';
import 'package:news_app/presentation/widgets/article_list_item.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  _BookmarksScreenState createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final NewsRepository _newsRepository = NewsRepository();
  List<Article> _bookmarkedArticles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBookmarkedArticles();
  }

  void _loadBookmarkedArticles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookmarkedArticles = await _newsRepository.getBookmarkedArticles();
      setState(() {
        _bookmarkedArticles = bookmarkedArticles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load bookmarked articles: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarkedArticles.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No bookmarked articles',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _bookmarkedArticles.length,
                  itemBuilder: (context, index) {
                    return ArticleListItem(
                      article: _bookmarkedArticles[index],
                      onBookmarkToggled: () {
                        _loadBookmarkedArticles(); // Refresh the list when a bookmark is toggled
                      },
                    );
                  },
                ),
    );
  }
}