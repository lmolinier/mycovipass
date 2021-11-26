import 'package:flutter/foundation.dart';

import 'persistence/store.dart';
import 'qrcodes/model.dart';

typedef OnDeletedCallback = void Function();
typedef OnAddedCallback = void Function(String qrcode);

class Controller {
  //final Store store = kIsWeb ? TempStore() : LocalStore("myqrwallet");
  final Store store = SecureStore();

  Future<bool> get ready async {
    var r = await store.ready;
    if (!kIsWeb) {
      return r;
    }
    await store.loadDefaultTestValuesIfEmpty();
    return r;
  }

  QrCode create(String qrcode) {
    return QrCode.fromQrCode(qrcode);
  }

  Future<bool> add(QrCode qr) async {
    return store.add(qr);
  }

  Future<bool> addFromQr(String qrcode) async {
    var item = create(qrcode);
    return await store.add(item);
  }

  Future<bool> remove(QrCode item) async {
    return store.remove(item);
  }

  Iterable<T> map<T>(T Function(QrCode) toElement) {
    return store.items.map(toElement);
  }

  Map<int, QrCode> asMap() {
    return store.items.asMap();
  }

  QrCode? get(int idx) {
    if (idx <= store.length) {
      return store.items[idx];
    }
    return null;
  }
}
