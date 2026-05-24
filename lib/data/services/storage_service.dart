import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/history_record.dart';

class StorageService {
  late Box _settingsBox;
  late Box _historyBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
    _historyBox = await Hive.openBox(AppConstants.historyBox);
  }

  // Settings
  String getApiUrl() => _settingsBox.get(AppConstants.keyApiUrl, defaultValue: AppConstants.defaultApiUrl);
  Future<void> setApiUrl(String url) => _settingsBox.put(AppConstants.keyApiUrl, url);

  String getApiKey() => _settingsBox.get(AppConstants.keyApiKey, defaultValue: '');
  Future<void> setApiKey(String key) => _settingsBox.put(AppConstants.keyApiKey, key);

  String getModel() => _settingsBox.get(AppConstants.keyModel, defaultValue: AppConstants.defaultModel);
  Future<void> setModel(String model) => _settingsBox.put(AppConstants.keyModel, model);

  int getStrictness() => _settingsBox.get(AppConstants.keyStrictness, defaultValue: 1);
  Future<void> setStrictness(int strictness) => _settingsBox.put(AppConstants.keyStrictness, strictness);

  // History
  List<HistoryRecord> getHistory() {
    final List<dynamic> records = _historyBox.values.toList();
    final result = records.map((e) => HistoryRecord.fromJsonString(e.toString())).toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  Future<void> addHistory(HistoryRecord record) async {
    await _historyBox.put(record.id, record.toJsonString());
  }

  Future<void> deleteHistory(String id) async {
    await _historyBox.delete(id);
  }

  Future<void> clearAllData() async {
    await _settingsBox.clear();
    await _historyBox.clear();
  }
}
