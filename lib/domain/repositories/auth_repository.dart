import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Stream of the currently authenticated user
  Stream<UserEntity?> get authStateChanges;

  /// Get the currently authenticated user
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Sign in with email and password
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Register with email and password
  Future<Either<Failure, UserEntity>> registerWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required UserRole role,
  });

  /// Sign in with Google
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// Send email verification
  Future<Either<Failure, void>> sendEmailVerification();

  /// Update FCM token
  Future<Either<Failure, void>> updateFcmToken(String token);

  /// Delete account
  Future<Either<Failure, void>> deleteAccount();

  /// Reload user
  Future<Either<Failure, UserEntity>> reloadUser();
}
