import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../core/constants/enums.dart';

// Service provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Auth state
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authServiceProvider).authStateChanges;
});

// Current user data
final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, AsyncValue<UserModel?>>((ref) {
  return CurrentUserNotifier(ref);
});

class CurrentUserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final Ref _ref;

  CurrentUserNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final user = await _ref.read(authServiceProvider).getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.data(null);
    }
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      final user =
          await _ref.read(authServiceProvider).login(username, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loginAsVisitor() async {
    state = AsyncValue.data(UserModel.visitor());
  }

  Future<void> logout() async {
    await _ref.read(authServiceProvider).logout();
    state = const AsyncValue.data(null);
  }

  Future<void> refreshUser() async {
    try {
      final user = await _ref.read(authServiceProvider).getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e) {
      // Keep current state
    }
  }

  void setUser(UserModel user) {
    state = AsyncValue.data(user);
  }
}

// Convenience providers
final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.valueOrNull != null &&
      user.valueOrNull?.role != UserRole.visiteur;
});

final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.valueOrNull?.role.isAdmin ?? false;
});

final isVisitorProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.valueOrNull == null ||
      user.valueOrNull?.role == UserRole.visiteur;
});

final userRoleProvider = Provider<UserRole>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.valueOrNull?.role ?? UserRole.visiteur;
});

// All users stream (admin)
final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.read(authServiceProvider).getAllUsers();
});

// Users by group
final usersByGroupProvider =
    StreamProvider.family<List<UserModel>, String>((ref, groupId) {
  return ref.read(authServiceProvider).getUsersByGroup(groupId);
});
