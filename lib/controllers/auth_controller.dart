import 'package:chat_app/models/user_models.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool isloading = false;
  String errorMessage = '';

  //geter
  UserModel? get currentUser => _currentUser;
  bool get isLoading => isloading;
  String get Errormessage => errorMessage;

  //Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    isloading = true;
    errorMessage = '';
    notifyListeners();

    UserModel? user = await _authService.resgister(
      name: name,
      email: email,
      password: password,
    );

    if (user != null) {
      _currentUser = user;
      isloading = false;
      notifyListeners();
      return true;
    } else {
      errorMessage = 'Registration failed , Please try again';
      isloading = false;
      notifyListeners();
      return false;
    }
  }

  //Login
  Future<bool> login({required String email, required String password}) async {
    isloading = true;
    errorMessage = '';
    notifyListeners();

    UserModel? user = await _authService.login(
      email: email,
      password: password,
    );

    if (user != null) {
      _currentUser = user;
      isloading = false;
      errorMessage = '';
      notifyListeners();
      return true;
    } else {
      isloading = false;
      errorMessage = 'Login failed , Please Try Again';
      notifyListeners();
      return false;
    }
  }

  //Logout
  Future<void> Logout() async {
    await _authService.Logout();
    _currentUser = null;
    notifyListeners();
  }

  void setCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  //set online
  Future<void> setOnline() async {
    if (_currentUser != null) {
      await _authService.userOnline(_currentUser!.usid);
    }
  }

  //set offline
  Future<void> setOffline() async {
    if (_currentUser != null) {
      await _authService.userOffline(_currentUser!.usid);
    }
  }
}
