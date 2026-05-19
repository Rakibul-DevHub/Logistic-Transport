import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// ============ States ============
abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashNavigate extends SplashState {}

// ============ Events ============
abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

class SplashStarted extends SplashEvent {}

// ============ Cubit ============
class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  // Configuration
  static const Duration _splashDuration = Duration(seconds: 3);
  static const Duration _minLoadTime = Duration(milliseconds: 500);

  Future<void> startSplash() async {
    emit(SplashLoading());

    // Ensure minimum display time for smooth UX
    await Future.wait([
      Future.delayed(_minLoadTime),
      _simulateInitialization(),
    ]);

    emit(SplashNavigate());
  }

  Future<void> _simulateInitialization() async {
    // Add your async operations here:
    // - Check auth status
    // - Load user data
    // - Initialize services
    await Future.delayed(_splashDuration);
  }

  @override
  Future<void> close() {
    // Clean up resources if needed
    return super.close();
  }
}