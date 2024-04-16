import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class User {
  User({
    required this.email,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] as String,
    );
  }
  final String email;
}

final authProvider =
    NotifierProvider<AuthNotifier, AsyncValue<User?>>(AuthNotifier.new);

class AuthNotifier extends Notifier<AsyncValue<User?>> {
  @override
  AsyncValue<User?> build() => const AsyncValue.data(null);

  FutureOr<User> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8080/user'),
      headers: {
        'alg': 'HS256',
        'typ': 'JWT',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'token': token}),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return User.fromJson(json);
  }

  FutureOr<bool> register(String email, String password) async {
    state = const AsyncValue.loading();
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8080/register'),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 201) {
      state = const AsyncValue.error(
        'Could not resist your data.',
        StackTrace.empty,
      );
      return false;
    }

    return await login(email, password);
  }

  FutureOr<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8080/login'),
      headers: {
        'alg': 'HS256',
        'typ': 'JWT',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode != 200) {
      state = const AsyncValue.error(
        'failed to log in',
        StackTrace.empty,
      );
      return false;
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final token = json['token'] as String;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);

    state = AsyncValue.data(User(email: email));
    return true;
  }

  FutureOr<void> logout() async {
    state = const AsyncValue.loading();

    final prefs = await SharedPreferences.getInstance();
    if (await prefs.remove('token')) {
      state = const AsyncValue.data(null);
    }

    state = AsyncValue.data(state.value);
  }
}
