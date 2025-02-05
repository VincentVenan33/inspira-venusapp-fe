import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:venus/core/app_constants/colors.dart';
import 'package:venus/core/app_constants/route.dart';
import 'package:venus/core/models/get_data/order_jual_get_data_dto.dart';
import 'package:venus/core/models/get_data/satuan_barang_get_data_dto.dart';
import 'package:venus/core/networks/barang_get_data_dto_network.dart';
import 'package:venus/core/networks/order_jual_get_data_dto_network.dart';
import 'package:venus/core/networks/satuan_barang_get_data_dto_network.dart';
import 'package:venus/core/networks/update_order_jual_detail_dto.dart';
import 'package:venus/core/view_models/produk/edit/edititemdetail_view_model.dart';
import 'package:venus/core/view_models/produk/itemdetail_view_model.dart';
import 'package:venus/core/view_models/view_model.dart';
import 'package:venus/ui/shared/loading_overlay.dart';
import 'package:venus/ui/shared/unfocus_helper.dart';
import 'package:venus/ui/views/orderjual/edit/editorderjual.dart';

import '../../../shared/spacings.dart';

class UpdateEditDetailOrderParam {
  const UpdateEditDetailOrderParam({
    this.nomor,
    this.mode,
    this.header,
    this.detailItem,
  });

  final int? nomor;
  final String? mode;
  final OrderJualGetDataContent? header;
  final List<OrderJualGetDataContent>? detailItem;
}

class UpdateEditDetailOrderJual extends ConsumerStatefulWidget {
  const UpdateEditDetailOrderJual({
    super.key,
    required this.param,
  });

  final UpdateEditDetailOrderParam param;

  @override
  ConsumerState<UpdateEditDetailOrderJual> createState() => _UpdateEditDetailOrderJualState();
}

class _UpdateEditDetailOrderJualState extends ConsumerState<UpdateEditDetailOrderJual> {
  int _qty = 0;
  int _netto = 0;
  int _disctotal = 0;
  int _discdirect = 0;
  int _disc3 = 0;
  int _diskon3 = 0;
  int _disc2 = 0;
  int _diskon2 = 0;
  int _disc1 = 0;
  int _diskon1 = 0;
  int _isi = 0;
  int _harga = 0;
  int _subtotal = 0;
  int _konversisatuan = 0;
  final TextEditingController kodeController = TextEditingController();
  final TextEditingController nomorbarangController = TextEditingController();
  final TextEditingController nomorsatuanController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController satuanqtyController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  final TextEditingController satuanisiController = TextEditingController();
  final TextEditingController konversisatuanController = TextEditingController();
  final TextEditingController isiController = TextEditingController();
  final TextEditingController diskon1Controller = TextEditingController();
  final TextEditingController diskon2Controller = TextEditingController();
  final TextEditingController diskon3Controller = TextEditingController();
  final TextEditingController directController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  final TextEditingController nettoController = TextEditingController();
  final TextEditingController subtotalController = TextEditingController();

  int jumlah = 0;
  double scrollPosition = 0.0;
  bool tabIsHide = false;

  late DetailOrderJualViewModel model;
  late int konversisatuan;

  @override
  void initState() {
    super.initState();
    hargaController.addListener(calculateDiscTotal);
    diskon1Controller.addListener(calculateDiscTotal);
    diskon2Controller.addListener(calculateDiscTotal);
    diskon3Controller.addListener(calculateDiscTotal);
    directController.addListener(calculateDiscTotal);
    hargaController.addListener(calculateNetto);
    totalController.addListener(calculateNetto);
    qtyController.addListener(calculateSubtotal);
    nettoController.addListener(calculateSubtotal);
  }

  void calculateDiscTotal() {
    setState(() {
      _harga = int.tryParse(hargaController.text) ?? 0;
      double disc1Percentage = (double.tryParse(diskon1Controller.text) ?? 0) / 100;
      double disc2Percentage = (double.tryParse(diskon2Controller.text) ?? 0) / 100;
      double disc3Percentage = (double.tryParse(diskon3Controller.text) ?? 0) / 100;

      // Calculate discounts
      _diskon1 = (_harga * disc1Percentage).toInt();
      _diskon2 = ((_harga - _diskon1) * disc2Percentage).toInt();
      _diskon3 = ((_harga - _diskon1 - _diskon2) * disc3Percentage).toInt();

      _discdirect = int.tryParse(directController.text) ?? 0;
      debugPrint('diskon1 $_diskon1');
      debugPrint('diskon2 $_diskon2');
      debugPrint('diskon3 $_diskon3');
      // Calculate total
      _disctotal = _diskon1 + _diskon2 + _diskon3 + _discdirect;
      totalController.text = _disctotal.toString();
    });
  }

  void calculateNetto() {
    setState(() {
      _harga = int.tryParse(hargaController.text) ?? 0;
      _disctotal = int.tryParse(totalController.text) ?? 0;
      _netto = _harga - _disctotal;
      nettoController.text = _netto.toString();
    });
  }

  void calculateSubtotal() {
    setState(() {
      _qty = int.tryParse(qtyController.text) ?? 0;
      _netto = int.tryParse(nettoController.text) ?? 0;
      _subtotal = _qty * _netto;
      subtotalController.text = _subtotal.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ViewModel<EditItemDetailOrderJualViewModel>(
      model: EditItemDetailOrderJualViewModel(
        barangGetDataDTOApi: ref.read(barangGetDataDTOApi),
        satuanBarangGetDataDTOApi: ref.read(satuanBarangGetDataDTOApi),
        orderJualDetailGetDataDTOApi: ref.read(orderJualGetDataDTOApi),
        setUpdateOrderJualDetailDTOApi: ref.read(setUpdateOrderJualDetailDTOApi),
        nomor: widget.param.nomor!,
      ),
      onModelReady: (EditItemDetailOrderJualViewModel model) => model.initModel(),
      builder: (_, EditItemDetailOrderJualViewModel model, __) {
        return UnfocusHelper(
          child: SafeArea(
            child: Scaffold(
              backgroundColor: venusColor.white,
              body: RefreshIndicator(
                onRefresh: () async => model.initModel(),
                child: NotificationListener<UserScrollNotification>(
                  onNotification: (notification) {
                    if (notification.direction == ScrollDirection.reverse) {
                      setState(() {
                        tabIsHide = true;
                      });
                    } else if (notification.direction == ScrollDirection.forward) {
                      setState(() {
                        tabIsHide = false;
                      });
                    }

                    return true;
                  },
                  child: LoadingOverlay(
                    isLoading: model.busy,
                    child: CustomScrollView(
                      slivers: [
                        SliverStickyHeader.builder(
                          sticky: true,
                          builder: (context, state) {
                            return AnimatedSlide(
                              curve: Curves.easeIn,
                              duration: const Duration(milliseconds: 200),
                              offset: tabIsHide == false ? Offset.zero : const Offset(0, -1),
                              child: Column(
                                children: [
                                  AppBar(
                                    backgroundColor: venusColor.backgroundAtas,
                                    title: Text(
                                      'Item Detail',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: tabIsHide == false ? 18 : 14,
                                      ),
                                    ),
                                    // actions: [
                                    //   IconButton(
                                    //     icon: const Icon(Icons.more_vert),
                                    //     onPressed: () {},
                                    //   ),
                                    // ],
                                    // centerTitle: true,
                                    toolbarHeight: tabIsHide == false ? kToolbarHeight : kToolbarHeight - 10,
                                  ),
                                ],
                              ),
                            );
                          },
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, i) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Image.network(
                                        'https://indraco.com/gmb/tanpalogo/TUGUBUAYA/TB-301.png',
                                        width: MediaQuery.of(context).size.width,
                                        height: 300,
                                        fit: BoxFit.cover,
                                      ),
                                    ],
                                  ),
                                  Spacings.verSpace(
                                    20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 24,
                                      right: 24,
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    model.kodeController.text,
                                                    style: const TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  Spacings.verSpace(
                                                    5,
                                                  ),
                                                  Text(
                                                    model.namaController.text,
                                                    style: const TextStyle(
                                                      color: venusColor.black,
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacings.verSpace(
                                          20,
                                        ),
                                        Column(
                                          children: [
                                            const Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'QTY',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: venusColor.lightBlack008),
                                                ),
                                              ],
                                            ),
                                            Spacings.verSpace(12),
                                            const Divider(
                                              height: 1,
                                              color: venusColor.lightBlack009,
                                            ),
                                            Spacings.verSpace(12),
                                            const Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Satuan',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: venusColor.lightBlack011,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Spacings.verSpace(5),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: DropdownButtonFormField<SatuanBarangGetDataContent>(
                                                    value: model.selectedSatuanBarang,
                                                    hint: Text(
                                                      model.satuanqtyController.text,
                                                      style: const TextStyle(
                                                          color: venusColor.black,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w500),
                                                    ),
                                                    items: model.satuanbarang
                                                        .where((item) => item.vcNama != null)
                                                        .map((item) => DropdownMenuItem<SatuanBarangGetDataContent>(
                                                              value: item,
                                                              child: satuanBarang(
                                                                context,
                                                                item,
                                                              ),
                                                            ))
                                                        .toList(),
                                                    onChanged: (value) {
                                                      setState(
                                                        () {
                                                          model.setselectedsatuanBarang(value);
                                                          _konversisatuan = value!.konversi!;
                                                          model.konversisatuanController.text =
                                                              _konversisatuan.toString();
                                                          _qty = int.tryParse(model.qtyController.text) ?? 0;
                                                          _konversisatuan =
                                                              int.tryParse(model.konversisatuanController.text) ?? 0;
                                                          debugPrint('konversi satuan $_konversisatuan');
                                                          _isi = _qty * _konversisatuan;
                                                          _harga = value.hargaPL!;
                                                          hargaController.text = _harga.toString();
                                                          model.isiController.text = _isi.toString();
                                                        },
                                                      );
                                                    },
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                          const EdgeInsets.only(left: 16, top: 6, bottom: 6),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8.0),
                                                        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8.0),
                                                        borderSide: const BorderSide(color: Colors.blue, width: 1.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      model.setselectedsatuanBarang(null);
                                                    });
                                                  },
                                                  icon: const Icon(
                                                    Icons.refresh_outlined,
                                                    color: venusColor.lightBlack014,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Spacings.verSpace(
                                              10,
                                            ),
                                            const Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Jumlah',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: venusColor.lightBlack011,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Spacings.verSpace(5),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets.all(0),
                                                    backgroundColor:
                                                        venusColor.floatButtonSalesColor, // Ubah ke warna yang sesuai
                                                    shape: const RoundedRectangleBorder(
                                                      side: BorderSide.none,
                                                      borderRadius: BorderRadius.all(
                                                        Radius.circular(
                                                          8,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _qty = int.tryParse(model.qtyController.text) ?? 0;
                                                      _konversisatuan =
                                                          int.tryParse(model.konversisatuanController.text) ?? 0;
                                                      debugPrint('konversi satuan $_konversisatuan');
                                                      if (_qty > 0) {
                                                        _qty--;
                                                        model.qtyController.text = _qty.toString();
                                                        _isi = _qty * _konversisatuan;
                                                        model.isiController.text = _isi.toString();
                                                      }
                                                    });
                                                  },
                                                  icon: const Icon(
                                                    Icons.remove,
                                                    color: Colors.white, // Ubah ke warna yang sesuai
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                SizedBox(
                                                  width: 100,
                                                  child: TextFormField(
                                                    controller: model.qtyController,
                                                    textAlign: TextAlign.center,
                                                    onChanged: (value) {
                                                      setState(
                                                        () {
                                                          _qty = int.tryParse(model.qtyController.text) ?? 0;
                                                          _konversisatuan =
                                                              int.tryParse(model.konversisatuanController.text) ?? 0;
                                                          debugPrint('konversi satuan $_konversisatuan');
                                                          _isi = _qty * _konversisatuan;
                                                          model.isiController.text = _isi.toString();

                                                          _qty = int.tryParse(value) ?? 0;
                                                        },
                                                      );
                                                    },
                                                    decoration: InputDecoration(
                                                      contentPadding: const EdgeInsets.symmetric(
                                                        vertical: 8.5,
                                                      ),
                                                      hintText: 'Qty...',
                                                      hintStyle: const TextStyle(
                                                        color: Colors.black, // Ubah ke warna yang sesuai
                                                        fontWeight: FontWeight.w300,
                                                        fontSize: 14,
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8.0),
                                                        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8.0),
                                                        borderSide: const BorderSide(color: Colors.blue, width: 1.0),
                                                      ),
                                                    ),
                                                    keyboardType: TextInputType.number,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.allow(
                                                        RegExp(r'[0-9]'),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                IconButton(
                                                  style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets.all(0),
                                                    backgroundColor:
                                                        venusColor.floatButtonSalesColor, // Ubah ke warna yang sesuai
                                                    shape: const RoundedRectangleBorder(
                                                      side: BorderSide.none,
                                                      borderRadius: BorderRadius.all(
                                                        Radius.circular(
                                                          8,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _qty = int.tryParse(model.qtyController.text) ?? 0;
                                                      _konversisatuan =
                                                          int.tryParse(model.konversisatuanController.text) ?? 0;
                                                      debugPrint('konversi satuan $_konversisatuan');
                                                      _qty++; // Menambah jumlah
                                                      model.qtyController.text = _qty.toString();
                                                      _isi = _qty * _konversisatuan;

                                                      model.isiController.text = _isi.toString();
                                                    });
                                                  },
                                                  icon: const Icon(
                                                    Icons.add,
                                                    color: Colors.white, // Ubah ke warna yang sesuai
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Spacings.verSpace(
                                              20,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        'Harga',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.bold,
                                                            color: venusColor.lightBlack008),
                                                      ),
                                                    ],
                                                  ),
                                                  Spacings.verSpace(12),
                                                  const Divider(
                                                    height: 1,
                                                    color: venusColor.lightBlack009,
                                                  ),
                                                  Spacings.verSpace(37),
                                                  TextFormField(
                                                    controller: model.hargaController,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _harga = int.tryParse(value) ?? 0;
                                                        _harga = int.tryParse(hargaController.text) ?? 0;
                                                        _disctotal = int.tryParse(totalController.text) ?? 0;
                                                        _netto = _harga - _disctotal;
                                                        nettoController.text = _netto.toString();
                                                      });
                                                    },
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                          const EdgeInsets.only(left: 16, top: 6, bottom: 6),
                                                      hintText: 'Masukkan harga',
                                                      hintStyle: const TextStyle(
                                                        color: venusColor.lightBlack015,
                                                        fontWeight: FontWeight.w300,
                                                        fontSize: 14,
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8.0),
                                                        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8.0),
                                                        borderSide: const BorderSide(color: Colors.blue, width: 1.0),
                                                      ),
                                                    ),
                                                    keyboardType: TextInputType.number,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.allow(
                                                        RegExp(r'[0-9]'),
                                                      ),
                                                    ],
                                                  ),
                                                  Spacings.verSpace(
                                                    20,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Spacings.horSpace(10),
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  const Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        'ISI',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.bold,
                                                            color: venusColor.lightBlack008),
                                                      ),
                                                    ],
                                                  ),
                                                  Spacings.verSpace(12),
                                                  const Divider(
                                                    height: 1,
                                                    color: venusColor.lightBlack009,
                                                  ),
                                                  Spacings.verSpace(12),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          children: [
                                                            const Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  'Satuan',
                                                                  style: TextStyle(
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.w500,
                                                                    color: venusColor.lightBlack011,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Spacings.verSpace(5),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                SizedBox(
                                                                  height: 48,
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      Text(
                                                                        model.satuanisiController.text,
                                                                        style: const TextStyle(
                                                                          color: venusColor.black,
                                                                          fontWeight: FontWeight.w400,
                                                                          fontSize: 17,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Spacings.horSpace(10),
                                                      Expanded(
                                                        child: Column(
                                                          children: [
                                                            const Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  'Jumlah',
                                                                  style: TextStyle(
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.w500,
                                                                    color: venusColor.lightBlack011,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Spacings.verSpace(5),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                SizedBox(
                                                                  height: 48,
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      Text(
                                                                        model.isiController.text,
                                                                        style: const TextStyle(
                                                                          color: venusColor.black,
                                                                          fontWeight: FontWeight.w400,
                                                                          fontSize: 17,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Spacings.verSpace(
                                                    20,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            const Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Discount (%)',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: venusColor.lightBlack008),
                                                ),
                                              ],
                                            ),
                                            Spacings.verSpace(12),
                                            const Divider(
                                              height: 1,
                                              color: venusColor.lightBlack009,
                                            ),
                                            Spacings.verSpace(12),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      const Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            '1',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w500,
                                                              color: venusColor.lightBlack011,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Spacings.verSpace(5),
                                                      TextFormField(
                                                        controller: model.diskon1Controller,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _disc1 = int.tryParse(value) ?? 0;
                                                            _harga = int.tryParse(model.hargaController.text) ?? 0;
                                                            double disc1Percentage =
                                                                (double.tryParse(model.diskon1Controller.text) ?? 0) /
                                                                    100;
                                                            double disc2Percentage =
                                                                (double.tryParse(model.diskon2Controller.text) ?? 0) /
                                                                    100;
                                                            double disc3Percentage =
                                                                (double.tryParse(model.diskon3Controller.text) ?? 0) /
                                                                    100;

                                                            // Calculate discounts
                                                            _diskon1 = (_harga * disc1Percentage).toInt();
                                                            _diskon2 = ((_harga - _diskon1) * disc2Percentage).toInt();
                                                            _diskon3 =
                                                                ((_harga - _diskon1 - _diskon2) * disc3Percentage)
                                                                    .toInt();

                                                            _discdirect =
                                                                int.tryParse(model.directController.text) ?? 0;
                                                            debugPrint('diskon1 $_diskon1');
                                                            debugPrint('diskon2 $_diskon2');
                                                            debugPrint('diskon3 $_diskon3');
                                                            // Calculate total
                                                            _disctotal = _diskon1 + _diskon2 + _diskon3 + _discdirect;
                                                            model.totalController.text = _disctotal.toString();
                                                          });
                                                        },
                                                        decoration: InputDecoration(
                                                          contentPadding:
                                                              const EdgeInsets.only(left: 16, top: 6, bottom: 6),
                                                          hintText: 'Masukkan diskon 1',
                                                          hintStyle: const TextStyle(
                                                            color: venusColor.lightBlack015,
                                                            fontWeight: FontWeight.w300,
                                                            fontSize: 14,
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(8.0),
                                                            borderSide:
                                                                const BorderSide(color: Colors.grey, width: 1.0),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(8.0),
                                                            borderSide:
                                                                const BorderSide(color: Colors.blue, width: 1.0),
                                                          ),
                                                        ),
                                                        keyboardType: TextInputType.number,
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter.allow(
                                                            RegExp(r'[0-9]'),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Spacings.horSpace(10),
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      const Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            '2',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w500,
                                                              color: venusColor.lightBlack011,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Spacings.verSpace(5),
                                                      TextFormField(
                                                        controller: model.diskon2Controller,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _disc2 = int.tryParse(value) ?? 0;
                                                            _disc1 = int.tryParse(value) ?? 0;
                                                            _harga = int.tryParse(model.hargaController.text) ?? 0;
                                                            double disc1Percentage =
                                                                (double.tryParse(model.diskon1Controller.text) ?? 0) /
                                                                    100;
                                                            double disc2Percentage =
                                                                (double.tryParse(model.diskon2Controller.text) ?? 0) /
                                                                    100;
                                                            double disc3Percentage =
                                                                (double.tryParse(model.diskon3Controller.text) ?? 0) /
                                                                    100;

                                                            // Calculate discounts
                                                            _diskon1 = (_harga * disc1Percentage).toInt();
                                                            _diskon2 = ((_harga - _diskon1) * disc2Percentage).toInt();
                                                            _diskon3 =
                                                                ((_harga - _diskon1 - _diskon2) * disc3Percentage)
                                                                    .toInt();

                                                            _discdirect =
                                                                int.tryParse(model.directController.text) ?? 0;
                                                            debugPrint('diskon1 $_diskon1');
                                                            debugPrint('diskon2 $_diskon2');
                                                            debugPrint('diskon3 $_diskon3');
                                                            // Calculate total
                                                            _disctotal = _diskon1 + _diskon2 + _diskon3 + _discdirect;
                                                            model.totalController.text = _disctotal.toString();
                                                          });
                                                        },
                                                        decoration: InputDecoration(
                                                          contentPadding:
                                                              const EdgeInsets.only(left: 16, top: 6, bottom: 6),
                                                          hintText: 'Masukkan diskon 2',
                                                          hintStyle: const TextStyle(
                                                            color: venusColor.lightBlack015,
                                                            fontWeight: FontWeight.w300,
                                                            fontSize: 14,
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(8.0),
                                                            borderSide:
                                                                const BorderSide(color: Colors.grey, width: 1.0),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(8.0),
                                                            borderSide:
                                                                const BorderSide(color: Colors.blue, width: 1.0),
                                                          ),
                                                        ),
                                                        keyboardType: TextInputType.number,
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter.allow(
                                                            RegExp(r'[0-9]'),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Spacings.horSpace(10),
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      const Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            '3',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w500,
                                                              color: venusColor.lightBlack011,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Spacings.verSpace(5),
                                                      TextFormField(
                                                        controller: model.diskon3Controller,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _disc3 = int.tryParse(value) ?? 0;
                                                            _disc1 = int.tryParse(value) ?? 0;
                                                            _harga = int.tryParse(model.hargaController.text) ?? 0;
                                                            double disc1Percentage =
                                                                (double.tryParse(model.diskon1Controller.text) ?? 0) /
                                                                    100;
                                                            double disc2Percentage =
                                                                (double.tryParse(model.diskon2Controller.text) ?? 0) /
                                                                    100;
                                                            double disc3Percentage =
                                                                (double.tryParse(model.diskon3Controller.text) ?? 0) /
                                                                    100;

                                                            // Calculate discounts
                                                            _diskon1 = (_harga * disc1Percentage).toInt();
                                                            _diskon2 = ((_harga - _diskon1) * disc2Percentage).toInt();
                                                            _diskon3 =
                                                                ((_harga - _diskon1 - _diskon2) * disc3Percentage)
                                                                    .toInt();

                                                            _discdirect =
                                                                int.tryParse(model.directController.text) ?? 0;
                                                            debugPrint('diskon1 $_diskon1');
                                                            debugPrint('diskon2 $_diskon2');
                                                            debugPrint('diskon3 $_diskon3');
                                                            // Calculate total
                                                            _disctotal = _diskon1 + _diskon2 + _diskon3 + _discdirect;
                                                            model.totalController.text = _disctotal.toString();
                                                          });
                                                        },
                                                        decoration: InputDecoration(
                                                          contentPadding:
                                                              const EdgeInsets.only(left: 16, top: 6, bottom: 6),
                                                          hintText: 'Masukkan diskon 3',
                                                          hintStyle: const TextStyle(
                                                            color: venusColor.lightBlack015,
                                                            fontWeight: FontWeight.w300,
                                                            fontSize: 14,
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(8.0),
                                                            borderSide:
                                                                const BorderSide(color: Colors.grey, width: 1.0),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(8.0),
                                                            borderSide:
                                                                const BorderSide(color: Colors.blue, width: 1.0),
                                                          ),
                                                        ),
                                                        keyboardType: TextInputType.number,
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter.allow(
                                                            RegExp(r'[0-9]'),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Spacings.verSpace(
                                              20,
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            const Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Summary',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: venusColor.lightBlack008),
                                                ),
                                              ],
                                            ),
                                            Spacings.verSpace(12),
                                            const Divider(
                                              height: 1,
                                              color: venusColor.lightBlack009,
                                            ),
                                            Spacings.verSpace(12),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      const Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Netto',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w500,
                                                              color: venusColor.lightBlack011,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Spacings.verSpace(5),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          SizedBox(
                                                            height: 48,
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Text(
                                                                  model.nettoController.text,
                                                                  style: const TextStyle(
                                                                    color: venusColor.black,
                                                                    fontWeight: FontWeight.w400,
                                                                    fontSize: 17,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Spacings.horSpace(10),
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      const Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Subtotal',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w500,
                                                              color: venusColor.lightBlack011,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Spacings.verSpace(5),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          SizedBox(
                                                            height: 48,
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Text(
                                                                  model.subtotalController.text,
                                                                  style: const TextStyle(
                                                                    color: venusColor.black,
                                                                    fontWeight: FontWeight.w400,
                                                                    fontSize: 17,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Spacings.horSpace(10),
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      const Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Berat',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w500,
                                                              color: venusColor.lightBlack011,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Spacings.verSpace(5),
                                                      TextFormField(
                                                        controller: model.beratController,
                                                        decoration: InputDecoration(
                                                          contentPadding:
                                                              const EdgeInsets.only(left: 16, top: 6, bottom: 6),
                                                          hintText: 'Masukkan berat',
                                                          hintStyle: const TextStyle(
                                                            color: venusColor.lightBlack015,
                                                            fontWeight: FontWeight.w300,
                                                            fontSize: 14,
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(8.0),
                                                            borderSide:
                                                                const BorderSide(color: Colors.grey, width: 1.0),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(8.0),
                                                            borderSide:
                                                                const BorderSide(color: Colors.blue, width: 1.0),
                                                          ),
                                                        ),
                                                        keyboardType: TextInputType.number,
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter.allow(
                                                            RegExp(r'[0-9]'),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Spacings.verSpace(108),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              childCount: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(
                  left: 30,
                  bottom: 30,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // ignore: unused_local_variable
                          final bool response = await model.updateOrderJualDetailModel(
                            intNomorHeader: widget.param.header?.intNomor ?? 0,
                            intNomorDetail: widget.param.header?.intNomor ?? 0,
                            intNomorMSatuan1: model.selectedSatuanBarang?.intNomor ?? 0,
                            decJumlah1: int.parse(model.qtyController.text),
                            decNetto: int.tryParse(model.nettoController.text.replaceAll(RegExp(r'[^\d-]'), '')) ?? 0,
                            decDisc3: int.tryParse(model.diskon3Controller.text.replaceAll(RegExp(r'[^\d-]'), '')) ?? 0,
                            decDisc2: int.tryParse(model.diskon2Controller.text.replaceAll(RegExp(r'[^\d-]'), '')) ?? 0,
                            decDisc1: int.tryParse(model.diskon1Controller.text.replaceAll(RegExp(r'[^\d-]'), '')) ?? 0,
                            decJumlahUnit: int.tryParse(isiController.text.replaceAll(RegExp(r'[^\d-]'), '')) ?? 0,
                            decHarga: int.tryParse(model.hargaController.text.replaceAll(RegExp(r'[^\d-]'), '')) ?? 0,
                            decSubTotal:
                                int.tryParse(model.subtotalController.text.replaceAll(RegExp(r'[^\d-]'), '')) ?? 0,
                            decBerat: int.tryParse(model.beratController.text.replaceAll(RegExp(r'[^\d-]'), '')) ?? 0,
                          );
                          if (response) {
                            showDialog(
                              // ignore: use_build_context_synchronously
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Succes'),
                                  content: const Text('Data Berhasil Disimpan'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          Routes.editorderjual,
                                          arguments: EditOrderJualParam(
                                            nomor: widget.param.header?.intNomor,
                                            mode: 'edit',
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            showDialog(
                              // ignore: use_build_context_synchronously
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Gagal'),
                                  content: const Text('Data Gagal Disimpan'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 124,
                            vertical: 16,
                          ),
                          backgroundColor: venusColor.floatButtonSalesColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Add Detail Barang',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget satuanBarang(BuildContext context, SatuanBarangGetDataContent item) {
    return Text(
      '${item.vcNama}',
      style: const TextStyle(
        color: venusColor.black,
      ),
    );
  }
}
