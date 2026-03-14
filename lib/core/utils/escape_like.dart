/// LIKE/ILIKE 패턴에서 특수문자를 이스케이프합니다.
String escapeLike(String value) {
  return value
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
}
