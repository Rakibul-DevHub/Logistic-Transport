import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// ============ States ============
abstract class OnboardingState extends Equatable {
  final int currentIndex;
  const OnboardingState(this.currentIndex);

  @override
  List<Object?> get props => [currentIndex];
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial(super.currentIndex);
}

class OnboardingPageChanged extends OnboardingState {
  const OnboardingPageChanged(super.currentIndex);
}

// ============ Cubit ============
class OnboardingCubit extends Cubit<OnboardingState> {
  final int totalPages;

  OnboardingCubit(this.totalPages) : super(const OnboardingInitial(0));

  /// Called by PageView.onPageChanged — only emits when the index actually
  /// changes, preventing redundant rebuilds on the same page.
  void updatePage(int index) {
    if (index == state.currentIndex) return;
    if (index >= 0 && index < totalPages) {
      emit(OnboardingPageChanged(index));
    }
  }

  void nextPage() {
    final next = state.currentIndex + 1;
    if (next < totalPages) {
      emit(OnboardingPageChanged(next));
    }
  }

  void skipToEnd() {
    final last = totalPages - 1;
    if (state.currentIndex != last) {
      emit(OnboardingPageChanged(last));
    }
  }

  bool isLastPage(OnboardingState state) => state.currentIndex == totalPages - 1;
}