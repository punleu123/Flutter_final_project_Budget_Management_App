import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/hive_boxes.dart';

/// Settings state notifier for managing app settings
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
    : super(
        SettingsState(
          currency: HiveBoxes.settingsBox.get('currency', defaultValue: 'USD'),
        ),
      ) {
    loadSettings();
  }

  /// Load settings from Hive
  void loadSettings() {
    final currency =
        HiveBoxes.settingsBox.get('currency', defaultValue: 'USD') as String;
    state = SettingsState(currency: currency);
  }

  /// Toggle currency between USD and KHR
  Future<void> toggleCurrency() async {
    final newCurrency = state.currency == 'USD' ? 'KHR' : 'USD';
    await HiveBoxes.settingsBox.put('currency', newCurrency);
    state = SettingsState(currency: newCurrency);
  }

  /// Set currency to specific value
  Future<void> setCurrency(String currency) async {
    await HiveBoxes.settingsBox.put('currency', currency);
    state = SettingsState(currency: currency);
  }

  /// Get decimal places based on currency
  int getDecimalPlaces() {
    return state.currency == 'USD' ? 2 : 0;
  }
}

/// Settings state
class SettingsState {
  final String currency; // USD or KHR

  SettingsState({required this.currency});
}

/// Provider for settings
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier();
  },
);

/// Provider to get current currency
final currencyProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).currency;
});

/// Provider to get decimal places for currency
final decimalPlacesProvider = Provider<int>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.currency == 'USD' ? 2 : 0;
});
