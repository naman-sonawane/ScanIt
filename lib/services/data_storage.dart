import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/sort_item.dart';
import '../models/user_stats.dart';

class DataStorage {
  static const String _sortItemsKey = 'sort_items';
  static const String _userStatsKey = 'user_stats';
  static const String _geminiApiKeyKey = 'gemini_api_key';
  static const String _selectedFolderKey = 'selected_folder';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> saveScanItem(ScanItem item) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> items = prefs.getStringList(_sortItemsKey) ?? [];

    items.removeWhere((itemJson) {
      final existingItem = ScanItem.fromJson(jsonDecode(itemJson));
      return existingItem.id == item.id;
    });

    items.add(jsonEncode(item.toJson()));
    await prefs.setStringList(_sortItemsKey, items);
  }

  Future<List<ScanItem>> getScanItems() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> items = prefs.getStringList(_sortItemsKey) ?? [];

    return items
        .map((itemJson) => ScanItem.fromJson(jsonDecode(itemJson)))
        .toList();
  }

  Future<void> deleteScanItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> items = prefs.getStringList(_sortItemsKey) ?? [];

    items.removeWhere((itemJson) {
      final item = ScanItem.fromJson(jsonDecode(itemJson));
      return item.id == id;
    });

    await prefs.setStringList(_sortItemsKey, items);
  }

  Future<void> clearAllScanItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sortItemsKey);
  }

  Future<void> saveUserStats(UserStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userStatsKey, jsonEncode(stats.toJson()));
  }

  Future<UserStats> getUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    String? statsJson = prefs.getString(_userStatsKey);

    if (statsJson != null) {
      return UserStats.fromJson(jsonDecode(statsJson));
    }

    return UserStats.initial();
  }

  Future<void> updateUserStats(ScanItem newItem) async {
    UserStats currentStats = await getUserStats();

    int scoreIncrease = _calculateScoreForCategory(newItem.category);

    Map<String, int> newCategoryCounts = Map.from(currentStats.categoryCounts);
    newCategoryCounts[newItem.category] =
        (newCategoryCounts[newItem.category] ?? 0) + 1;

    List<String> newAchievements = List.from(currentStats.achievements);
    _checkAndAddAchievements(newAchievements, currentStats.itemsSorted + 1,
        currentStats.totalScore + scoreIncrease);

    int newStreakDays = _calculateStreak(currentStats.lastActive);

    UserStats newStats = currentStats.copyWith(
      totalScore: currentStats.totalScore + scoreIncrease,
      itemsSorted: currentStats.itemsSorted + 1,
      categoryCounts: newCategoryCounts,
      achievements: newAchievements,
      lastActive: DateTime.now(),
      streakDays: newStreakDays,
    );

    await saveUserStats(newStats);
  }

  int _calculateScoreForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'compost':
        return 20; // Highest score for composting
      case 'glass':
        return 15; // Good score for glass recycling
      case 'plastic':
        return 10; // Standard score for plastic recycling
      case 'e-waste':
        return 25; // High score for e-waste (harder to dispose properly)
      case 'landfill':
        return 5; // Low score for landfill
      default:
        return 5;
    }
  }

  void _checkAndAddAchievements(
      List<String> achievements, int itemsSorted, int totalScore) {
    if (itemsSorted >= 10 && !achievements.contains('First Steps')) {
      achievements.add('First Steps');
    }
    if (itemsSorted >= 50 && !achievements.contains('Sorting Master')) {
      achievements.add('Sorting Master');
    }
    if (itemsSorted >= 100 && !achievements.contains('Waste Warrior')) {
      achievements.add('Waste Warrior');
    }
    if (totalScore >= 500 && !achievements.contains('Green Champion')) {
      achievements.add('Green Champion');
    }
    if (totalScore >= 1000 && !achievements.contains('Eco Legend')) {
      achievements.add('Eco Legend');
    }
  }

  int _calculateStreak(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive).inDays;

    if (difference <= 1) {
      return 1; // Continue or start streak
    } else {
      return 0; // Break streak
    }
  }

  Future<void> saveGeminiApiKey(String apiKey) async {
    await _secureStorage.write(key: _geminiApiKeyKey, value: apiKey);
  }

  Future<String?> getGeminiApiKey() async {
    return await _secureStorage.read(key: _geminiApiKeyKey);
  }

  Future<bool> hasGeminiApiKey() async {
    String? apiKey = await getGeminiApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  Future<void> deleteGeminiApiKey() async {
    await _secureStorage.delete(key: _geminiApiKeyKey);
  }

  Future<void> setSelectedFolderPath(String folderPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedFolderKey, folderPath);
  }

  Future<String> getSelectedFolderPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedFolderKey) ?? '';
  }

  Future<List<ScanItem>> getScanItemsByCategory(String category) async {
    List<ScanItem> allItems = await getScanItems();
    return allItems
        .where((item) => item.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  Future<List<ScanItem>> searchScanItems(String query) async {
    List<ScanItem> allItems = await getScanItems();
    return allItems
        .where((item) =>
            item.itemName.toLowerCase().contains(query.toLowerCase()) ||
            item.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
