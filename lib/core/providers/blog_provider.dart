import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/services/blog_service.dart';

final blogPostsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(blogServiceProvider);
  return service.getBlogPosts(limit: 20, offset: 0);
});

final blogPostDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, slug) async {
  final service = ref.read(blogServiceProvider);
  return service.getBlogPost(slug);
});
