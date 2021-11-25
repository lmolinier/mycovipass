import 'package:eudcc/eudcc.dart';
import 'package:flutter/widgets.dart';

import '../../carousel.dart';
import '../../controller.dart';

import 'widget.dart';

class EUDCCQrCode implements QrCode {
  final EUDigitalCovidCertificate cert;

  EUDCCQrCode(this.cert);

  @override
  String toQrCode() {
    return cert.qr ?? "unknown";
  }

  static QrCode? fromQrCode(String qr) {
    var cert = EUDigitalCovidCertificateFactory().fromQrCode(qr);
    return cert != null ? EUDCCQrCode(cert) : null;
  }

  @override
  Widget widget({OnDeletedCallback? onDeleted}) {
    return EUDCCWidget(cert, onDeleted: onDeleted);
  }
}
