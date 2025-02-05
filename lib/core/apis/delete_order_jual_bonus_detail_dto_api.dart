import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:venus/core/models/delete_data/delete_order_jual_bonus_detail_dto.dart';

part 'delete_order_jual_bonus_detail_dto_api.g.dart';

@RestApi()
abstract class DeleteOrderJualBonusDetailDTOApi {
  factory DeleteOrderJualBonusDetailDTOApi(Dio dio, {String baseUrl}) = _DeleteOrderJualBonusDetailDTOApi;

  @DELETE('/api/deleteData/{id}')
  Future<HttpResponse<dynamic>> deleteOrderJualBonusDetail(
    @Path('id') int nomor,
    @Header('Accept') String accept,
    @Body() DeleteOrderJualBonusDetailPayload payload,
  );
}
