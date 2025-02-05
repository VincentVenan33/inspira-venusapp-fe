import 'package:json_annotation/json_annotation.dart';

part 'create_order_jual_detail_dto.g.dart';

@JsonSerializable()
class CreateOrderJualDetailPayload {
  CreateOrderJualDetailPayload({
    required this.action,
    required this.requestData,
  });

  factory CreateOrderJualDetailPayload.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderJualDetailPayloadFromJson(json);

  Map<String, dynamic> toJson() => _$CreateOrderJualDetailPayloadToJson(this);

  final String action;
  final CreateOrderJualDetailRequest requestData;
}

@JsonSerializable()
class CreateOrderJualDetailRequest {
  CreateOrderJualDetailRequest({
    required this.formatcode,
    required this.intNomorHeader,
    required this.intNomorDetail,
    required this.intNomorMBarang,
    required this.intNomorMSatuan1,
    required this.decJumlah1,
    required this.decNetto,
    required this.decDisc1,
    required this.decDisc2,
    required this.decDisc3,
    required this.decJumlahUnit,
    required this.dtTanggal,
    required this.decHarga,
    required this.decSubTotal,
    required this.decBerat,
  });

  factory CreateOrderJualDetailRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderJualDetailRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateOrderJualDetailRequestToJson(this);
 @JsonKey(name: 'format_code')
  final String? formatcode;
  final int? intNomorHeader;
  final int? intNomorDetail;
  final int? intNomorMBarang;
  final int? intNomorMSatuan1;
  final int? decJumlah1;
  final int? decNetto;
  final int? decDisc1;
  final int? decDisc2;
  final int? decDisc3;
  final int? decJumlahUnit;
  final String dtTanggal;
  final int? decHarga;
  final int decSubTotal;
  final int decBerat;
}

@JsonSerializable()
class CreateOrderJualDetailResponse {
  CreateOrderJualDetailResponse({
    this.success,
    this.statusCode,
    required this.data,
  });

  factory CreateOrderJualDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderJualDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateOrderJualDetailResponseToJson(this);

  final bool? success;
  @JsonKey(name: 'status_code')
  final int? statusCode;
  final SetOrderJualDetailDataContent data;
}

@JsonSerializable()
class SetOrderJualDetailDataContent {
  SetOrderJualDetailDataContent({
    required this.kode,
    required this.nomorthOrderJualDetail,
    required this.nomormhbarang,
    required this.nomormhsatuan,
    required this.qty,
    required this.netto,
    required this.disctotal,
    required this.discdirect,
    required this.disc3,
    required this.disc2,
    required this.disc1,
    required this.satuanqty,
    required this.isi,
    required this.satuanisi,
    required this.harga,
    required this.subtotal,
    required this.konversisatuan,
    required this.id,
  });

  factory SetOrderJualDetailDataContent.fromJson(Map<String, dynamic> json) =>
      _$SetOrderJualDetailDataContentFromJson(json);

  Map<String, dynamic> toJson() => _$SetOrderJualDetailDataContentToJson(this);

  final String kode;
  final int? nomorthOrderJualDetail;
  final int? nomormhbarang;
  final int? nomormhsatuan;
  final int? qty;
  final int? netto;
  @JsonKey(name: 'disc_total')
  final int? disctotal;
  @JsonKey(name: 'disc_direct')
  final int? discdirect;
  @JsonKey(name: 'disc_3')
  final int? disc3;
  @JsonKey(name: 'disc_2')
  final int? disc2;
  @JsonKey(name: 'disc_1')
  final int? disc1;
  @JsonKey(name: 'satuan_qty')
  final String satuanqty;
  final int? isi;
  @JsonKey(name: 'satuan_isi')
  final String satuanisi;
  final int? harga;
  final String subtotal;
  @JsonKey(name: 'konversi_satuan')
  final String konversisatuan;
  final int? id;
}
