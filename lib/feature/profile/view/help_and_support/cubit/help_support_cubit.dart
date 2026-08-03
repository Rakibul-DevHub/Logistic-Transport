import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/utils/app_url.dart';
import 'package:tag/feature/profile/view/help_and_support/model/help_support_data.dart';

abstract class HelpSupportState extends Equatable {
  const HelpSupportState();

  @override
  List<Object?> get props => [];
}

class HelpSupportInitial extends HelpSupportState {}

class HelpSupportLoading extends HelpSupportState {}

class HelpSupportSuccess extends HelpSupportState {
  final HelpSupportData data;

  const HelpSupportSuccess({required this.data});

  @override
  List<Object?> get props => [data];
}

class HelpSupportFailure extends HelpSupportState {
  final String errorMessage;

  const HelpSupportFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class HelpSupportCubit extends Cubit<HelpSupportState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  HelpSupportCubit() : super(HelpSupportInitial());

  Future<void> fetch() async {
    emit(HelpSupportLoading());
    try {
      final response = await _networkCaller.getRequest(
        AppUrl.helpSupport,
        headers: {'Accept': 'application/json'},
      );

      if (!response.isSuccess || response.jsonResponse == null) {
        emit(HelpSupportFailure(
          errorMessage:
              response.errorMessage ?? 'Failed to load help & support',
        ));
        return;
      }

      final parsed = HelpSupportResponse.fromJson(response.jsonResponse!);
      if (parsed.data == null) {
        emit(const HelpSupportFailure(
          errorMessage: 'Help & support data is empty',
        ));
        return;
      }

      emit(HelpSupportSuccess(data: parsed.data!));
    } catch (e) {
      debugPrint('❌ HelpSupportCubit error: $e');
      emit(HelpSupportFailure(errorMessage: e.toString()));
    }
  }
}
