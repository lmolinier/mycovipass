import 'dart:convert';
import 'dart:typed_data';

import 'package:eudcc/eudcc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../qrcodes/model.dart';
import '../../controller.dart';

import 'widget.dart';

class EUDCCQrCode extends QrCode {
  @override
  String get type => "eudcc";

  final EUDigitalCovidCertificate cert;
  Uint8List? image;
  Color? color;

  EUDCCQrCode(this.cert);

  EUDCCQrCode.fromJson(Map<String, dynamic> json)
      : image = json["image"] != null ? base64Decode(json["image"]) : null,
        color = json["color"] != null ? Color(json["color"]) : null,
        cert = EUDigitalCovidCertificateFactory().fromQrCode(json["qr"])!;

  static QrCode? fromQrCode(String qr) {
    var cert = EUDigitalCovidCertificateFactory().fromQrCodeOrUri(qr);
    return cert != null ? EUDCCQrCode(cert) : null;
  }

  @override
  Widget widget({OnDeletedCallback? onDeleted, OnUpdatedCallback? onUpdated}) {
    return EUDCCWidget(this, onDeleted: onDeleted, onUpdated: onUpdated);
  }

  Widget avatarFrom(Uint8List? image, Color? color) {
    return CircleAvatar(
      backgroundImage: image != null
          ? Image.memory(image).image
          : const AssetImage('assets/default_avatar.png'),
      backgroundColor: color ?? Colors.transparent,
      radius: 40,
    );
  }

  Widget avatar() {
    return avatarFrom(image, color);
  }

  @override
  Map<String, dynamic> toJson() {
    var m = {"qr": cert.qr, ...super.toJson()};
    if (image != null) {
      m["image"] = base64Encode(image!.toList());
    }
    if (color != null) {
      m["color"] = color!.value;
    }
    return m;
  }

  setAvatar(Uint8List image, Color color) {
    this.image = image;
    this.color = color;
  }
}
