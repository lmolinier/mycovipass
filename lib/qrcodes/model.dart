import 'package:flutter/widgets.dart';

import '../plugins/eudcc/qrcode.dart';
import '../controller.dart';

class QrCode {
  String get type => "unknown";

  Map<String, dynamic> toJson() => toBaseJson();

  Map<String, dynamic> toBaseJson() => {
        "type": type,
      };

  Widget widget({OnDeletedCallback? onDeleted}) => Text("Unknown type $type");

  QrCode();

  factory QrCode.fromQrCode(String qrcode) {
    for (var fn in [
      EUDCCQrCode.fromQrCode,
    ]) {
      var obj = fn(qrcode);
      if (obj != null) {
        return obj;
      }
    }
    throw Exception("no handler for this qrcode");
  }

  factory QrCode.fromJson(Map<String, dynamic> json) {
    switch (json["type"]) {
      case "eudcc":
        return EUDCCQrCode.fromJson(json);
      default:
        throw Exception("unknown type from $json");
    }
  }
}
