/// Функция для поиска и замены строки на новый текст, с обрезанием всего, что было до строки
///
/// text - изначальный трекст
/// searchString - строка, которую ищем
/// replaceString - строка, на которую заменяем
String nsgTrimLeft({required String text, required String searchString, required String replaceString}) {
  String textNew = text.replaceFirst(searchString, replaceString);
  int indexof = textNew.indexOf(replaceString);
  if (indexof != -1) {
    textNew = textNew.substring(indexof);
  }
  return textNew;
}
