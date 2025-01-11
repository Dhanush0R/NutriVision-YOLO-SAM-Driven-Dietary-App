import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define the StateNotifier for managing the list of selected diseases
class SelectedDiseasesNotifier extends StateNotifier<List<String>> {
  SelectedDiseasesNotifier() : super([]);

  // Method to add a disease
  void addDisease(List<String> disease) {
    state = [...disease];
  }

  // Method to remove a disease
  void removeDisease(String disease) {
    state = state.where((item) => item != disease).toList();
  }

  // Method to clear all diseases
  void clearDiseases() {
    state = [];
  }
}

// Define the provider
final selectedDiseasesProvider =
    StateNotifierProvider<SelectedDiseasesNotifier, List<String>>(
        (ref) => SelectedDiseasesNotifier());
