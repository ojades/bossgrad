import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChildStatsService {
  static final ChildStatsService _instance = ChildStatsService._internal();
  factory ChildStatsService() => _instance;
  ChildStatsService._internal();

  final ValueNotifier<int> coins = ValueNotifier<int>(0);
  final ValueNotifier<int> xp = ValueNotifier<int>(0);
  final ValueNotifier<int> rank = ValueNotifier<int>(0);
  final ValueNotifier<String> childName = ValueNotifier<String>('Player');

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    childName.value = prefs.getString('child_name') ?? 'Player';
    coins.value = prefs.getInt('child_coins') ?? 0;
    xp.value = prefs.getInt('child_xp') ?? 0;
    rank.value = prefs.getInt('child_rank') ?? 0;
  }

  void updateStats({int? newCoins, int? newXp, int? newRank, String? newName}) {
    if (newCoins != null) coins.value = newCoins;
    if (newXp != null) xp.value = newXp;
    if (newRank != null) rank.value = newRank;
    if (newName != null) childName.value = newName;
    _persist();
  }

  void deduct({required int costCoins, required int costXp}) {
    coins.value -= costCoins;
    xp.value -= costXp;
    _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('child_coins', coins.value);
    await prefs.setInt('child_xp', xp.value);
    await prefs.setInt('child_rank', rank.value);
    await prefs.setString('child_name', childName.value);
  }
}
