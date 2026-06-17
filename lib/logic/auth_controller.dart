import 'package:flutter/foundation.dart';
import '../data/repositories/user_repository.dart';
import '../data/user.dart';

class AuthController extends ChangeNotifier {
  final UserRepository _userRepository;
  UserAccount? _currentUser;
  bool _isLoading = false;

  AuthController({UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository();

  UserAccount? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _userRepository.login(email, password);
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Log error
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _userRepository.register(username, email, password);
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Log error
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
