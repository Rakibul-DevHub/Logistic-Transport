// lib/feature/auth/cubit/auth_registration_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// ==================== EVENTS ====================
abstract class AuthRegistrationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UpdateRegistrationData extends AuthRegistrationEvent {
  final String email;
  final String firstName;
  final String lastName;
  final String password;

  UpdateRegistrationData({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
  });

  @override
  List<Object?> get props => [email, firstName, lastName, password];
}

class ClearRegistrationData extends AuthRegistrationEvent {}

// ==================== STATE ====================
class AuthRegistrationState extends Equatable {
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final bool isLoading;
  final String? errorMessage;

  const AuthRegistrationState({
    this.email = '',
    this.firstName = '',
    this.lastName = '',
    this.password = '',
    this.isLoading = false,
    this.errorMessage,
  });

  AuthRegistrationState copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? password,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthRegistrationState(
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    email,
    firstName,
    lastName,
    password,
    isLoading,
    errorMessage,
  ];
}

// ==================== CUBIT ====================
class AuthRegistrationCubit extends Cubit<AuthRegistrationState> {
  AuthRegistrationCubit() : super(const AuthRegistrationState());

  /// Store registration data from CreateAccountScreen
  void updateRegistrationData({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) {
    emit(state.copyWith(
      email: email.trim(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      password: password,
      errorMessage: null,
    ));
  }

  /// Clear sensitive data after flow completion
  void clearData() {
    emit(const AuthRegistrationState());
  }

  /// Set loading state for API operations
  void setLoading(bool value) {
    emit(state.copyWith(isLoading: value));
  }

  /// Set error message
  void setError(String message) {
    emit(state.copyWith(errorMessage: message, isLoading: false));
  }

  /// Getters for easy access
  String get email => state.email;
  String get firstName => state.firstName;
  String get lastName => state.lastName;
  String get password => state.password;
  bool get isLoading => state.isLoading;
  String? get errorMessage => state.errorMessage;
}