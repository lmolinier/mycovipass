import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QrReader {
  final String? extension;
  final Uint8List buffer;

  QrReader(this.extension, this.buffer);

  Future<String?> scan(BuildContext context) async {
    img.Image? image;
    switch (extension) {
      case "pdf":
        EasyLoading.showInfo(AppLocalizations.of(context)!.loadingPdf);
        var doc = await PdfDocument.openData(buffer);
        var page = await doc.getPage(1);
        // Ensure the page is big enough for the QR Code to be readable
        var png =
            await page.render(width: 4 * page.width, height: 4 * page.height);
        image = img.decodePng(png!.bytes);
        break;
      case "png":
        EasyLoading.showInfo(AppLocalizations.of(context)!.loadingPng);
        image = img.decodePng(buffer);
        break;
      default:
        return null;
    }

    if (image == null) {
      return null;
    }

    EasyLoading.showInfo("Detecting QR Code in image");
    LuminanceSource source = RGBLuminanceSource(image.width, image.height,
        image.getBytes(format: img.Format.abgr).buffer.asInt32List());
    var bitmap = BinaryBitmap(HybridBinarizer(source));

    try {
      var reader = QRCodeReader();

      var hints = DecodeHints();
      hints.put(DecodeHintType.tryHarder);
      hints.put(DecodeHintType.possibleFormats, [BarcodeFormat.qrCode]);
      var result = reader.decode(bitmap, hints: hints);
      return result.text;
    } catch (_) {
      return null;
    }
  }
}
