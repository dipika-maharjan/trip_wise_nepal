import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:trip_wise_nepal/core/constants/hive_table_constant.dart';
import 'package:trip_wise_nepal/features/auth/data/models/auth_hive_model.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService.instance;
});

class HiveService {
  // Singleton instance
  static final HiveService _instance = HiveService._internal();

  HiveService._internal();

  factory HiveService() {
    return _instance;
  }

  static HiveService get instance => _instance;

  // init
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    print('[DEBUG] HiveService.init: Hive path = $path');
    Hive.init(path);

    // register adapter
    _registerAdapter();
    await _openBoxes();
    print('[DEBUG] HiveService.init: Boxes opened, keys in authBox = ${Hive.box<AuthHiveModel>(HiveTableConstant.authTable).keys.toList()}');
  }

  // Adapter register
  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  // box open
  Future<void> _openBoxes() async {
    print('[DEBUG] HiveService._openBoxes: Opening authBox');
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
    print('[DEBUG] HiveService._openBoxes: authBox opened, keys = ${Hive.box<AuthHiveModel>(HiveTableConstant.authTable).keys.toList()}');
  }

  // box close
  Future<void> close() async {
    await Hive.close();
  }

  // ======================= Auth Queries =========================

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  // Register user
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    print('[DEBUG] HiveService.register: saving user with authId = ${user.authId}');
    await _authBox.put(user.authId, user);
    print('[DEBUG] HiveService.register: user saved = ${_authBox.get(user.authId)}');
    return user;
  }

  // Login - find user by email and password
  AuthHiveModel? login(String email, String password) {
    try {
      final user = _authBox.values.firstWhere(
        (user) => user.email == email && user.password == password,
      );
      print('[DEBUG] HiveService.login: found user = $user');
      return user;
    } catch (e) {
      print('[DEBUG] HiveService.login: no user found for $email');
      return null;
    }
  }

  // Get user by ID
  AuthHiveModel? getUserById(String authId) {
    final user = _authBox.get(authId);
    print('[DEBUG] HiveService.getUserById: authId = $authId, user = $user');
    return user;
  }

  // Get user by email
  AuthHiveModel? getUserByEmail(String email) {
    try {
      return _authBox.values.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  // Get all users
  List<AuthHiveModel> getAllUsers() {
    return _authBox.values.toList();
  }

  // Update user
  Future<bool> updateUser(AuthHiveModel user) async {
    if (_authBox.containsKey(user.authId)) {
      await _authBox.put(user.authId, user);
      return true;
    }
    return false;
  }

  // Delete user
  Future<void> deleteUser(String authId) async {
    await _authBox.delete(authId);
  }

  // Clear all users (for testing)
  Future<void> clearAllUsers() async {
    await _authBox.clear();
  }
}