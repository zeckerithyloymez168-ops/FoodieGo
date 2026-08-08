import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/address.dart';
import '../services/firebase_bootstrap.dart';
import '../services/user_repository.dart';

/// Result of an auth action with a user-facing message.
class AuthResult {
  const AuthResult({required this.success, this.message});

  final bool success;
  final String? message;

  factory AuthResult.ok([String? message]) =>
      AuthResult(success: true, message: message);

  factory AuthResult.fail(String message) =>
      AuthResult(success: false, message: message);
}

class AuthProvider extends ChangeNotifier {
  AuthProvider({UserRepository? users}) : _users = users ?? UserRepository() {
    _listenAuth();
  }

  final UserRepository _users;

  bool _isLoggedIn = false;
  bool _isGuest = false;
  bool _initializing = true;
  String? _uid;
  String _name = '';
  String _email = '';
  String _phone = '';
  final List<Address> _addresses = [];

  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;
  bool get canUseApp => _isLoggedIn || _isGuest;
  bool get firebaseAuthReady => FirebaseBootstrap.isReady;
  bool get initializing => _initializing;
  String? get uid => _uid;
  String get name => _name.isEmpty ? 'FoodieGo User' : _name;
  String get email => _email;
  String get phone => _phone;
  List<Address> get addresses => List.unmodifiable(_addresses);

  Address? get defaultAddress {
    if (_addresses.isEmpty) return null;
    return _addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => _addresses.first,
    );
  }

  void _listenAuth() {
    if (!FirebaseBootstrap.isReady) {
      _initializing = false;
      return;
    }
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        await _applyFirebaseUser(user);
      } else if (!_isGuest) {
        _clearSession();
      }
      _initializing = false;
      notifyListeners();
    });
  }

  Future<void> _applyFirebaseUser(User user) async {
    _uid = user.uid;
    _email = user.email ?? '';
    _name = (user.displayName?.trim().isNotEmpty == true)
        ? user.displayName!.trim()
        : (_email.contains('@') ? _email.split('@').first : 'User');
    if (_name.isNotEmpty) {
      _name = _name[0].toUpperCase() + (_name.length > 1 ? _name.substring(1) : '');
    }
    _isLoggedIn = true;
    _isGuest = false;
    await _users.upsertProfile(
      uid: user.uid,
      name: _name,
      email: _email,
      phone: _phone.isEmpty ? null : _phone,
    );
    await _loadRemoteAddresses();
  }

  void _clearSession() {
    _isLoggedIn = false;
    _isGuest = false;
    _uid = null;
    _name = '';
    _email = '';
    // keep addresses empty for real accounts until load
  }

  static String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'user-not-found':
        return 'No account found with this email. Create one first.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Try again.';
      case 'email-already-in-use':
        return 'This email is already registered. Sign in instead.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'operation-not-allowed':
        return 'Email sign-in is not enabled. Check Firebase Auth settings.';
      case 'requires-recent-login':
        return 'Please sign in again to continue.';
      default:
        return e.message?.isNotEmpty == true
            ? e.message!
            : 'Authentication failed (${e.code}).';
    }
  }

  Future<AuthResult> login(String email, String password) async {
    final e = email.trim();
    final p = password;
    if (e.isEmpty || !e.contains('@')) {
      return AuthResult.fail('Enter a valid email address.');
    }
    if (p.length < 6) {
      return AuthResult.fail('Password must be at least 6 characters.');
    }

    if (!FirebaseBootstrap.isReady) {
      return AuthResult.fail(
        'Firebase is not connected. Check your network and try again.',
      );
    }

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: e,
        password: p,
      );
      if (cred.user == null) {
        return AuthResult.fail('Sign in failed. Please try again.');
      }
      await _applyFirebaseUser(cred.user!);
      notifyListeners();
      return AuthResult.ok('Welcome back!');
    } on FirebaseAuthException catch (ex) {
      debugPrint('Auth login: ${ex.code} ${ex.message}');
      return AuthResult.fail(_mapAuthError(ex));
    } catch (ex) {
      debugPrint('Auth login error: $ex');
      return AuthResult.fail('Something went wrong. Please try again.');
    }
  }

  Future<AuthResult> register(
    String name,
    String email,
    String password, {
    String? phone,
  }) async {
    final n = name.trim();
    final e = email.trim();
    final p = password;
    if (n.length < 2) return AuthResult.fail('Enter your full name.');
    if (!e.contains('@')) return AuthResult.fail('Enter a valid email address.');
    if (p.length < 6) {
      return AuthResult.fail('Password must be at least 6 characters.');
    }

    if (!FirebaseBootstrap.isReady) {
      return AuthResult.fail(
        'Firebase is not connected. Check your network and try again.',
      );
    }

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: e,
        password: p,
      );
      final user = cred.user;
      if (user == null) {
        return AuthResult.fail('Could not create account. Try again.');
      }
      await user.updateDisplayName(n);
      if (phone != null && phone.trim().isNotEmpty) {
        _phone = phone.trim();
      }
      await user.reload();
      final refreshed = FirebaseAuth.instance.currentUser ?? user;
      await _applyFirebaseUser(refreshed);
      _name = n;
      notifyListeners();
      return AuthResult.ok('Account created successfully.');
    } on FirebaseAuthException catch (ex) {
      debugPrint('Auth register: ${ex.code} ${ex.message}');
      return AuthResult.fail(_mapAuthError(ex));
    } catch (ex) {
      debugPrint('Auth register error: $ex');
      return AuthResult.fail('Something went wrong. Please try again.');
    }
  }

  Future<AuthResult> sendPasswordReset(String email) async {
    final e = email.trim();
    if (!e.contains('@')) {
      return AuthResult.fail('Enter the email for your account.');
    }
    if (!FirebaseBootstrap.isReady) {
      return AuthResult.fail('Firebase is not connected.');
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: e);
      return AuthResult.ok(
        'Password reset email sent to $e. Check your inbox.',
      );
    } on FirebaseAuthException catch (ex) {
      return AuthResult.fail(_mapAuthError(ex));
    } catch (_) {
      return AuthResult.fail('Could not send reset email. Try again.');
    }
  }

  void continueAsGuest() {
    _isGuest = true;
    _isLoggedIn = false;
    _uid = 'guest';
    _name = 'Guest';
    _email = '';
    _phone = '';
    _addresses
      ..clear()
      ..add(
        const Address(
          id: 'guest-home',
          label: 'Home',
          line1: 'Add your address in Profile',
          city: 'Your city',
          phone: '',
          isDefault: true,
        ),
      );
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    if (name != null && name.trim().isNotEmpty) _name = name.trim();
    if (email != null && email.trim().isNotEmpty) _email = email.trim();
    if (phone != null && phone.trim().isNotEmpty) _phone = phone.trim();
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        if (name != null && name.trim().isNotEmpty) {
          await user.updateDisplayName(name.trim());
        }
      } catch (e) {
        debugPrint('updateDisplayName: $e');
      }
    }

    if (_uid != null &&
        _uid != 'guest' &&
        FirebaseBootstrap.isReady) {
      await _users.upsertProfile(
        uid: _uid!,
        name: _name,
        email: _email,
        phone: _phone,
      );
    }
  }

  Future<void> addAddress(Address address) async {
    if (address.isDefault) {
      for (var i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
    _addresses.add(address);
    notifyListeners();
    if (_uid != null && _uid != 'guest' && FirebaseBootstrap.isReady) {
      await _users.saveAddress(_uid!, address);
    }
  }

  void setDefaultAddress(String id) {
    for (var i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(isDefault: _addresses[i].id == id);
    }
    notifyListeners();
    if (_uid != null && _uid != 'guest' && FirebaseBootstrap.isReady) {
      for (final a in _addresses) {
        _users.saveAddress(_uid!, a);
      }
    }
  }

  void removeAddress(String id) {
    _addresses.removeWhere((a) => a.id == id);
    if (_addresses.isNotEmpty && !_addresses.any((a) => a.isDefault)) {
      _addresses[0] = _addresses[0].copyWith(isDefault: true);
    }
    notifyListeners();
  }

  Future<void> _loadRemoteAddresses() async {
    if (_uid == null || !FirebaseBootstrap.isReady) return;
    final remote = await _users.fetchAddresses(_uid!);
    if (remote.isNotEmpty) {
      _addresses
        ..clear()
        ..addAll(remote);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (FirebaseBootstrap.isReady) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
    }
    _isLoggedIn = false;
    _isGuest = false;
    _uid = null;
    _name = '';
    _email = '';
    _phone = '';
    _addresses.clear();
    notifyListeners();
  }
}
