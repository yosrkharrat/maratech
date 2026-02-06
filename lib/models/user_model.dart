import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/enums.dart';

class UserModel {
  final String id;
  final String displayName;
  final String email;
  final String phone;
  final UserRole role;
  final String? groupId;
  final String? profilePhotoUrl;
  final bool stravaConnected;
  final String? stravaAthleteId;
  final Map<String, dynamic>? stravaTokens;
  final bool notificationsEnabled;
  final AccessibilityPrefs accessibilityPrefs;
  final DateTime joinedAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.role,
    this.groupId,
    this.profilePhotoUrl,
    this.stravaConnected = false,
    this.stravaAthleteId,
    this.stravaTokens,
    this.notificationsEnabled = true,
    this.accessibilityPrefs = const AccessibilityPrefs(),
    required this.joinedAt,
    this.lastLoginAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: UserRole.fromString(data['role'] ?? 'visiteur'),
      groupId: data['groupId'],
      profilePhotoUrl: data['profilePhotoUrl'],
      stravaConnected: data['stravaConnected'] ?? false,
      stravaAthleteId: data['stravaAthleteId'],
      stravaTokens: data['stravaTokens'],
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      accessibilityPrefs: data['accessibilityPrefs'] != null
          ? AccessibilityPrefs.fromMap(data['accessibilityPrefs'])
          : const AccessibilityPrefs(),
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'role': role.value,
      'groupId': groupId,
      'profilePhotoUrl': profilePhotoUrl,
      'stravaConnected': stravaConnected,
      'stravaAthleteId': stravaAthleteId,
      'stravaTokens': stravaTokens,
      'notificationsEnabled': notificationsEnabled,
      'accessibilityPrefs': accessibilityPrefs.toMap(),
      'joinedAt': Timestamp.fromDate(joinedAt),
      'lastLoginAt':
          lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  UserModel copyWith({
    String? id,
    String? displayName,
    String? email,
    String? phone,
    UserRole? role,
    String? groupId,
    String? profilePhotoUrl,
    bool? stravaConnected,
    String? stravaAthleteId,
    Map<String, dynamic>? stravaTokens,
    bool? notificationsEnabled,
    AccessibilityPrefs? accessibilityPrefs,
    DateTime? joinedAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      groupId: groupId ?? this.groupId,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      stravaConnected: stravaConnected ?? this.stravaConnected,
      stravaAthleteId: stravaAthleteId ?? this.stravaAthleteId,
      stravaTokens: stravaTokens ?? this.stravaTokens,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      accessibilityPrefs: accessibilityPrefs ?? this.accessibilityPrefs,
      joinedAt: joinedAt ?? this.joinedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// Check if user is a visitor (not authenticated)
  static UserModel visitor() {
    return UserModel(
      id: 'visitor',
      displayName: 'Visiteur',
      email: '',
      phone: '',
      role: UserRole.visiteur,
      joinedAt: DateTime.now(),
    );
  }
}

class AccessibilityPrefs {
  final String fontSize;
  final bool highContrast;
  final bool screenReader;
  final bool colorInversion;

  const AccessibilityPrefs({
    this.fontSize = 'normal',
    this.highContrast = false,
    this.screenReader = false,
    this.colorInversion = false,
  });

  factory AccessibilityPrefs.fromMap(Map<String, dynamic> map) {
    return AccessibilityPrefs(
      fontSize: map['fontSize'] ?? 'normal',
      highContrast: map['highContrast'] ?? false,
      screenReader: map['screenReader'] ?? false,
      colorInversion: map['colorInversion'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fontSize': fontSize,
      'highContrast': highContrast,
      'screenReader': screenReader,
      'colorInversion': colorInversion,
    };
  }
}
