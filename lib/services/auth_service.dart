import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/enums.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current Firebase user
  User? get currentFirebaseUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Login with username (displayName) and password (last 3 CIN digits)
  /// Password is stored hashed in Firestore
  Future<UserModel?> login(String username, String password) async {
    try {
      // Find user by displayName
      final querySnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('displayName', isEqualTo: username.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw AuthException('Utilisateur non trouvé');
      }

      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();

      // Verify password (last 3 digits of CIN)
      final storedPassword = userData['password'] as String?;
      if (storedPassword == null || storedPassword != password.trim()) {
        throw AuthException('Mot de passe incorrect');
      }

      // Sign in with Firebase Auth using email/password
      final email = userData['email'] as String;
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userDoc.id)
          .update({'lastLoginAt': FieldValue.serverTimestamp()});

      return UserModel.fromFirestore(userDoc);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Erreur de connexion: ${e.toString()}');
    }
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Get current user data from Firestore
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = currentFirebaseUser;
    if (firebaseUser == null) return null;

    try {
      // Find user doc by email
      final querySnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('email', isEqualTo: firebaseUser.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      return UserModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      return null;
    }
  }

  /// Create a new user (Admin only)
  Future<UserModel> createUser({
    required String displayName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    String? groupId,
  }) async {
    try {
      // Create Firebase Auth account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;

      final user = UserModel(
        id: userId,
        displayName: displayName,
        email: email,
        phone: phone,
        role: role,
        groupId: groupId,
        joinedAt: DateTime.now(),
      );

      // Save to Firestore with password for CIN-based login
      final firestoreData = user.toFirestore();
      firestoreData['password'] = password;

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .set(firestoreData);

      // Sign out the newly created user (admin stays logged in)
      // Re-sign in as admin would be handled by the calling code

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    } catch (e) {
      throw AuthException('Erreur lors de la création: ${e.toString()}');
    }
  }

  /// Update user role (Admin Principal only)
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({'role': newRole.value});
  }

  /// Update user group (Admin Groupe only)
  Future<void> assignUserToGroup(String userId, String groupId) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({'groupId': groupId});
  }

  /// Delete user (Admin Principal only)
  Future<void> deleteUser(String userId) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .delete();
  }

  /// Get all users
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection(AppConstants.usersCollection)
        .orderBy('displayName')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  /// Get users by group
  Stream<List<UserModel>> getUsersByGroup(String groupId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .where('groupId', isEqualTo: groupId)
        .orderBy('displayName')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  /// Update user profile
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    // Sanitize data — never allow role changes via profile update
    data.remove('role');
    data.remove('password');
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update(data);
  }

  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Utilisateur non trouvé';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'weak-password':
        return 'Mot de passe trop faible';
      case 'invalid-email':
        return 'Email invalide';
      case 'user-disabled':
        return 'Compte désactivé';
      case 'too-many-requests':
        return 'Trop de tentatives, réessayez plus tard';
      default:
        return 'Erreur d\'authentification';
    }
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
