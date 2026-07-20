import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/utils/app_url.dart';
import '../model/settings_content_data.dart';

enum SettingsContentType {
  terms,
  privacy,
}

abstract class SettingsContentState extends Equatable {
  const SettingsContentState();

  @override
  List<Object?> get props => [];
}

class SettingsContentInitial extends SettingsContentState {}

class SettingsContentLoading extends SettingsContentState {}

class SettingsContentSuccess extends SettingsContentState {
  final String htmlContent;
  final String key;
  final SettingsContentType type;

  const SettingsContentSuccess({
    required this.htmlContent,
    required this.type,
    this.key = '',
  });

  @override
  List<Object?> get props => [htmlContent, key, type];
}

class SettingsContentFailure extends SettingsContentState {
  final String errorMessage;

  const SettingsContentFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class SettingsContentCubit extends Cubit<SettingsContentState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  SettingsContentCubit() : super(SettingsContentInitial());

  Future<void> fetch(SettingsContentType type) async {
    try {
      emit(SettingsContentLoading());

      final url = type == SettingsContentType.terms
          ? AppUrl.termsAndConditions
          : AppUrl.privacyPolicy;

      final response = await _networkCaller.getRequest(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final parsed =
        SettingsContentResponse.fromJson(response.jsonResponse!);

        if (parsed.data != null && parsed.data!.value.trim().isNotEmpty) {
          emit(SettingsContentSuccess(
            htmlContent: parsed.data!.value,
            key: parsed.data!.key,
            type: type,
          ));
          return;
        }

        emit(SettingsContentFailure(
          errorMessage: type == SettingsContentType.terms
              ? 'Terms content is empty'
              : 'Privacy policy content is empty',
        ));
        return;
      }

      String errorMsg = response.errorMessage ??
          (type == SettingsContentType.terms
              ? 'Failed to load terms & conditions'
              : 'Failed to load privacy policy');

      if (response.jsonResponse != null) {
        errorMsg = response.jsonResponse?['message']?.toString() ??
            response.jsonResponse?['error']?.toString() ??
            errorMsg;
      }

      emit(SettingsContentFailure(errorMessage: errorMsg));
    } catch (e) {
      emit(SettingsContentFailure(
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }
}
