/// Converts legal page HTML from the web into markdown for in-app rendering.
String extractLegalContent(String html) {
  var content = html;
  content = content.replaceAll(
    RegExp(r'<script[^>]*>[\s\S]*?</script>', caseSensitive: false),
    '',
  );
  content = content.replaceAll(
    RegExp(r'<style[^>]*>[\s\S]*?</style>', caseSensitive: false),
    '',
  );
  content = content.replaceAll(
    RegExp(r'<nav[^>]*>[\s\S]*?</nav>', caseSensitive: false),
    '',
  );
  content = content.replaceAll(
    RegExp(r'<header[^>]*>[\s\S]*?</header>', caseSensitive: false),
    '',
  );
  content = content.replaceAll(
    RegExp(r'<footer[^>]*>[\s\S]*?</footer>', caseSensitive: false),
    '',
  );

  final h1Match =
      RegExp(r'<h1[^>]*>(.*?)</h1>', caseSensitive: false).firstMatch(content);
  if (h1Match != null) {
    content = content.substring(h1Match.start);
  }

  content = content.replaceAllMapped(
    RegExp(r'<h1[^>]*>(.*?)</h1>', caseSensitive: false),
    (m) => '# ${_stripTags(m.group(1) ?? '')}\n\n',
  );
  content = content.replaceAllMapped(
    RegExp(r'<h2[^>]*>(.*?)</h2>', caseSensitive: false),
    (m) => '## ${_stripTags(m.group(1) ?? '')}\n\n',
  );
  content = content.replaceAllMapped(
    RegExp(r'<h3[^>]*>(.*?)</h3>', caseSensitive: false),
    (m) => '### ${_stripTags(m.group(1) ?? '')}\n\n',
  );
  content = content.replaceAllMapped(
    RegExp(r'<h4[^>]*>(.*?)</h4>', caseSensitive: false),
    (m) => '#### ${_stripTags(m.group(1) ?? '')}\n\n',
  );

  content = content.replaceAllMapped(
    RegExp(r'<li[^>]*>(.*?)</li>', caseSensitive: false, dotAll: true),
    (m) => '- ${_stripTags(m.group(1) ?? '').trim()}\n',
  );

  content = content.replaceAllMapped(
    RegExp(r'<p[^>]*>(.*?)</p>', caseSensitive: false, dotAll: true),
    (m) => '${_stripTags(m.group(1) ?? '').trim()}\n\n',
  );

  content = content.replaceAllMapped(
    RegExp(
      r'<(?:strong|b)[^>]*>(.*?)</(?:strong|b)>',
      caseSensitive: false,
    ),
    (m) => '**${m.group(1)}**',
  );

  content = content.replaceAll(RegExp(r'<[^>]+>'), '');
  content = content.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  content = content.trim();

  content = content.replaceFirst(RegExp(r'^# .*\n\n'), '');
  content = content.replaceFirst(RegExp(r'버전:[\s\S]*?(?=##|$)'), '');

  content = content.replaceAll(RegExp(r'←?\s*홈으로.*', multiLine: true), '');
  content = content.replaceAll(RegExp(r'← 홈으로'), '');
  content = content.replaceAll(RegExp(r'홈으로 돌아가기.*', multiLine: true), '');

  content = content.replaceAll(
    'trendsoccer.com',
    '[trendsoccer.com](https://trendsoccer.com)',
  );
  content = content.replaceAll(
    'trikilab2025@gmail.com',
    '[trikilab2025@gmail.com](mailto:trikilab2025@gmail.com)',
  );

  return content.trim();
}

String _stripTags(String html) {
  return html.replaceAll(RegExp(r'<[^>]+>'), '').trim();
}
