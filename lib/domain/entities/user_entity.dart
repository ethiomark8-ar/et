import 'package:equatable/equatable.dart';

enum UserRole { buyer, seller, admin }

enum VerificationStatus { none, pending, approved, rejected }

class UserEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl;
  final UserRole role;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final VerificationStatus sellerVerificationStatus;
  final bool isActive;
  final String? fcmToken;
  final String language;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? businessName;
  final String? businessDescription;
  final double sellerRating;
  final int totalSales;
  final String? location;
  final List<String> wishlist;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    required this.role,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.sellerVerificationStatus = VerificationStatus.none,
    this.isActive = true,
    this.fcmToken,
    this.language = 'en',
    this.notificationsEnabled = true,
    required this.createdAt,
    this.updatedAt,
    this.businessName,
    this.businessDescription,
    this.sellerRating = 0.0,
    this.totalSales = 0,
    this.location,
    this.wishlist = const [],
  });

  bool get isBuyer => role == UserRole.buyer;
  bool get isSeller => role == UserRole.seller;
  bool get isAdmin => role == UserRole.admin;
  bool get isVerifiedSeller =>
      isSeller && sellerVerificationStatus == VerificationStatus.approved;

  UserEntity copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    UserRole? role,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    VerificationStatus? sellerVerificationStatus,
    bool? isActive,
    String? fcmToken,
    String? language,
    bool? notificationsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? businessName,
    String? businessDescription,
    double? sellerRating,
    int? totalSales,
    String? location,
    List<String>? wishlist,
  }) {
    return UserEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      sellerVerificationStatus:
          sellerVerificationStatus ?? this.sellerVerificationStatus,
      isActive: isActive ?? this.isActive,
      fcmToken: fcmToken ?? this.fcmToken,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      businessName: businessName ?? this.businessName,
      businessDescription: businessDescription ?? this.businessDescription,
      sellerRating: sellerRating ?? this.sellerRating,
      totalSales: totalSales ?? this.totalSales,
      location: location ?? this.location,
      wishlist: wishlist ?? this.wishlist,
    );
  }

  @override
  List<Object?> get props => [
        id, fullName, email, phoneNumber, avatarUrl, role,
        isEmailVerified, isPhoneVerified, sellerVerificationStatus,
        isActive, fcmToken, language, notificationsEnabled,
        createdAt, updatedAt, businessName, businessDescription,
        sellerRating, totalSales, location, wishlist,
      ];
}
