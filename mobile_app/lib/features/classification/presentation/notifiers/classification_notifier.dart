import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core_providers.dart';
import '../../domain/entities/classification_result.dart';

class ClassificationState {
  final List<ClassificationResult> results;
  final bool isAnalyzing;
  final String? error;
  final String? statusMessage;
  final int selectedIndex;

  const ClassificationState({
    this.results = const [],
    this.isAnalyzing = false,
    this.error,
    this.statusMessage,
    this.selectedIndex = 0,
  });

  ClassificationState copyWith({
    List<ClassificationResult>? results,
    bool? isAnalyzing,
    String? error,
    String? statusMessage,
    int? selectedIndex,
    bool clearError = false,
    bool clearStatus = false,
  }) => ClassificationState(
    results: results ?? this.results,
    isAnalyzing: isAnalyzing ?? this.isAnalyzing,
    error: clearError ? null : (error ?? this.error),
    statusMessage: clearStatus ? null : (statusMessage ?? this.statusMessage),
    selectedIndex: selectedIndex ?? this.selectedIndex,
  );
}

// ClassificationNotifier — управляет состоянием экрана распознавания (MVVM ViewModel).
class ClassificationNotifier extends Notifier<ClassificationState> {
  @override
  ClassificationState build() => const ClassificationState();

  Future<void> classify(Uint8List imageBytes) async {
    state = state.copyWith(
      isAnalyzing: true, clearError: true, results: [], selectedIndex: 0,
      statusMessage: 'Sending image...',
    );
    try {
      final results = await ref.read(classifyImageUseCaseProvider).call(imageBytes);
      state = state.copyWith(results: results, isAnalyzing: false, clearStatus: true);
    } catch (e) {
      state = state.copyWith(
        isAnalyzing: false, error: e.toString(), clearStatus: true,
      );
    }
  }

  void selectResult(int index) => state = state.copyWith(selectedIndex: index);

  void reset() => state = const ClassificationState();
}

final classificationNotifierProvider =
    NotifierProvider<ClassificationNotifier, ClassificationState>(
        ClassificationNotifier.new);