import 'dart:typed_data';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:r_scan/r_scan.dart';

class QrReader {
  final String? extension;
  final Uint8List buffer;

  QrReader(this.extension, this.buffer);

  Future<String?> scan() async {
    Uint8List buf;
    if (extension == "pdf") {
      var doc = await PdfDocument.openData(buffer);
      var page = await doc.getPage(1);
      var image = await page.render(width: page.width, height: page.height);
      buf = image!.bytes;
    } else {
      /* assume buffer contains an image directly usable in RScan */
      buf = buffer;
    }
    var res = await RScan.scanImageMemory(buf);
    return res.message;
  }
}
