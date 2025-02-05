import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';
import 'package:venus/core/app_constants/colors.dart';
import 'package:venus/core/app_constants/route.dart';
import 'package:venus/core/models/get_data/area_get_data_dto.dart';
import 'package:venus/core/models/get_data/get_data_dto.dart';
import 'package:venus/core/models/get_data/valuta_get_data_dto.dart';
import 'package:venus/core/networks/area_get_data_dto_network.dart';
import 'package:venus/core/networks/delete_order_jual_detail_dto.dart';
import 'package:venus/core/networks/get_data_dto_network.dart';
import 'package:venus/core/networks/jenis_penjualan_get_data_dto_network.dart';
import 'package:venus/core/networks/order_jual_get_data_dto_network.dart';
import 'package:venus/core/networks/update_order_jual_only_dto.dart';
import 'package:venus/core/networks/valuta_get_data_dto_network.dart';
import 'package:venus/core/services/shared_preferences_service.dart';
import 'package:venus/core/utilities/string_utils.dart';
import 'package:venus/core/view_models/orderjual/edit/updateorderjual_view_model.dart';
import 'package:venus/core/view_models/view_model.dart';
import 'package:venus/ui/shared/loading_overlay.dart';
import 'package:venus/ui/shared/spacings.dart';
import 'package:venus/ui/shared/unfocus_helper.dart';
import 'package:venus/ui/views/navbar/navbar_sales_view.dart';
import 'package:venus/ui/views/orderjual/edit/edititemdetail.dart';
import 'package:venus/ui/views/orderjual/edit/editprodukkatalog.dart';

class EditOrderJualParam {
  const EditOrderJualParam({
    required this.nomor,
    required this.mode,
  });

  final int? nomor;
  final String? mode;
}

class EditOrderJual extends ConsumerStatefulWidget {
  const EditOrderJual({
    super.key,
    required this.param,
  });

  final EditOrderJualParam param;

  @override
  ConsumerState<EditOrderJual> createState() => _EditOrderJualState();
}

class _EditOrderJualState extends ConsumerState<EditOrderJual> {
  final TextEditingController customerController = TextEditingController();
  final TextEditingController diskonprosentaseController = TextEditingController(text: '0');
  final TextEditingController diskonnominalController = TextEditingController();
  final TextEditingController dppController = TextEditingController();
  final TextEditingController ppnnominalController = TextEditingController();
  final TextEditingController biayalainController = TextEditingController(text: '0');
  final TextEditingController totalController = TextEditingController();
  final TextEditingController salesController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController satuanqtyController = TextEditingController();
  final TextEditingController isiController = TextEditingController();
  final TextEditingController satuanisiController = TextEditingController();
  final TextEditingController nettoController = TextEditingController();
  final TextEditingController subtotalController = TextEditingController();

  final int _subtotal = 0;
  final int _diskonnominal = 0;
  final int _dpp = 0;
  final int _ppn = 0;
  final int _biayalain = 0;
  final int _total = 0;

  @override
  void initState() {
    super.initState();
  }

  String? selectedPPN = '0';

  double scrollPosition = 0.0;
  bool tabIsHide = false;

  @override
  Widget build(BuildContext context) {
    return ViewModel<UpdateOrderJualViewModel>(
      model: UpdateOrderJualViewModel(
        orderJualGetDataDTOApi: ref.read(orderJualGetDataDTOApi),
        getDataDTOApi: ref.read(getDataDTOApi),
        jenisPenjualanGetDataDTOApi: ref.read(jenisPenjualanGetDataDTOApi),
        areaGetDataDTOApi: ref.read(areaGetDataDTOApi),
        valutaGetDataDTOApi: ref.read(valutaGetDataDTOApi),
        sharedPreferencesService: ref.read(sharedPrefProvider),
        setUpdateOrderJualOnlyDTOApi: ref.read(setUpdateOrderJualOnlyDTOApi),
        setDeleteOrderJualDetailDTOApi: ref.read(setDeleteOrderJualDetailDTOApi),
        nomor: widget.param.nomor!,
      ),
      onModelReady: (UpdateOrderJualViewModel model) => model.initModel(),
      builder: (_, UpdateOrderJualViewModel model, __) {
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
                        SliverStickyHeader(
                          sticky: true,
                          header: Column(
                            children: [
                              Column(
                                children: [
                                  AnimatedSlide(
                                    curve: Curves.easeIn,
                                    duration: const Duration(milliseconds: 200),
                                    offset: tabIsHide == false ? Offset.zero : const Offset(0, -1),
                                    child: Column(
                                      children: [
                                        AppBar(
                                          backgroundColor: venusColor.backgroundAtas,
                                          leading: IconButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            icon: const Icon(
                                              Icons.arrow_back,
                                            ),
                                          ),
                                          title: Text(
                                            'Edit Order Jual',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: tabIsHide == false ? 18 : 14,
                                            ),
                                          ),
                                          // centerTitle: true,
                                          toolbarHeight: tabIsHide == false ? kToolbarHeight : kToolbarHeight - 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, i) => Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 15,
                                      right: 19,
                                    ),
                                    child: Column(
                                      children: [
                                        const Row(
                                          children: [
                                            Text(
                                              'Kode*',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: venusColor.lightBlack011,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacings.horSpace(5),
                                        TextFormField(
                                          controller: model.kodeController,
                                          decoration: InputDecoration(
                                            contentPadding: const EdgeInsets.only(left: 16, top: 6, bottom: 6),
                                            hintText: model.kodeController.text,
                                            hintStyle: const TextStyle(
                                              color: venusColor.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
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
                                          readOnly: true,
                                        ),
                                        Spacings.verSpace(14),
                                        const Row(
                                          children: [
                                            Text(
                                              'Tanggal',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                color: venusColor.lightBlack011,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacings.verSpace(5),
                                        Container(
                                          width: double.infinity,
                                          height: 48,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                DateFormat('dd/MM/yyyy').format(model.selectedDate),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: venusColor.black,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const Icon(
                                                Icons.calendar_month,
                                                color: venusColor.lightBlack016,
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Spacings.verSpace(14),
                                        const Row(
                                          children: [
                                            Text(
                                              'Tanggal Kirim',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                color: venusColor.lightBlack011,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacings.verSpace(5),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 48,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.all(
                                                8,
                                              ),
                                              side: const BorderSide(
                                                color: Colors.grey,
                                                width: 1.0,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              backgroundColor: venusColor.transparent,
                                              surfaceTintColor: venusColor.transparent,
                                              shadowColor: const Color(0x00000000),
                                            ),
                                            onPressed: () async {
                                              final DateTime? picked = await showDatePicker(
                                                context: context,
                                                initialDate:
                                                    model.selectedDateKirim, // Default to today if not selected
                                                firstDate: DateTime(2000),
                                                lastDate: DateTime(2101),
                                              );

                                              if (picked != null && picked != model.selectedDateKirim) {
                                                setState(() {
                                                  model.selectedDateKirim = picked;
                                                });
                                              }
                                            },
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  DateFormat('dd/MM/yyyy').format(model.selectedDateKirim),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: venusColor.black,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.calendar_month,
                                                  color: venusColor.lightBlack016,
                                                  size: 16,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Spacings.verSpace(14),
                                        const Row(
                                          children: [
                                            Text(
                                              'Gudang',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                color: venusColor.lightBlack011,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacings.verSpace(5),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              Routes.editgudangorderjual,
                                              arguments: model,
                                            ).then((withResponse) {
                                              if (withResponse == false) {
                                                return;
                                              }
                                              if (model.selectedGudang != null) {
                                                GetDataContent value = model.selectedGudang!;
                                                setState(() {
                                                  model.gudangController.text = "${value.vcKode} - ${value.vcNama}";
                                                });
                                              }
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.all(0),
                                            backgroundColor: Color(venusColor.transparent.value),
                                            surfaceTintColor: venusColor.transparent,
                                            shadowColor: venusColor.transparent,
                                            shape: const RoundedRectangleBorder(
                                              side: BorderSide.none,
                                              borderRadius: BorderRadius.all(
                                                Radius.zero,
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      model.gudangController.text,
                                                      style: const TextStyle(
                                                        color: venusColor.black,
                                                        fontWeight: FontWeight.w400,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            model.gudangController.clear();
                                                          });
                                                        },
                                                        icon: const Icon(
                                                          Icons.refresh,
                                                          color: venusColor.lightBlack014,
                                                        ),
                                                      ),
                                                      const Icon(
                                                        Icons.search,
                                                        color: venusColor.lightBlack014,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Spacings.verSpace(14),
                                        const Row(
                                          children: [
                                            Text(
                                              'Jatuh Tempo',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                color: venusColor.lightBlack011,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacings.verSpace(5),
                                        TextFormField(
                                          controller: model.jatuhtempoController,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: venusColor.black,
                                          ),
                                          decoration: InputDecoration(
                                            contentPadding: const EdgeInsets.only(left: 16, top: 6, bottom: 6),
                                            hintText: 'Jatuh Tempo (Hari)',
                                            hintStyle: const TextStyle(
                                              color: venusColor.lightBlack015,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
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
                                          keyboardType:
                                              const TextInputType.numberWithOptions(signed: true, decimal: false),
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                          ],
                                        ),
                                        Spacings.verSpace(14),
                                        const Row(
                                          children: [
                                            Text(
                                              'Pembayaran',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                color: venusColor.lightBlack011,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacings.verSpace(5),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: DropdownButton<int>(
                                                value: model.selectedPembayaran,
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    model.setselectedPembayaran(newValue ?? 0);
                                                  });
                                                },
                                                isExpanded: true,
                                                underline: Container(),
                                                items: const [
                                                  DropdownMenuItem(
                                                    value: 0,
                                                    enabled: false,
                                                    child: Text('Pilih Pembayaran'),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 1,
                                                    child: Text('CBD'),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 2,
                                                    child: Text('COD'),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 3,
                                                    child: Text('CREDIT'),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 4,
                                                    child: Text('CGD-TC'),
                                                  ),
                                                ],
                                                icon: const Icon(Icons.arrow_drop_down),
                                                iconSize: 24,
                                                alignment: AlignmentDirectional.centerEnd, // Alignment for the icon
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacings.verSpace(14),
                                        const Row(
                                          children: [
                                            Text(
                                              'Jenis',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                color: venusColor.lightBlack011,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacings.verSpace(5),
                                        ElevatedButton(
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 29,
                                                    vertical: 29,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: venusColor.lightBlack020,
                                                      width: 1,
                                                    ),
                                                    borderRadius: const BorderRadius.only(
                                                      topLeft: Radius.circular(25),
                                                      topRight: Radius.circular(25),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          const Text(
                                                            'Browse Jenis Penjualan',
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                            },
                                                            icon: const Icon(Icons.close),
                                                          ),
                                                        ],
                                                      ),
                                                      Spacings.verSpace(8),
                                                      Expanded(
                                                        child: ListView.builder(
                                                          shrinkWrap: true,
                                                          itemCount: model.jenispenjualan.length,
                                                          itemBuilder: (context, index) {
                                                            return RadioListTile(
                                                              tileColor: venusColor.transparent,
                                                              title: Text(
                                                                model.jenispenjualan[index].vcNama,
                                                              ),
                                                              groupValue: model.selectedJenisPenjualan,
                                                              value: model.jenispenjualan[index],
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  model.setselectedjenispenjualan(value);
                                                                });
                                                                Navigator.of(context).pop(true);
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.all(0),
                                            backgroundColor: Color(venusColor.transparent.value),
                                            surfaceTintColor: venusColor.transparent,
                                            shadowColor: venusColor.transparent,
                                            shape: const RoundedRectangleBorder(
                                              side: BorderSide.none,
                                              borderRadius: BorderRadius.all(
                                                Radius.zero,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                model.selectedJenisPenjualan != null
                                                    ? model.selectedJenisPenjualan!.vcNama
                                                    : model.jenisPenjualanController.text,
                                                style: const TextStyle(
                                                  color: venusColor.black,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const Row(
                                                children: [
                                                  Icon(
                                                    Icons.search,
                                                    color: venusColor.lightBlack014,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Spacings.verSpace(14),
                                        const Row(
                                          children: [
                                            Text(
                                              'Pelanggan*',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                color: venusColor.lightBlack011,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacings.verSpace(5),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              Routes.editpelangganorderjual,
                                              arguments: model,
                                            ).then(
                                              (withResponse) {
                                                if (withResponse == false) {
                                                  return;
                                                }
                                                if (model.selectedCustomer != null) {
                                                  GetDataContent value = model.selectedCustomer!;
                                                  String? sales = value.namasales;
                                                  String? area = value.namaarea;
                                                  setState(
                                                    () {
                                                      model.customerController.text = value.vcNama;
                                                      model.salesController.text = sales!;
                                                      model.areaController.text = area!;
                                                      model.setselectedarea(
                                                        AreaGetDataContent(
                                                          intNomor: value.intNomorMArea ?? 0,
                                                          vcNama: value.namaarea ?? '',
                                                        ),
                                                      );
                                                      model.setselectedsales(
                                                        GetDataContent(
                                                          intNomor: value.intNomorMSales ?? 0,
                                                          vcNama: value.namasales ?? '',
                                                          vcKode: value.kodesales ?? '',
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }
                                              },
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.all(0),
                                            backgroundColor: Color(venusColor.transparent.value),
                                            surfaceTintColor: venusColor.transparent,
                                            shadowColor: venusColor.transparent,
                                            shape: const RoundedRectangleBorder(
                                              side: BorderSide.none,
                                              borderRadius: BorderRadius.all(
                                                Radius.zero,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                model.customerController.text,
                                                style: const TextStyle(
                                                  color: venusColor.black,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        model.customerController.clear();
                                                      });
                                                    },
                                                    icon: const Icon(
                                                      Icons.refresh,
                                                      color: venusColor.lightBlack014,
                                                    ),
                                                  ),
                                                  const Icon(
                                                    Icons.search,
                                                    color: venusColor.lightBlack014,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Spacings.verSpace(14),
                                        const Row(
                                          children: [
                                            Text(
                                              'BEX',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                color: venusColor.lightBlack011,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacings.verSpace(5),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              Routes.editsalesorderjual,
                                              arguments: model,
                                            ).then((withResponse) {
                                              if (withResponse == false) {
                                                return;
                                              }
                                              if (model.selectedSales != null) {
                                                GetDataContent value = model.selectedSales!;
                                                setState(() {
                                                  model.salesController.text = value.vcNama;
                                                });
                                              }
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.all(0),
                                            backgroundColor: Color(venusColor.transparent.value),
                                            surfaceTintColor: venusColor.transparent,
                                            shadowColor: venusColor.transparent,
                                            shape: const RoundedRectangleBorder(
                                              side: BorderSide.none,
                                              borderRadius: BorderRadius.all(
                                                Radius.zero,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                model.salesController.text,
                                                style: const TextStyle(
                                                  color: venusColor.black,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        model.salesController.clear();
                                                      });
                                                    },
                                                    icon: const Icon(
                                                      Icons.refresh,
                                                      color: venusColor.lightBlack014,
                                                    ),
                                                  ),
                                                  const Icon(
                                                    Icons.search,
                                                    color: venusColor.lightBlack014,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Spacings.verSpace(14),
                                        const Row(
                                          children: [
                                            Text(
                                              'Area',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                color: venusColor.lightBlack011,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacings.verSpace(5),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              Routes.editareaorderjual,
                                              arguments: model,
                                            ).then((withResponse) {
                                              if (withResponse == false) {
                                                return;
                                              }
                                              if (model.selectedArea != null) {
                                                AreaGetDataContent value = model.selectedArea!;
                                                setState(() {
                                                  model.areaController.text = value.vcNama;
                                                });
                                              }
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.all(0),
                                            backgroundColor: Color(venusColor.transparent.value),
                                            surfaceTintColor: venusColor.transparent,
                                            shadowColor: venusColor.transparent,
                                            shape: const RoundedRectangleBorder(
                                              side: BorderSide.none,
                                              borderRadius: BorderRadius.all(
                                                Radius.zero,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                model.areaController.text,
                                                style: const TextStyle(
                                                  color: venusColor.black,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        model.areaController.clear();
                                                      });
                                                    },
                                                    icon: const Icon(
                                                      Icons.refresh,
                                                      color: venusColor.lightBlack014,
                                                    ),
                                                  ),
                                                  const Icon(
                                                    Icons.search,
                                                    color: venusColor.lightBlack014,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Spacings.verSpace(14),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  const Row(
                                                    children: [
                                                      Text(
                                                        'Valuta',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 14,
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
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            showModalBottomSheet(
                                                              context: context,
                                                              builder: (BuildContext context) {
                                                                return Container(
                                                                  padding: const EdgeInsets.symmetric(
                                                                    horizontal: 29,
                                                                    vertical: 29,
                                                                  ),
                                                                  constraints: BoxConstraints(
                                                                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                                                                  ),
                                                                  decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                      color: venusColor.lightBlack020,
                                                                      width: 1,
                                                                    ),
                                                                    borderRadius: const BorderRadius.only(
                                                                      topLeft: Radius.circular(25),
                                                                      topRight: Radius.circular(25),
                                                                    ),
                                                                  ),
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          const Text(
                                                                            'Browse Valuta',
                                                                            textAlign: TextAlign.left,
                                                                            style: TextStyle(
                                                                              fontSize: 18,
                                                                              fontWeight: FontWeight.w600,
                                                                            ),
                                                                          ),
                                                                          IconButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            icon: const Icon(Icons.close),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Spacings.verSpace(8),
                                                                      Expanded(
                                                                        child: ListView.builder(
                                                                          shrinkWrap: true,
                                                                          physics: const NeverScrollableScrollPhysics(),
                                                                          itemCount: model.valuta.length,
                                                                          itemBuilder: (context, index) {
                                                                            return RadioListTile(
                                                                              tileColor: venusColor.transparent,
                                                                              title: Text(
                                                                                model.valuta[index].vcNama,
                                                                              ),
                                                                              groupValue: model.selectedValuta,
                                                                              value: model.valuta[index],
                                                                              onChanged: (value) {
                                                                                setState(() {
                                                                                  model.setselectedvaluta(value);
                                                                                });
                                                                                Navigator.of(context).pop(true);
                                                                              },
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            padding: const EdgeInsets.all(0),
                                                            backgroundColor: Color(venusColor.transparent.value),
                                                            surfaceTintColor: venusColor.transparent,
                                                            shadowColor: venusColor.transparent,
                                                            shape: const RoundedRectangleBorder(
                                                              side: BorderSide.none,
                                                              borderRadius: BorderRadius.all(
                                                                Radius.zero,
                                                              ),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                model.selectedValuta != null
                                                                    ? model.selectedValuta!.vcNama
                                                                    : model.valutaController.text,
                                                                style: const TextStyle(
                                                                  color: venusColor.black,
                                                                  fontWeight: FontWeight.w400,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                              const Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons.search,
                                                                    color: venusColor.lightBlack014,
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Spacings.horSpace(12),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Row(
                                                    children: [
                                                      Text(
                                                        'Kurs',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 14,
                                                          color: venusColor.lightBlack011,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Spacings.verSpace(5),
                                                  TextFormField(
                                                    controller: model.kursController,
                                                    textAlign: TextAlign.right,
                                                    onChanged: (value) {},
                                                    decoration: InputDecoration(
                                                      contentPadding: const EdgeInsets.only(
                                                        left: 16,
                                                        top: 6,
                                                        bottom: 6,
                                                        right: 16,
                                                      ),
                                                      hintText: 'Masukkan Kurs',
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
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacings.verSpace(14),
                                        const Row(
                                          children: [
                                            Text(
                                              'Export / PPN',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                color: venusColor.lightBlack011,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacings.verSpace(5),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: DropdownButton<int>(
                                                value: model.selectedPPN,
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    model.setselectedPPN(newValue ?? 0);
                                                    model.hitung();
                                                  });
                                                },
                                                isExpanded: true,
                                                underline: Container(),
                                                items: const [
                                                  DropdownMenuItem(
                                                    value: 0,
                                                    child: Text('Export'),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 1,
                                                    child: Text('PPN'),
                                                  ),
                                                ],
                                                icon: const Icon(Icons.arrow_drop_down),
                                                iconSize: 24,
                                                alignment: AlignmentDirectional.centerEnd, // Alignment for the icon
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(
                                          color: Colors.grey,
                                        ),
                                        Spacings.verSpace(14),
                                        const Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'DETAIL BARANG',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: venusColor.lightBlack008,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacings.verSpace(14),
                                        const Divider(
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                  ListView.separated(
                                    padding: const EdgeInsets.only(
                                      top: 0,
                                      left: 15,
                                      right: 19,
                                    ),
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    separatorBuilder: (context, index) {
                                      return const Divider(
                                        color: Colors.grey,
                                      );
                                    },
                                    itemCount: model.orderjualdetail.length,
                                    itemBuilder: (contect, index) {
                                      // final detailItems = model.orderjualdetail[index];
                                      return ListTile(
                                        title: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              children: [
                                                Image.network(
                                                  'https://indraco.com/gmb/tanpalogo/TUGUBUAYA/TB-301.png',
                                                  width: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                              ],
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          '${model.orderjualdetail[index].kodeBarang}',
                                                          style: const TextStyle(
                                                            fontSize: 17,
                                                            fontWeight: FontWeight.bold,
                                                            color: venusColor.black,
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        onPressed: () async {
                                                          Navigator.pushNamed(
                                                            context,
                                                            Routes.updateeditDetailCatalog,
                                                            arguments: UpdateEditDetailOrderParam(
                                                              nomor: model.orderjualdetail[index].intNomor,
                                                              mode: 'edit',
                                                              header: model.orderjual,
                                                              detailItem: model.orderjualdetail,
                                                            ),
                                                          );
                                                        },
                                                        icon: const Icon(
                                                          Icons.edit,
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red, // Warna ikon hapus
                                                        ),
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return AlertDialog(
                                                                title: const Text('Hapus Data Detail Barang'),
                                                                content: const Text(
                                                                    'Apakah anda yakin menghapus detail barang ini?'),
                                                                actions: <Widget>[
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      TextButton(
                                                                        child: const Text('Ya'),
                                                                        onPressed: () async {
                                                                          bool success =
                                                                              await model.deleteOrderJualDetailModel(
                                                                            intDeleteUserID: 1,
                                                                            nomor:
                                                                                model.orderjualdetail[index].intNomor,
                                                                          );
                                                                          // ignore: use_build_context_synchronously
                                                                          Navigator.pop(context);
                                                                          // Tutup dialog konfirmasi pertama
                                                                          if (success) {
                                                                            // Jika berhasil, tampilkan dialog berhasil
                                                                            showDialog(
                                                                              // ignore: use_build_context_synchronously
                                                                              context: context,
                                                                              builder: (BuildContext context) {
                                                                                return AlertDialog(
                                                                                  title: const Text('Berhasil'),
                                                                                  content: const Text(
                                                                                      'Detail Barang berhasil dihapus.'),
                                                                                  actions: <Widget>[
                                                                                    TextButton(
                                                                                      child: const Text('OK'),
                                                                                      onPressed: () {
                                                                                        Navigator.pop(context);
                                                                                        model.initModel();
                                                                                        setState(() {
                                                                                          model.fetchOrderJual(
                                                                                              reload: true);
                                                                                        });
                                                                                      },
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              },
                                                                            );
                                                                          } else {
                                                                            // Jika gagal, tampilkan dialog gagal
                                                                            showDialog(
                                                                              // ignore: use_build_context_synchronously
                                                                              context: context,
                                                                              builder: (BuildContext context) {
                                                                                return AlertDialog(
                                                                                  title: const Text('Gagal'),
                                                                                  content: const Text(
                                                                                      'Gagal menghapus detail barang'),
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
                                                                      ),
                                                                      TextButton(
                                                                        child: const Text('Tidak'),
                                                                        onPressed: () {
                                                                          Navigator.pop(
                                                                              context); // Tutup dialog konfirmasi pertama
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  Spacings.verSpace(5),
                                                  Text(
                                                    '${model.orderjualdetail[index].vcNamaJual}',
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.w400,
                                                      color: venusColor.black,
                                                    ),
                                                  ),
                                                  Spacings.verSpace(5),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        '${model.orderjualdetail[index].decJumlahUnit.toString().replaceAll('.0', '')} ${model.orderjualdetail[index].satuan1}',
                                                        style: const TextStyle(
                                                          fontSize: 17,
                                                          fontWeight: FontWeight.w400,
                                                          color: venusColor.black,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Berat : ${model.orderjualdetail[index].decBerat}'
                                                            .toString()
                                                            .replaceAll('.0', ''),
                                                        style: const TextStyle(
                                                          fontSize: 17,
                                                          fontWeight: FontWeight.w400,
                                                          color: venusColor.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Spacings.verSpace(5),
                                                  Text(
                                                    StringUtils.rupiahFormat(
                                                      // ignore: unnecessary_null_comparison
                                                      double.parse(model.orderjualdetail[index].decSubTotal != null
                                                          ? '${model.orderjualdetail[index].decSubTotal}'
                                                          : '0'),
                                                      symbol: 'Subtotal (Rp) : ',
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.w400,
                                                      color: venusColor.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      top: 0,
                                      left: 15,
                                      right: 19,
                                    ),
                                    child: Divider(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 15,
                                      right: 19,
                                    ),
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
                                                    model.subtotalController.text =
                                                        '${model.orderjualdetail.fold(0, (sum, item) => sum + (item.decSubTotal?.toInt() ?? 0))}',
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
                                        Spacings.verSpace(14),
                                        const Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Discount',
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
                                          children: [
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        TextFormField(
                                                          controller: model.diskonprosentaseController,
                                                          onChanged: (value) {
                                                            model.hitung();
                                                          },
                                                          decoration: InputDecoration(
                                                            contentPadding:
                                                                const EdgeInsets.only(left: 16, top: 6, bottom: 6),
                                                            hintText: 'Masukkan diskon',
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
                                                    child: SizedBox(
                                                      height: 48,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          Text(
                                                            model.diskonnominalController.text,
                                                            style: const TextStyle(
                                                              color: venusColor.black,
                                                              fontWeight: FontWeight.w400,
                                                              fontSize: 17,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacings.verSpace(14),
                                        Column(
                                          children: [
                                            const Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Biaya',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: venusColor.lightBlack011,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Spacings.verSpace(5),
                                            SizedBox(
                                              height: 48,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        model.biayaController.text,
                                                        style: const TextStyle(
                                                          color: venusColor.black,
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 17,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacings.verSpace(14),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        const Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'UM 1',
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
                                                          controller: model.um1Controller,
                                                          textAlign: TextAlign.right,
                                                          onChanged: (value) {
                                                            model.hitung();
                                                          },
                                                          decoration: InputDecoration(
                                                            contentPadding: const EdgeInsets.only(
                                                              left: 16,
                                                              top: 6,
                                                              bottom: 6,
                                                              right: 16,
                                                            ),
                                                            hintText: 'Masukkan UM1',
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
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        const Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'UM 2',
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
                                                          controller: model.um2Controller,
                                                          textAlign: TextAlign.right,
                                                          onChanged: (value) {
                                                            model.hitung();
                                                          },
                                                          decoration: InputDecoration(
                                                            contentPadding: const EdgeInsets.only(
                                                              left: 16,
                                                              top: 6,
                                                              bottom: 6,
                                                              right: 16,
                                                            ),
                                                            hintText: 'Masukkan UM 2',
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
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        const Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'UM 3',
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
                                                          controller: model.um3Controller,
                                                          textAlign: TextAlign.right,
                                                          onChanged: (value) {
                                                            model.hitung();
                                                          },
                                                          decoration: InputDecoration(
                                                            contentPadding: const EdgeInsets.only(
                                                              left: 16,
                                                              top: 6,
                                                              bottom: 6,
                                                              right: 16,
                                                            ),
                                                            hintText: 'Masukkan UM 3',
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
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacings.verSpace(14),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  const Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Total UM',
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
                                                              model.totalumController.text,
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
                                                  Spacings.verSpace(14),
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
                                                        'DPP',
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
                                                              model.dppController.text,
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
                                                  Spacings.verSpace(14),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacings.verSpace(14),
                                        Column(
                                          children: [
                                            const Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'PPN',
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
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      const Expanded(
                                                        child: SizedBox(
                                                          height: 48,
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                '11%',
                                                                style: TextStyle(
                                                                  color: venusColor.black,
                                                                  fontWeight: FontWeight.w400,
                                                                  fontSize: 17,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Spacings.horSpace(10),
                                                      Expanded(
                                                        child: SizedBox(
                                                          height: 48,
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            children: [
                                                              Text(
                                                                model.ppnnominalController.text,
                                                                style: const TextStyle(
                                                                  color: venusColor.black,
                                                                  fontWeight: FontWeight.w400,
                                                                  fontSize: 17,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Spacings.verSpace(14),
                                        const Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Sisa',
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
                                                    model.sisaController.text,
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
                                  Spacings.verSpace(164),
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
                padding: const EdgeInsets.only(left: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                Routes.editkatalogproduk,
                                arguments: EditProdukKatalogParam(
                                  nomor: widget.param.nomor,
                                  mode: 'edit',
                                  header: model.orderjual,
                                  detailItem: model.orderjualdetail,
                                ),
                              );
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
                    Spacings.verSpace(28),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final bool response = await model.updateOrderJualOnlyModel(
                                dtTanggalKirim: DateFormat('yyyy-MM-dd').format(model.selectedDate),
                                intJenis: model.selectedPembayaran,
                                intJTHari: int.parse(model.jatuhtempoController.text),
                                decKurs: int.parse(model.kursController.text),
                                decUM1: int.parse(model.um1Controller.text),
                                decUM2: int.parse(model.um2Controller.text),
                                decUM3: int.parse(model.um3Controller.text),
                                decTotalUMC: int.parse(model.totalumController.text),
                                decTotalBiaya: int.parse(model.biayaController.text),
                                decSubTotal: int.parse(model.subtotalController.text),
                                decPPN: 11,
                                decPPNNominal: int.parse(model.ppnnominalController.text),
                                decDPP: int.parse(model.dppController.text),
                                decSisa: int.parse(model.sisaController.text),
                                intEksport: model.selectedPembayaran,
                              );
                              if (response) {
                                showDialog(
                                  // ignore: use_build_context_synchronously
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Succes'),
                                      content: const Text('Data Berhasil Diubah'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('OK'),
                                          onPressed: () {
                                            Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              Routes.navBarSales,
                                              (route) => false,
                                              arguments: NavbarSalesViewParam(
                                                menuIndex: 1,
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
                                      content: const Text('Data gagal diubah'),
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
                                horizontal: 144,
                                vertical: 16,
                              ),
                              backgroundColor: venusColor.floatButtonSalesColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Simpan',
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget customer(BuildContext context, GetDataContent item) {
    return Text(
      item.vcNama,
      style: const TextStyle(
        color: venusColor.black,
      ),
    );
  }

  Widget valuta(BuildContext context, ValutaGetDataContent item) {
    return Text(
      item.vcNama,
      style: const TextStyle(
        color: venusColor.black,
      ),
    );
  }
}
