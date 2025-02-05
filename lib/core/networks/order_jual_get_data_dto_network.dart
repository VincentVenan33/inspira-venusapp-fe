import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/dio.dart';
import 'package:venus/core/apis/order_jual_get_data_dto_api.dart';
import 'package:venus/core/models/get_data/order_jual_get_data_dto.dart';
import 'package:venus/core/models/parsed_response.dart';
import 'package:venus/core/services/dio_service.dart';
import 'package:venus/core/utilities/error_utils.dart';

final orderJualGetDataDTOApi = Provider<OrderJualGetDataDTOService>((ref) {
  final DioService dio = ref.read(dioProvider);
  return OrderJualGetDataDTOService(
    dio.getDio(domainType: DomainType.account),
  );
});

class OrderJualGetDataDTOService {
  OrderJualGetDataDTOService(
    Dio dio,
  ) : api = OrderJualGetDataDTOApi(
          dio,
        );
  final OrderJualGetDataDTOApi api;

  Future<Either<Failure, OrderJualGetDataResponse>> getData({
    required String action,
    required OrderJualGetFilter filters,
    required OrderJualGetSearch search,
  }) async {
    try {
      final payload = OrderJualGetDataPayload(
        action: action,
        filters: filters,
        search: [search],
      );
      final HttpResponse<dynamic> response = await api.getData(
        'application/json',
        payload,
      );
      if (response.isSuccess) {
        return Right<Failure, OrderJualGetDataResponse>(
          OrderJualGetDataResponse.fromJson(
            response.data,
          ),
        );
      }
      return ErrorUtils<OrderJualGetDataResponse>().handleDomainError(
        response,
      );
    } catch (e) {
      return ErrorUtils<OrderJualGetDataResponse>().handleError(e);
    }
  }
}
