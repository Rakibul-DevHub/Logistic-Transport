import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';
import 'package:tag/feature/load/view/expense/model/load_expense_data.dart';

abstract class AddLoadExpenseState extends Equatable {
  const AddLoadExpenseState();

  @override
  List<Object?> get props => [];
}

class AddLoadExpenseInitial extends AddLoadExpenseState {
  const AddLoadExpenseInitial();
}

class AddLoadExpenseLoading extends AddLoadExpenseState {
  final String message;

  const AddLoadExpenseLoading({
    this.message = 'Saving expense...',
  });

  @override
  List<Object?> get props => [message];
}

class AddLoadExpenseSuccess extends AddLoadExpenseState {
  final LoadExpenseData data;
  final String message;

  const AddLoadExpenseSuccess({
    required this.data,
    this.message = 'Expense created successfully',
  });

  @override
  List<Object?> get props => [data, message];
}

class AddLoadExpenseFailure extends AddLoadExpenseState {
  final String errorMessage;

  const AddLoadExpenseFailure({
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [errorMessage];
}

class LoadExpenseListLoading extends AddLoadExpenseState {
  const LoadExpenseListLoading();
}

class LoadExpenseListSuccess extends AddLoadExpenseState {
  final List<LoadExpenseData> expenses;

  const LoadExpenseListSuccess({required this.expenses});

  double get totalAmount =>
      expenses.fold<double>(0, (sum, e) => sum + (e.amount ?? 0));

  @override
  List<Object?> get props => [expenses];
}

class LoadExpenseListFailure extends AddLoadExpenseState {
  final String errorMessage;

  const LoadExpenseListFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class AddLoadExpenseCubit extends Cubit<AddLoadExpenseState> {
  final NetworkCallerDio _networkCaller;

  AddLoadExpenseCubit({
    NetworkCallerDio? networkCaller,
  })  : _networkCaller = networkCaller ?? NetworkCallerDio(),
        super(const AddLoadExpenseInitial());

  /// [loadId] must be the load's Mongo `_id` (API contract).
  Future<void> createExpense({
    required String loadId,
    required String type,
    required double amount,
    required String date,
    File? receiptFile,
    String? notes,
  }) async {
    try {
      final cleanLoadId = loadId.trim();
      final cleanType = type.trim().toLowerCase();
      final cleanNotes = notes?.trim();

      if (cleanLoadId.isEmpty) {
        emit(
          const AddLoadExpenseFailure(
            errorMessage: 'Load ID is missing',
          ),
        );
        return;
      }

      if (amount <= 0) {
        emit(
          const AddLoadExpenseFailure(
            errorMessage: 'Please enter a valid amount',
          ),
        );
        return;
      }

      emit(
        const AddLoadExpenseLoading(
          message: 'Preparing expense...',
        ),
      );

      final token =
          await SecureStorageService.instance.getAccessToken();

      if (token == null || token.isEmpty) {
        emit(
          const AddLoadExpenseFailure(
            errorMessage: 'Please login again',
          ),
        );
        return;
      }

      String? uploadedReceipt;

      if (receiptFile != null) {
        if (!await receiptFile.exists()) {
          emit(
            const AddLoadExpenseFailure(
              errorMessage: 'Receipt file not found',
            ),
          );
          return;
        }

        emit(
          const AddLoadExpenseLoading(
            message: 'Uploading receipt...',
          ),
        );

        final uploadResponse = await _networkCaller.uploadImage(
          AppUrl.singleImageUpload,
          imageFile: receiptFile,
          headers: {
            'Authorization': 'Bearer $token',
          },
          fileFieldName: 'file',
          method: 'POST',
        );

        if (!uploadResponse.isSuccess ||
            uploadResponse.jsonResponse == null) {
          emit(
            AddLoadExpenseFailure(
              errorMessage: uploadResponse.errorMessage ??
                  uploadResponse.jsonResponse?['message']?.toString() ??
                  'Failed to upload receipt',
            ),
          );
          return;
        }

        final uploadData = uploadResponse.jsonResponse?['data'];

        if (uploadData is Map) {
          uploadedReceipt = uploadData['filename']?.toString() ??
              uploadData['path']?.toString() ??
              uploadData['url']?.toString().split('/').last;
        }

        if (uploadedReceipt == null || uploadedReceipt.isEmpty) {
          emit(
            const AddLoadExpenseFailure(
              errorMessage: 'Could not get the uploaded receipt name',
            ),
          );
          return;
        }
      }

      final request = AddLoadExpenseRequest(
        loadId: cleanLoadId,
        type: cleanType,
        amount: amount,
        date: date,
        receipt: uploadedReceipt,
        notes: cleanNotes,
      );

      emit(
        const AddLoadExpenseLoading(
          message: 'Saving expense...',
        ),
      );

      final response = await _networkCaller.postRequest(
        AppUrl.addLoadExpense,
        body: request.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final parsed = LoadExpenseResponse.fromJson(
          response.jsonResponse!,
        );

        if (parsed.data != null) {
          emit(
            AddLoadExpenseSuccess(
              data: parsed.data!,
              message: parsed.message ?? 'Expense created successfully',
            ),
          );
          return;
        }
      }

      emit(
        AddLoadExpenseFailure(
          errorMessage: response.errorMessage ??
              response.jsonResponse?['message']?.toString() ??
              'Failed to create expense',
        ),
      );
    } catch (error) {
      emit(
        AddLoadExpenseFailure(
          errorMessage: error.toString(),
        ),
      );
    }
  }

  /// [loadMongoId] is the load's Mongo `_id`.
  Future<void> fetchExpenses(String loadMongoId) async {
    try {
      final id = loadMongoId.trim();
      if (id.isEmpty) {
        emit(
          const LoadExpenseListFailure(
            errorMessage: 'Load ID is missing',
          ),
        );
        return;
      }

      emit(const LoadExpenseListLoading());

      final token =
          await SecureStorageService.instance.getAccessToken();

      if (token == null || token.isEmpty) {
        emit(
          const LoadExpenseListFailure(
            errorMessage: 'Please login again',
          ),
        );
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.getLoadExpense(id),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final parsed = LoadExpenseListResponse.fromJson(
          response.jsonResponse!,
        );
        emit(LoadExpenseListSuccess(expenses: parsed.data));
        return;
      }

      emit(
        LoadExpenseListFailure(
          errorMessage: response.errorMessage ??
              response.jsonResponse?['message']?.toString() ??
              'Failed to load expenses',
        ),
      );
    } catch (error) {
      emit(
        LoadExpenseListFailure(
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void reset() {
    emit(const AddLoadExpenseInitial());
  }
}