import 'package:eudcc/eudcc.dart';
import 'package:flutter/widgets.dart';

import '../../qrcodes/model.dart';
import '../../controller.dart';

import 'widget.dart';

class EUDCCQrCode extends QrCode {
  @override
  String get type => "eudcc";

  final EUDigitalCovidCertificate cert;

  EUDCCQrCode(this.cert);

  EUDCCQrCode.fromJson(Map<String, dynamic> json)
      : cert = EUDigitalCovidCertificateFactory().fromQrCode(json["qr"])!;

  static QrCode? fromQrCode(String qr) {
    var cert = EUDigitalCovidCertificateFactory().fromQrCode(qr);
    return cert != null ? EUDCCQrCode(cert) : null;
  }

  @override
  Widget widget({OnDeletedCallback? onDeleted}) {
    return EUDCCWidget(cert, onDeleted: onDeleted);
  }

  @override
  Map<String, dynamic> toJson() {
    return {"qr": cert.qr, ...super.toJson()};
  }
}
