import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String name;
  final String description;
  final String adminId;
  final int memberCount;
  final String color;
  final String? imageUrl;
  final String paceRange;
  final DateTime createdAt;

  const GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.adminId,
    this.memberCount = 0,
    required this.color,
    this.imageUrl,
    this.paceRange = '',
    required this.createdAt,
  });

  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      adminId: data['adminId'] ?? '',
      memberCount: data['memberCount'] ?? 0,
      color: data['color'] ?? '#1E88E5',
      imageUrl: data['imageUrl'],
      paceRange: data['paceRange'] ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'adminId': adminId,
      'memberCount': memberCount,
      'color': color,
      'imageUrl': imageUrl,
      'paceRange': paceRange,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  GroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? adminId,
    int? memberCount,
    String? color,
    String? imageUrl,
    String? paceRange,
    DateTime? createdAt,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      adminId: adminId ?? this.adminId,
      memberCount: memberCount ?? this.memberCount,
      color: color ?? this.color,
      imageUrl: imageUrl ?? this.imageUrl,
      paceRange: paceRange ?? this.paceRange,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
