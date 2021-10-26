import 'dart:io';

import 'package:eudcc/eudcc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'certificate.dart';
import 'qrscanner.dart';
import 'store.dart';

class AddMenu extends StatefulWidget {
  const AddMenu({Key? key}) : super(key: key);

  @override
  State<AddMenu> createState() => AddMenuState();
}

class AddMenuState extends State<AddMenu> {
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  final Store store = kIsWeb ? TempStore() : LocalStore("mycovipass");

  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return FutureBuilder(
        future: store.ready,
        builder: (BuildContext context, snapshot) {
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
                animatedIcon: AnimatedIcons.menu_close,
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
                      label: 'Scan',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QRScannerView(
                                onFinish: (Barcode code) {
                                  store.add(code.code.toString()).then((res) {
                                    if (!res) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "cannot save the certificate")),
                                      );
                                    }
                                    Navigator.of(context).maybePop();
                                  });
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
                    label: "Image",
                    onTap: () {
                      /*FilePicker.platform
                          .pickFiles()
                          .then((FilePickerResult? result) {
                        if (result != null) {
                          RScan.scanImagePath(result.files.single.path!)
                              .then((RScanResult? result) {
                            print(result);
                          });
                        } else {
                          // User canceled the picker
                        }
                      });*/
                    },
                  )
                ],
              ),
              body: Column(children: <Widget>[
                Expanded(
                  child: CarouselSlider(
                    carouselController: _controller,
                    options: CarouselOptions(
                        //enlargeCenterPage: true,
                        height: MediaQuery.of(context).size.height,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _current = index;
                          });
                        }),
                    items: store.map((EUDigitalCovidCertificate cert) {
                      return CertificateWidget(cert);
                    }).toList(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: store.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () => _controller.animateToPage(entry.key),
                      child: Container(
                        width: 12.0,
                        height: 12.0,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black)
                                    .withOpacity(
                                        _current == entry.key ? 0.9 : 0.4)),
                      ),
                    );
                  }).toList(),
                ),
              ]),
            ),
          );
        });
  }
}
