import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:venus/core/models/get_data/total_get_data_dto.dart';
import 'package:venus/core/networks/total_get_data_dto_network.dart';
import 'package:venus/core/services/shared_preferences_service.dart';
import 'package:venus/core/view_models/base_view_model.dart';

class ActivitySalesViewModel extends BaseViewModel {
  ActivitySalesViewModel({
    required TotalGetDataDTOService totalGetDataDTOApi,
    required SharedPreferencesService sharedPreferencesService,
  })  : _totalGetDataDTOApi = totalGetDataDTOApi,
        _sharedPreferencesService = sharedPreferencesService;

  final TotalGetDataDTOService _totalGetDataDTOApi;
  // ignore: unused_field
  final SharedPreferencesService _sharedPreferencesService;

  String? _nama;
  String? get nama => _nama;

  String? _admingrup;
  String? get admingrup => _admingrup;

  final Map<String, TotalGetDataContent> _totalMap = {};
  Map<String, TotalGetDataContent> get totalMap => _totalMap;

  @override
  Future<void> initModel() async {
    setBusy(true);
    await _fetchTotal();
    await _fecthUser();
    setBusy(false);
  }

  Future<void> _fetchTotal() async {
    final response = await _totalGetDataDTOApi.getData(
      action: "getDashboard",
    );

    if (response.isRight) {
      _totalMap.clear(); // Clear existing data
      for (var data in response.right.data) {
        _totalMap[data.tipe] = data;
      }
      notify();
    }
  }

  Future<void> _fecthUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString(SharedPrefKeys.userData.label);
    _nama = json.decode(userDataJson!)['vcNama'];
    _admingrup = json.decode(userDataJson)['vcJabatan'];
  }
}
