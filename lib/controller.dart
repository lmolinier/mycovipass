import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'plugins/eudcc/qrcode.dart';
import 'store.dart';
import 'carousel.dart';

abstract class QrCode {
  String toQrCode();
  Widget widget({OnDeletedCallback? onDeleted});
}

class Controller {
  final Store store = kIsWeb ? TempStore() : LocalStore("myqrwallet");

  Future<bool> get ready {
    return store.ready;
  }

  QrCode? create(String qrcode) {
    return [
      EUDCCQrCode.fromQrCode,
    ].map((fn) => fn(qrcode)).first;
  }

  Future<bool> add(QrCode qr) async {
    return store.add(qr);
  }

  Future<bool> addFromQr(String qrcode) async {
    var qr = create(qrcode);
    return qr != null ? await store.add(qr) : false;
  }

  Future<bool> remove(QrCode qr) async {
    return store.remove(qr);
  }

  Iterable<T> map<T>(T Function(QrCode) toElement) {
    return store.certs.map(toElement);
  }

  Map<int, QrCode> asMap() {
    return store.certs.asMap();
  }

  QrCode? get(int idx) {
    if (idx <= store.length) {
      return store.certs[idx];
    }
    return null;
  }
}
