import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app/data/models/article.dart';
import 'package:news_app/presentation/screens/article_detail_screen.dart';
import 'package:news_app/data/repositories/news_repository.dart';
import 'package:intl/intl.dart';

class ArticleListItem extends StatefulWidget {
  final Article article;
  final VoidCallback? onBookmarkToggled;

  const ArticleListItem({
    super.key,
    required this.article,
    this.onBookmarkToggled,
  });

  @override
  _ArticleListItemState createState() => _ArticleListItemState();
}

class _ArticleListItemState extends State<ArticleListItem> {
  final NewsRepository _newsRepository = NewsRepository();

  void _toggleBookmark() async {
    await _newsRepository.toggleBookmark(widget.article);
    setState(() {});
    widget.onBookmarkToggled?.call();
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final formatter = DateFormat.yMMMd();
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    CachedNetworkImage(
      imageUrl: widget.article.urlToImage,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
      height: 200,
      color: Colors.grey[300],
      child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
      height: 200,
      color: Colors.grey[300],
      child: Icon(Icons.error, size: 64, color: Colors.grey[400]),
      ),
    );
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleDetailScreen(article: widget.article),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: widget.article.urlToImage.isNotEmpty
                  ? Image.network(
                      widget.article.urlToImage,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: Icon(Icons.image, size: 64, color: Colors.grey[400]),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.article.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(widget.article.publishedAt),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      IconButton(
                        icon: Icon(
                          widget.article.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: widget.article.isBookmarked ? Theme.of(context).colorScheme.primary : Colors.grey,
                        ),
                        onPressed: _toggleBookmark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}