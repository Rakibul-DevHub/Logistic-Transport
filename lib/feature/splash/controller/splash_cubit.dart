import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/network/secure_storage_service.dart';
import '../../../core/network/network_caller_dio.dart';
import '../../../core/utils/app_url.dart';

// ============ States ============
abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashNavigate extends SplashState {
  final String routeName;
  final Map<String, dynamic>? arguments;

  const SplashNavigate({
    required this.routeName,
    this.arguments,
  });

  @override
  List<Object?> get props => [routeName, arguments];
}

// ============ Events ============
abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

class SplashStarted extends SplashEvent {}

// ============ Cubit ============
class SplashCubit extends Cubit<SplashState> {
  final SecureStorageService _storage = SecureStorageService.instance;
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  SplashCubit() : super(SplashInitial());

  // Configuration
  static const Duration _splashDuration = Duration(seconds: 2);
  static const Duration _minLoadTime = Duration(milliseconds: 500);

  Future<void> startSplash() async {
    emit(SplashLoading());

    // Ensure minimum display time for smooth UX
    await Future.wait([
      Future.delayed(_minLoadTime),
      _checkAuthStatus(),
    ]);

    // Navigation will be handled by the state
  }

  Future<void> _checkAuthStatus() async {
    try {
      // 1. Check if access token exists
      String? accessToken = await _storage.getAccessToken();

      if (accessToken != null && accessToken.isNotEmpty) {
        // Access token exists, try to validate it
        final isValid = await _validateAccessToken(accessToken);

        if (isValid) {
          // Token is valid, navigate to home
          emit(SplashNavigate(routeName: AppRoutes.bottomNav));
          return;
        }
      }

      // 2. Access token is empty or invalid, try refresh token
      String? refreshToken = await _storage.getRefreshToken();
      String? userEmail = await _storage.getUserEmail();

      if (refreshToken != null && refreshToken.isNotEmpty && userEmail != null && userEmail.isNotEmpty) {
        // Try to refresh the access token using login API with refresh token
        final newAccessToken = await _refreshAccessToken(userEmail, refreshToken);

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          // Refresh successful, save new token and navigate to home
          await _storage.saveAccessToken(newAccessToken);
          emit(SplashNavigate(routeName: AppRoutes.bottomNav));
          return;
        }
      }

      // 3. Both tokens are invalid/expired, navigate to login
      await _storage.deleteAllTokens(); // Clean up invalid tokens
      emit(SplashNavigate(routeName: AppRoutes.login));

    } catch (e) {
      // Error occurred, navigate to login as fallback
      print('❌ Auth check error: $e');
      await _storage.deleteAllTokens();
      emit(SplashNavigate(routeName: AppRoutes.login));
    }
  }

  // Validate access token by making a request to user profile
  Future<bool> _validateAccessToken(String accessToken) async {
    try {
      final response = await _networkCaller.getRequest(
        AppUrl.userProfile,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      return response.isSuccess;
    } catch (e) {
      print('❌ Token validation error: $e');
      return false;
    }
  }

  // Refresh access token using login API with refresh token
  Future<String?> _refreshAccessToken(String email, String refreshToken) async {
    try {
      // Use login API with refresh token
      final Map<String, dynamic> requestBody = {
        'email': email,
        'refreshToken': refreshToken,
      };

      final response = await _networkCaller.postRequest(
        AppUrl.logIn,
        body: requestBody,
        isLogin: true,
      );

      if (response.isSuccess) {
        // Extract new tokens from response
        String? newAccessToken = response.jsonResponse?['data']?['tokens']?['accessToken'] ??
            response.jsonResponse?['data']?['accessToken'] ??
            response.jsonResponse?['accessToken'];

        String? newRefreshToken = response.jsonResponse?['data']?['tokens']?['refreshToken'] ??
            response.jsonResponse?['data']?['refreshToken'] ??
            response.jsonResponse?['refreshToken'];

        // Save new refresh token if provided
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await _storage.saveRefreshToken(newRefreshToken);
        }

        return newAccessToken;
      }
      return null;
    } catch (e) {
      print('❌ Refresh token error: $e');
      return null;
    }
  }

  @override
  Future<void> close() {
    // Clean up resources if needed
    return super.close();
  }
}