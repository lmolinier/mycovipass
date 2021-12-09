import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:file_picker/file_picker.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'controller.dart';
import 'qrcodes/scanner.dart';
import 'qrcodes/reader.dart';

class PopMenu extends StatefulWidget {
  final Widget body;
  final OnDeletedCallback? onDeleted;
  final OnAddedCallback? onAdded;

  const PopMenu({required this.body, this.onDeleted, this.onAdded, Key? key})
      : super(key: key);

  @override
  State<PopMenu> createState() => PopMenuState();
}

class PopMenuState extends State<PopMenu> {
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        floatingActionButton: SpeedDial(
          activeIcon: Icons.close,
          icon: Icons.add,
          openCloseDial: isDialOpen,
          backgroundColor: Colors.redAccent,
          overlayColor: Colors.grey,
          overlayOpacity: 0.5,
          spacing: 15,
          spaceBetweenChildren: 15,
          closeManually: false,
          children: [
            SpeedDialChild(
                child: const Icon(Icons.qr_code),
                label: AppLocalizations.of(context)!.actionScan,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QRScannerView(
                          onFinish: (Barcode code) {
                            widget.onAdded!(code.code.toString());
                            Navigator.of(context).maybePop();
                          },
                          onFailed: (String reason) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(reason)),
                            );
                          },
                        ),
                      ));
                }),
            SpeedDialChild(
              child: const Icon(Icons.image),
              label: AppLocalizations.of(context)!.actionImage,
              onTap: () {
                FilePicker.platform
                    .pickFiles()
                    .then((FilePickerResult? result) {
                  EasyLoading.showInfo(
                      AppLocalizations.of(context)!.loadingFile);
                  if (result != null) {
                    for (var f in result.files) {
                      Uint8List b;
                      if (f.bytes == null) {
                        b = File(f.path!).readAsBytesSync();
                      } else {
                        b = f.bytes!;
                      }

                      QrReader(f.extension, b)
                          .scan(context)
                          .then((String? qrcode) {
                        if (qrcode != null) {
                          widget.onAdded!(qrcode);
                        } else {
                          EasyLoading.showError(
                              AppLocalizations.of(context)!.errorDecode);
                        }
                      });
                    }
                  } else {
                    // User canceled the picker
                    EasyLoading.dismiss();
                  }
                });
              },
            ),
          ],
        ),
        body: widget.body,
      ),
    );
  }
}
