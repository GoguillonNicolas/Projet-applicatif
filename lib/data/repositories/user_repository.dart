import '../database_helper.dart';
import '../user.dart';

class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<UserAccount?> register(String username, String email, String password) {
    return _dbHelper.registerUser(username, email, password);
  }

  Future<UserAccount?> login(String email, String password) {
    return _dbHelper.loginUser(email, password);
  }
}
