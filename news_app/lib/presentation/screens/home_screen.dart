import 'package:flutter/material.dart';
import 'package:news_app/data/models/article.dart';
import 'package:news_app/data/repositories/news_repository.dart';
import 'package:news_app/presentation/widgets/article_list_item.dart';
import 'package:news_app/presentation/widgets/category_filter.dart';
import 'package:news_app/presentation/screens/search_screen.dart';
import 'package:news_app/presentation/screens/bookmarks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NewsRepository _newsRepository = NewsRepository();
  List<Article> _articles = [];
  bool _isLoading = false;
  String _selectedCategory = '';
  int _currentPage = 1;
  bool _hasMoreArticles = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchNews();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMoreArticles) {
        _fetchNews(page: _currentPage + 1);
      }
    }
  }

  Future<void> _fetchNews({int page = 1}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final articles = await _newsRepository.getTopHeadlines(category: _selectedCategory, page: page);
      setState(() {
        if (page == 1) {
          _articles = articles;
        } else {
          _articles.addAll(articles);
        }
        _currentPage = page;
        _isLoading = false;
        _hasMoreArticles = articles.isNotEmpty;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load news: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News App', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookmarksScreen()),
              ).then((_) => _fetchNews()); // Refresh the list when returning from BookmarksScreen
            },
          ),
        ],
      ),
      body: Column(
        children: [
          CategoryFilter(
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
                _currentPage = 1;
                _hasMoreArticles = true;
              });
              _fetchNews();
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _fetchNews(page: 1),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _articles.length + (_hasMoreArticles ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _articles.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ArticleListItem(
                    article: _articles[index],
                    onBookmarkToggled: () {
                      setState(() {});
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}