/// Formats single-block analysis text with paragraph breaks for readability.
String formatAnalysisText(String text) {
  if (text.isEmpty) return text;

  final breakPatterns = [
    'The key differentiator',
    'Watch whether',
    r'The .+ offense',
    r'The .+ will need',
    'Overall,',
    'In conclusion,',
    'Looking at',
    'On the other hand',
    'However,',
    'Meanwhile,',
    '핵심은',
    '주목할',
    '전체적으로',
    '결론적으로',
    '반면',
  ];

  var result = text;
  for (final pattern in breakPatterns) {
    result = result.replaceAllMapped(
      RegExp('(?<=[.!?])\\s+($pattern)', caseSensitive: false),
      (match) => '\n\n${match.group(1)}',
    );
  }

  if (!result.contains('\n\n')) {
    final sentences = result.split(RegExp(r'(?<=\.)\s+'));
    if (sentences.length > 3) {
      final buffer = StringBuffer();
      for (var i = 0; i < sentences.length; i++) {
        buffer.write(sentences[i]);
        if (i < sentences.length - 1) {
          buffer.write((i + 1) % 3 == 0 ? '\n\n' : ' ');
        }
      }
      result = buffer.toString();
    }
  }

  return result.trim();
}
