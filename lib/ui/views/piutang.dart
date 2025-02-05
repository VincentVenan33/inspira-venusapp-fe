import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';
import 'package:venus/core/app_constants/colors.dart';
import 'package:venus/core/app_constants/route.dart';
import 'package:venus/core/networks/omset_piutang_get_data_dto_network.dart';
import 'package:venus/core/networks/total_omset_piutang_get_data_dto_network.dart';
import 'package:venus/core/services/shared_preferences_service.dart';
import 'package:venus/core/utilities/string_utils.dart';
import 'package:venus/core/utilities/text_styles.dart';
import 'package:venus/core/view_models/piutang_view_model.dart';
import 'package:venus/core/view_models/view_model.dart';
import 'package:venus/ui/shared/loading_overlay.dart';
import 'package:venus/ui/shared/spacings.dart';
import 'package:venus/ui/shared/unfocus_helper.dart';
import 'package:venus/ui/views/navbar/navbar_sales_view.dart';

class PiutangDashboardView extends ConsumerStatefulWidget {
  const PiutangDashboardView({super.key});

  @override
  ConsumerState<PiutangDashboardView> createState() => _PiutangDashboardViewState();
}

double scrollPosition = 0.0;
bool tabIsHide = false;

class _PiutangDashboardViewState extends ConsumerState<PiutangDashboardView> {
  @override
  Widget build(BuildContext context) {
    return ViewModel<PiutangViewModel>(
        model: PiutangViewModel(
          omsetpiutangGetDataDTOApi: ref.read(omsetpiutangGetDataDTOApi),
          totalomsetpiutangGetDataDTOApi: ref.read(totalOmsetpiutangGetDataDTOApi),
          sharedPreferencesService: ref.read(sharedPrefProvider),
        ),
        onModelReady: (PiutangViewModel model) => model.initModel(),
        builder: (_, PiutangViewModel model, __) {
          return LoadingOverlay(
            isLoading: model.busy,
            child: UnfocusHelper(
              child: SafeArea(
                child: Scaffold(
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
                      child: CustomScrollView(
                        slivers: [
                          SliverStickyHeader.builder(
                            sticky: true,
                            builder: (context, state) {
                              return Column(
                                children: [
                                  Visibility(
                                    visible: tabIsHide == false,
                                    maintainAnimation: true,
                                    maintainState: true,
                                    child: AnimatedSlide(
                                      curve: Curves.easeIn,
                                      duration: const Duration(milliseconds: 200),
                                      offset: tabIsHide == false ? Offset.zero : const Offset(0, -1),
                                      child: Column(
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(color: venusColor.backgroundAtas),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                    top: 20,
                                                    left: 14,
                                                    right: 24,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      IconButton(
                                                        onPressed: () {
                                                          Navigator.pushNamedAndRemoveUntil(
                                                            context,
                                                            Routes.navBarSales,
                                                            (route) => false,
                                                            arguments: NavbarSalesViewParam(
                                                              menuIndex: 0,
                                                              // 1 = Aktifitas Sales
                                                            ),
                                                          );
                                                        },
                                                        icon: const Icon(
                                                          Icons.arrow_back,
                                                        ),
                                                      ),
                                                      Spacings.horSpace(12),
                                                      Container(
                                                        width: 48,
                                                        height: 48,
                                                        decoration: const BoxDecoration(
                                                          shape: BoxShape.circle, // Makes the container circular
                                                        ),
                                                        child: ClipOval(
                                                          child: Image.network(
                                                            'https://images.unsplash.com/photo-1638803040283-7a5ffd48dad5?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1974&q=80', // Replace with your image URL
                                                            fit: BoxFit
                                                                .cover, // You can choose the BoxFit that suits your needs
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: SizedBox(
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(left: 10),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  model.nama ?? '',
                                                                  style: const TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  model.admingrup ?? '',
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: const ImageIcon(
                                                          AssetImage(
                                                            'assets/icons/notification-bing.png',
                                                          ),
                                                        ),
                                                        onPressed: () {},
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Spacings.verSpace(25),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(
                                      top: 24,
                                      left: 24,
                                      right: 24,
                                    ),
                                    color: venusColor.white,
                                    child: Column(children: [
                                      const Text(
                                        'TOTAL PIUTANG',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: venusColor.lightBlack008,
                                        ),
                                      ),
                                      Spacings.verSpace(12),
                                      const Divider(
                                        height: 1,
                                        color: venusColor.lightBlack009,
                                      ),
                                      Spacings.verSpace(23),
                                    ]),
                                  ),
                                ],
                              );
                            },
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, i) => (Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 24,
                                        left: 24,
                                        right: 24,
                                      ),
                                      child: Column(
                                        children: [
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: model.piutang.length,
                                            itemBuilder: (context, index) {
                                              return Column(
                                                children: [
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(
                                                                  5.914), // Add border radius here
                                                              color: const Color.fromRGBO(36, 149, 174, 0.80),
                                                            ),
                                                            alignment: Alignment.center,
                                                            padding: const EdgeInsets.only(
                                                              top: 5,
                                                              left: 9,
                                                              right: 9.92,
                                                              bottom: 4.46,
                                                            ),
                                                            child: Text(
                                                              '${model.piutang[index].transaksikode}',
                                                              style: const TextStyle(
                                                                color: venusColor.white,
                                                                fontWeight: FontWeight.w500,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ),
                                                          Spacings.verSpace(10.43),
                                                          Text(
                                                            StringUtils.rupiahFormat(
                                                              double.parse(model.piutang[index].total != null
                                                                  ? '${model.piutang[index].total}'
                                                                  : '0'),
                                                              symbol: 'Rp. ',
                                                            ),
                                                            style: buildTextStyle(
                                                              fontSize: 15.376,
                                                              fontWeight: 400,
                                                              color: venusColor.lightBlack010,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        DateFormat('dd MMMM yyyy').format(
                                                          DateTime.parse(model.piutang[index].transaksitanggal ?? ''),
                                                        ),
                                                        style: buildTextStyle(
                                                          fontSize: 15.376,
                                                          fontWeight: 700,
                                                          color: venusColor.lightBlack011,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Spacings.verSpace(9),
                                                  const Column(
                                                    children: [
                                                      Divider(
                                                        height: 1,
                                                        color: venusColor.lightBlack009,
                                                      ),
                                                    ],
                                                  ),
                                                  Spacings.verSpace(20.82),
                                                ],
                                              );
                                            },
                                          ),
                                          Spacings.verSpace(50),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                                childCount: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  bottomSheet: Container(
                    color: venusColor.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              color: venusColor.lightBlack011,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            StringUtils.rupiahFormat(
                              double.parse(model.totalpiutang?.total != null ? '${model.totalpiutang?.total}' : '0'),
                              symbol: 'Rp. ',
                            ),
                            style: const TextStyle(
                              color: venusColor.lightBlack011,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
