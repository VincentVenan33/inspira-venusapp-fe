import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:venus/core/models/get_data/order_jual_get_data_dto.dart';
import 'package:venus/core/networks/approval_order_jual_dto_network.dart';
import 'package:venus/core/networks/order_jual_get_data_dto_network.dart';
import 'package:venus/core/view_models/base_view_model.dart';

class ApprovalDetailOrderViewModel extends BaseViewModel {
  ApprovalDetailOrderViewModel({
    required OrderJualGetDataDTOService orderJualGetDataDTOApi,
    required SetApprovalOrderJualDTOService setApprovalOrderJualDTOApi,
    required int nomor,
  })  : _orderJualGetDataDTOApi = orderJualGetDataDTOApi,
        _setApprovalOrderJualDTOApi = setApprovalOrderJualDTOApi,
        _nomor = nomor;

  final OrderJualGetDataDTOService _orderJualGetDataDTOApi;
  final SetApprovalOrderJualDTOService _setApprovalOrderJualDTOApi;
  final int _nomor;

  final List<OrderJualGetDataContent> _orderjual = [];
  List<OrderJualGetDataContent> get orderjual => _orderjual;

  List<OrderJualGetDataContent> _orderjualdetail = [];
  List<OrderJualGetDataContent> get orderjualdetail => _orderjualdetail;

  List<OrderJualGetDataContent> _orderjualbonusdetail = [];
  List<OrderJualGetDataContent> get orderjualbonusdetail => _orderjualbonusdetail;

  int _currentPage = 1;
  bool _isLastPage = false;
  bool get isLastPage => _isLastPage;

  bool _statussetuju = false;
  bool get statussetuju => _statussetuju;

  @override
  Future<void> initModel() async {
    setBusy(true);
    await fetchOrderJual(reload: true);
    await _fetchOrderJualDetail(_nomor);
    await _fetchOrderJualBonusDetail(_nomor);
    setBusy(false);
  }

  OrderJualGetFilter currentFilter = OrderJualGetFilter(
    limit: 10,
    page: 10,
    sort: 'DESC',
    orderby: 'thorderjual.nomor',
  );
  Future<void> fetchOrderJual({bool reload = false}) async {
    final search = OrderJualGetSearch(
      term: 'like',
      key: 'thorderjual.kode',
      query: '',
    );
    if (reload) {
      _currentPage = 1;
      _orderjual.clear();
    }
    try {
      final newFilter = OrderJualGetFilter(
        limit: currentFilter.limit,
        page: _currentPage,
        sort: 'DESC',
        intNomor: _nomor,
        orderby: 'thorderjual.nomor',
      );

      final response = await _orderJualGetDataDTOApi.getData(
        action: "getOrderJual",
        filters: newFilter,
        search: search,
      );

      if (response.isRight) {
        final List<OrderJualGetDataContent> orderjualDataFromApi = response.right.data.data;
        _statussetuju = orderjualDataFromApi[0].intApproved == 0 ? false : true;
        _isLastPage = orderjualDataFromApi.length < currentFilter.limit;
        _orderjual.addAll(orderjualDataFromApi);
        if (_isLastPage == false) {
          _currentPage++;
        }

        notify();
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _fetchOrderJualDetail(int nomorOrderJual) async {
    final search = OrderJualGetSearch(
      term: 'like',
      key: 'tdorderjual.intNomorHeader',
      query: '$nomorOrderJual',
    );
    debugPrint('nomororderjual $nomorOrderJual');
    final filters = OrderJualGetFilter(
      limit: 10,
      page: 1,
    );

    final response = await _orderJualGetDataDTOApi.getData(
      action: "getOrderJualDetail",
      filters: filters,
      search: search,
    );

    if (response.isRight) {
      _orderjualdetail = response.right.data.data;
      notify();
    } else {}
  }

  Future<void> _fetchOrderJualBonusDetail(int nomorOrderJual) async {
    final search = OrderJualGetSearch(
      term: 'like',
      key: 'tdorderjualbonus.nomorthorderjual',
      query: '$nomorOrderJual',
    );
    final filters = OrderJualGetFilter(
      limit: 10,
      page: 1,
    );

    final response = await _orderJualGetDataDTOApi.getData(
      action: "getOrderJualBonusDetail",
      filters: filters,
      search: search,
    );

    if (response.isRight) {
      _orderjualbonusdetail = response.right.data.data;
      notify();
    }
  }

  Future<bool> approvalOrderJualModel({
    required int intApproved,
    required int dtApproveTime,
  }) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    final response = await _setApprovalOrderJualDTOApi.setApprovalOrderJual(
      action: "updateOrderJual",
      intApproved: intApproved,
      dtApproveTime: formattedDate,
      intNomor: _nomor,
    );
    if (response.isRight) {
      return true;
    }
    return false;
  }
}
