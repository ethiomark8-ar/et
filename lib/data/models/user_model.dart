import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.phoneNumber,
    super.avatarUrl,
    required super.role,
    super.isEmailVerified,
    super.isPhoneVerified,
    super.sellerVerificationStatus,
    super.isActive,
    super.fcmToken,
    super.language,
    super.notificationsEnabled,
    required super.createdAt,
    super.updatedAt,
    super.businessName,
    super.businessDescription,
    super.sellerRating,
    super.totalSales,
    super.location,
    super.wishlist,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data, doc.id);
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      role: _parseRole(map['role'] as String?),
      isEmailVerified: map['isEmailVerified'] as bool? ?? false,
      isPhoneVerified: map['isPhoneVerified'] as bool? ?? false,
      sellerVerificationStatus:
          _parseVerificationStatus(map['sellerVerificationStatus'] as String?),
      isActive: map['isActive'] as bool? ?? true,
      fcmToken: map['fcmToken'] as String?,
      language: map['language'] as String? ?? 'en',
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? _parseTimestamp(map['updatedAt']) : null,
      businessName: map['businessName'] as String?,
      businessDescription: map['businessDescription'] as String?,
      sellerRating: _parseDouble(map['sellerRating']),
      totalSales: map['totalSales'] as int? ?? 0,
      location: map['location'] as String?,
      wishlist: List<String>.from(map['wishlist'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'sellerVerificationStatus': sellerVerificationStatus.name,
      'isActive': isActive,
      'fcmToken': fcmToken,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'businessName': businessName,
      'businessDescription': businessDescription,
      'sellerRating': sellerRating,
      'totalSales': totalSales,
      'location': location,
      'wishlist': wishlist,
    };
  }

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'seller':
        return UserRole.seller;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.buyer;
    }
  }

  static VerificationStatus _parseVerificationStatus(String? status) {
    switch (status) {
      case 'pending':
        return VerificationStatus.pending;
      case 'approved':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.none;
    }
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return 0.0;
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      avatarUrl: entity.avatarUrl,
      role: entity.role,
      isEmailVerified: entity.isEmailVerified,
      isPhoneVerified: entity.isPhoneVerified,
      sellerVerificationStatus: entity.sellerVerificationStatus,
      isActive: entity.isActive,
      fcmToken: entity.fcmToken,
      language: entity.language,
      notificationsEnabled: entity.notificationsEnabled,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      businessName: entity.businessName,
      businessDescription: entity.businessDescription,
      sellerRating: entity.sellerRating,
      totalSales: entity.totalSales,
      location: entity.location,
      wishlist: entity.wishlist,
    );
  }
}
