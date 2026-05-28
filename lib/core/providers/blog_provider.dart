import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/services/blog_service.dart';
import 'package:trendsoccer/core/utils/legal_content_parser.dart';

final blogPostsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(blogServiceProvider);
  return service.getBlogPosts(limit: 20, offset: 0);
});

final blogPostDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, slug) async {
  final service = ref.read(blogServiceProvider);
  return service.getBlogPost(slug);
});

Future<String> _loadLegalMarkdown(
  BlogService service,
  String type,
  String label,
) async {
  final html = await service.fetchLegalContent(type);
  if (html.isEmpty) {
    throw Exception('Failed to fetch $label');
  }

  final content = extractLegalContent(html);
  if (content.isEmpty) {
    throw Exception('Failed to parse $label');
  }

  final previewLen = min(100, content.length);
  print(
    '[LEGAL] $type content: ${content.length} chars, '
    'first 100: ${content.substring(0, previewLen)}',
  );
  return content;
}

final privacyContentProvider = FutureProvider<String>((ref) async {
  final service = ref.read(blogServiceProvider);
  return _loadLegalMarkdown(service, 'privacy', 'privacy policy');
});

final termsContentProvider = FutureProvider<String>((ref) async {
  final service = ref.read(blogServiceProvider);
  return _loadLegalMarkdown(service, 'terms', 'terms of service');
});
