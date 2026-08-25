// lib/services/auth_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/recipe.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;

  // Initialize auth service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _auth.authStateChanges().listen((user) async {
        if (user != null) {
          _currentUser = await _getUserData(user.uid);
        } else {
          _currentUser = null;
        }
        _isInitialized = true;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Initialize error: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Get user data from Firestore
  Future<UserModel?> _getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return UserModel(
          id: doc.id,
          name: data['name'] as String? ?? '',
          email: data['email'] as String? ?? '',
          allergies: List<String>.from(data['allergies'] as List? ?? []),
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return null;
    }
  }

  // Sign up with email and password
  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
    List<String> allergies = const [],
  }) async {
    UserCredential? userCredential;

    try {
      _isLoading = true;
      notifyListeners();

      // Step 1: Create Firebase Auth user
      debugPrint('Creating auth user...');
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create user account');
      }

      final uid = userCredential.user!.uid;
      debugPrint('Auth user created with UID: $uid');

      // Step 2: Create user document in Firestore
      debugPrint('Creating Firestore document...');
      await _firestore.collection('users').doc(uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'allergies': allergies,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Firestore document created successfully');

      // Step 3: Create and return UserModel
      final user = UserModel(
        id: uid,
        name: name.trim(),
        email: email.trim(),
        allergies: allergies,
      );

      _currentUser = user;
      notifyListeners();

      debugPrint('Sign up completed successfully');
      return user;

    } catch (e) {
      debugPrint('Sign up error: $e');

      // Rollback: Delete auth user if Firestore operation failed
      if (userCredential?.user != null) {
        try {
          await userCredential!.user!.delete();
          debugPrint('Rolled back auth user creation');
        } catch (deleteError) {
          debugPrint('Error during rollback: $deleteError');
        }
      }

      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        _currentUser = await _getUserData(userCredential.user!.uid);
        return _currentUser;
      }
      return null;
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUser = null;
    } catch (e) {
      debugPrint('Error during sign out: $e');
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  // Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      debugPrint('Password reset error: $e');
      rethrow;
    }
  }

  // Update profile
  Future<UserModel?> updateProfile({
    String? name,
    List<String>? allergies,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_currentUser == null) {
        throw Exception('No user logged in');
      }

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (allergies != null) updates['allergies'] = allergies;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(_currentUser!.id).update(updates);

        _currentUser = _currentUser!.copyWith(
          name: name ?? _currentUser!.name,
          allergies: allergies ?? _currentUser!.allergies,
        );
      }

      notifyListeners();
      return _currentUser;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Favorites CRUD
  Future<void> addFavoriteRecipe(Recipe recipe) async {
    try {
      if (_currentUser == null) throw Exception('No user logged in');
      final ref = _firestore
          .collection('users')
          .doc(_currentUser!.id)
          .collection('favorites')
          .doc(recipe.id);
      await ref.set({
        ...recipe.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Add favorite error: $e');
      rethrow;
    }
  }

  Future<void> removeFavoriteRecipe(String recipeId) async {
    try {
      if (_currentUser == null) throw Exception('No user logged in');
      final ref = _firestore
          .collection('users')
          .doc(_currentUser!.id)
          .collection('favorites')
          .doc(recipeId);
      await ref.delete();
    } catch (e) {
      debugPrint('Remove favorite error: $e');
      rethrow;
    }
  }

  Future<Set<String>> getFavoriteRecipeIds() async {
    try {
      if (_currentUser == null) throw Exception('No user logged in');
      final query = await _firestore
          .collection('users')
          .doc(_currentUser!.id)
          .collection('favorites')
          .get();
      return query.docs.map((d) => d.id).toSet();
    } catch (e) {
      debugPrint('Get favorite ids error: $e');
      return {};
    }
  }

  Stream<List<Recipe>> favoritesStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }
    final ref = _firestore
        .collection('users')
        .doc(_currentUser!.id)
        .collection('favorites')
        .orderBy('createdAt', descending: true);
    return ref.snapshots().map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        try {
          return Recipe.fromJson(data).copyWith(id: doc.id);
        } catch (_) {
          return Recipe(
            id: doc.id,
            title: (data['title'] as String?) ?? 'Favori Tarif',
            description: data['description'] as String?,
            ingredients: const [],
            instructions: const [],
          );
        }
      }).toList();
    });
  }
}
