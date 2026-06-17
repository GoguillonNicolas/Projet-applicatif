import '../database_helper.dart';
import '../product.dart';

class ProductRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Product>> getAllProducts() {
    return _dbHelper.getProducts();
  }

  Future<List<Product>> search(String query) {
    return _dbHelper.searchProducts(query);
  }
}
