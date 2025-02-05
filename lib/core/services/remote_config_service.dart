// import 'dart:convert';

// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:venus/core/app_constants/app_constant.dart';
// import 'package:venus/core/models/appwrite_credential.dart';
// import 'package:venus/core/models/kategori_uom.dart';

// final remoteConfigProvider = Provider<RemoteConfigService>(
//   (ref) => RemoteConfigService(),
// );

// class RemoteConfigService {
//   RemoteConfigService();
//   static const String _minVersionKey = 'min_version';
//   static const String _latestVersionKey = 'latest_version';

//   static const String _kategoriUOM = 'kategori_uom';

//   static const String _appwriteCredential = 'appwrite_credential';

//   // feature flags
//   static const String _dummyFF = 'dummy_ff';

//   late FirebaseRemoteConfig _remoteConfig;

//   void setRemoteConfig(FirebaseRemoteConfig remoteConfig) =>
//       _remoteConfig = remoteConfig;

//   Future<void> initialize() async {
//     setRemoteConfig(FirebaseRemoteConfig.instance);
//     await _remoteConfig.setDefaults(await _getDefaults());

//     await _fetchAndActivate();
//   }

//   Future<void> _fetchAndActivate() async {
//     await _remoteConfig.setConfigSettings(
//       RemoteConfigSettings(
//         fetchTimeout: const Duration(minutes: 1),
//         minimumFetchInterval: const Duration(seconds: 10),
//       ),
//     );
//     await _remoteConfig.fetchAndActivate();
//   }

//   String _generateVersionKey(String key) {
//     return '${AppConstant.platform}_$key';
//   }

//   Future<Map<String, dynamic>> _getDefaults() async {
//     final Map<String, dynamic> defaults = <String, dynamic>{};

//     defaults.addAll(<String, dynamic>{
//       _generateVersionKey(_minVersionKey): '1.0.0',
//       _generateVersionKey(_latestVersionKey): '1.0.0',
//     });

//     return defaults;
//   }

//   String? get appMinVersion => _remoteConfig.getString(
//         _generateVersionKey(_minVersionKey),
//       );

//   String? get appLatestVersion => _remoteConfig.getString(
//         _generateVersionKey(_latestVersionKey),
//       );

//   AppwriteCredential get appwriteCredential {
//     final String value = _remoteConfig.getString(_appwriteCredential);

//     return AppwriteCredential.fromJson(json.decode(value));
//   }

//   KategoriUOM get kategoriUOM {
//     final String value = _remoteConfig.getString(_kategoriUOM);

//     return KategoriUOM.fromJson(json.decode(value));
//   }
// }
