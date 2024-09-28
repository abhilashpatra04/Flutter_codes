import 'package:news_app/data/models/article.dart';
import 'package:news_app/data/repositories/news_repository.dart';

class GetNewsUseCase {
  final NewsRepository _newsRepository;

  GetNewsUseCase(this._newsRepository);

  Future<List<Article>> execute({String category = ''}) {
    return _newsRepository.getTopHeadlines(category: category);
  }
}