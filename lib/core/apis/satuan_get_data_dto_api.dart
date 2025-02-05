import 'package:dio/dio.dart';
import 'package:venus/core/models/get_data/satuan_get_data_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'satuan_get_data_dto_api.g.dart';

@RestApi()
abstract class SatuanGetDataDTOApi {
  factory SatuanGetDataDTOApi(Dio dio, {String baseUrl}) = _SatuanGetDataDTOApi;

  @POST('/api/getData')
  Future<HttpResponse<dynamic>> getData(
    @Header('Accept') String accept,
    @Body() SatuanGetDataPayload payload,
  );
}
