import 'package:json_annotation/json_annotation.dart';

part 'approval_order_jual_dto.g.dart';

@JsonSerializable()
class ApprovalOrderJualPayload {
  ApprovalOrderJualPayload({
    required this.action,
    required this.requestData,
  });

  factory ApprovalOrderJualPayload.fromJson(Map<String, dynamic> json) => _$ApprovalOrderJualPayloadFromJson(json);

  Map<String, dynamic> toJson() => _$ApprovalOrderJualPayloadToJson(this);

  final String action;
  final ApprovalOrderJualRequest requestData;
}

@JsonSerializable()
class ApprovalOrderJualRequest {
  ApprovalOrderJualRequest({
    required this.intApproved,
    required this.dtApproveTime,
  });

  factory ApprovalOrderJualRequest.fromJson(Map<String, dynamic> json) => _$ApprovalOrderJualRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ApprovalOrderJualRequestToJson(this);
  final int? intApproved;
  final String? dtApproveTime;
}

@JsonSerializable()
class ApprovalOrderJualResponse {
  ApprovalOrderJualResponse({
    this.msg,
    this.code,
  });

  factory ApprovalOrderJualResponse.fromJson(Map<String, dynamic> json) => _$ApprovalOrderJualResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ApprovalOrderJualResponseToJson(this);

  final bool? msg;
  final int? code;
}
