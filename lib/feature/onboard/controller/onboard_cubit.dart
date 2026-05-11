// import 'package:flutter_bloc/flutter_bloc.dart';
//
// class OnboardingCubit extends Cubit<int> {
//   final int totalPages;
//
//   OnboardingCubit(this.totalPages) : super(0);
//
//   void setPage(int index) {
//     if (index >= 0 && index < totalPages) {
//       emit(index);
//     }
//   }
//
//   void nextPage() {
//     if (state < totalPages - 1) {
//       emit(state + 1);
//     }
//   }
//
//   bool get isLastPage => state == totalPages - 1;
// }




import 'package:flutter_bloc/flutter_bloc.dart';

// States
abstract class OnboardingState {
  final int currentIndex;
  const OnboardingState(this.currentIndex);
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial(int currentIndex) : super(currentIndex);
}

class OnboardingPageChanged extends OnboardingState {
  const OnboardingPageChanged(int currentIndex) : super(currentIndex);
}

// Events
abstract class OnboardingEvent {}

class OnboardingPageUpdated extends OnboardingEvent {
  final int index;
  OnboardingPageUpdated(this.index);
}

class OnboardingNextPageRequested extends OnboardingEvent {}

class OnboardingSkipToEndRequested extends OnboardingEvent {}

// Cubit
class OnboardingCubit extends Cubit<OnboardingState> {
  final int totalPages;

  OnboardingCubit(this.totalPages) : super(OnboardingInitial(0));

  void updatePage(int index) {
    if (index >= 0 && index < totalPages) {
      emit(OnboardingPageChanged(index));
    }
  }

  void nextPage() {
    final currentIndex = state.currentIndex;
    if (currentIndex < totalPages - 1) {
      emit(OnboardingPageChanged(currentIndex + 1));
    }
  }

  void skipToEnd() {
    emit(OnboardingPageChanged(totalPages - 1));
  }

  bool isLastPage(OnboardingState state) {
    return state.currentIndex == totalPages - 1;
  }
}