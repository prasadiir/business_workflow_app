import 'package:shared_preferences/shared_preferences.dart';
import '../models/entry_model.dart';

class StorageService {
  static const String _entriesKey = 'business_entries';

  Future<List<EntryModel>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getStringList(_entriesKey) ?? [];
    return entriesJson.map((e) => EntryModel.fromJson(e)).toList();
  }

  Future<void> saveEntry(EntryModel entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getEntries();
    entries.add(entry);
    final entriesJson = entries.map((e) => e.toJson()).toList();
    await prefs.setStringList(_entriesKey, entriesJson);
  }

  Future<void> deleteEntry(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getEntries();
    entries.removeWhere((e) => e.id == id);
    final entriesJson = entries.map((e) => e.toJson()).toList();
    await prefs.setStringList(_entriesKey, entriesJson);
  }

  Future<EntryModel?> getEntryById(String id) async {
    final entries = await getEntries();
    try {
      return entries.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }
}
