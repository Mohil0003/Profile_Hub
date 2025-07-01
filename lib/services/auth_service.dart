import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../database/database_helper.dart';
import '../models/user.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  Future<User?> login(String email, String password) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      if (result.isNotEmpty) {
        return User.fromMap(result.first);
      }
      return null;
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  Future<User?> signup(User user) async {
    try {
      final db = await _dbHelper.database;
      
      // Check if email already exists
      final existingUser = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [user.email],
      );

      if (existingUser.isNotEmpty) {
        return null;
      }

      final id = await db.insert('users', user.toMap());
      return user.copyWith(id: id);
    } catch (e) {
      print('Error during signup: $e');
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // Get user details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final userEmail = googleUser.email;
      final userName = googleUser.displayName ?? '';
      
      // Check if user exists in local database
      final db = await _dbHelper.database;
      final result = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [userEmail],
      );

      if (result.isEmpty) {
        // Create new user
        final newUser = User(
          name: userName,
          email: userEmail,
          password: '', // No password for Google auth
          phone: '',
          birthdate: DateTime.now(),
          gender: 'Male',
          city: 'New York',
          hobbies: [],
          isFavorite: false,
        );

        final id = await db.insert('users', newUser.toMap());
        return newUser.copyWith(id: id);
      } else {
        // Return existing user
        return User.fromMap(result.first);
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
} 