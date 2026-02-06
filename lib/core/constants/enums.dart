import 'package:flutter/widgets.dart';

/// Enums used across the application
enum UserRole {
  adminPrincipal('admin_principal'),
  adminCoach('admin_coach'),
  adminGroupe('admin_groupe'),
  adherent('adherent'),
  visiteur('visiteur');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserRole.visiteur,
    );
  }

  bool get isAdmin =>
      this == adminPrincipal ||
      this == adminCoach ||
      this == adminGroupe;

  bool get canManageUsers => this == adminPrincipal;
  bool get canManageEvents => isAdmin;
  bool get canManagePrograms =>
      this == adminPrincipal || this == adminCoach;
  bool get canManageGroup =>
      this == adminPrincipal || this == adminGroupe;
}

enum EventType {
  race('race'),
  trail('trail'),
  training('training'),
  social('social');

  final String value;
  const EventType(this.value);

  static EventType fromString(String value) {
    return EventType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EventType.training,
    );
  }
}

enum EventStatus {
  upcoming('upcoming'),
  ongoing('ongoing'),
  completed('completed'),
  cancelled('cancelled');

  final String value;
  const EventStatus(this.value);

  static EventStatus fromString(String value) {
    return EventStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EventStatus.upcoming,
    );
  }
}

enum ParticipationRole {
  organisateur('organisateur'),
  participant('participant'),
  interested('interested');

  final String value;
  const ParticipationRole(this.value);

  static ParticipationRole fromString(String value) {
    return ParticipationRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ParticipationRole.interested,
    );
  }
}

enum MediaType {
  photo('photo'),
  video('video'),
  reel('reel');

  final String value;
  const MediaType(this.value);

  static MediaType fromString(String value) {
    return MediaType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MediaType.photo,
    );
  }
}

enum MediaTiming {
  before('before'),
  during('during'),
  after('after');

  final String value;
  const MediaTiming(this.value);

  static MediaTiming fromString(String value) {
    return MediaTiming.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MediaTiming.during,
    );
  }
}

enum NoteType {
  infoOrganisateur('info_organisateur'),
  question('question'),
  feedback('feedback'),
  general('general');

  final String value;
  const NoteType(this.value);

  static NoteType fromString(String value) {
    return NoteType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NoteType.general,
    );
  }
}

enum ClassementCriteria {
  distance('distance'),
  time('time'),
  pace('pace');

  final String value;
  const ClassementCriteria(this.value);
}

enum AppLanguage {
  fr('fr', 'Français'),
  en('en', 'English'),
  ar('ar', 'العربية'),
  tn('tn', 'تونسي');

  final String code;
  final String nativeName;
  const AppLanguage(this.code, this.nativeName);

  Locale get locale => Locale(code);
}
