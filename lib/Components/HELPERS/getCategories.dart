import '../OTHER/API/item_add.dart' as API;

class GetCategories {
  static Future<List<String>> fetchCategories() async {
    List<dynamic> categorieData = await API.getCategories();
    List<String> categories = categorieData.map((category) => category['category'] as String).toList();

    categories.add("Default");
    categories.add("Freezer");

    return categories;
  }
}
