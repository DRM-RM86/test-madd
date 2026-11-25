import 'package:shared_preferences/shared_preferences.dart';

class WorkspaceStore {
  WorkspaceStore(this.preferences);

  final SharedPreferences preferences;

  Future<int> readTab(String phone) async {
    return preferences.getInt('workspace_tab_$phone') ?? 0;
  }

  Future<void> saveTab(String phone, int tab) async {
    await preferences.setInt('workspace_tab_$phone', tab);
  }

  Future<String> readQuery(String phone) async {
    return preferences.getString('workspace_query_$phone') ?? '';
  }

  Future<void> saveQuery(String phone, String query) async {
    await preferences.setString('workspace_query_$phone', query);
  }
}
