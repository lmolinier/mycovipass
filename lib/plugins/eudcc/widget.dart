import 'package:eudcc/eudcc.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:qr_flutter/qr_flutter.dart';

import '../../carousel.dart';
import 'utils.dart';

class EUDCCWidget extends QrCodeWidget {
  const EUDCCWidget(this.cert, {Key? key, OnDeletedCallback? onDeleted})
      : super(key: key, onDeleted: onDeleted);

  final EUDigitalCovidCertificate cert;

  @override
  State<EUDCCWidget> createState() => EUDCCWidgetState();
}

class EUDCCWidgetState extends State<EUDCCWidget> {
  ValueNotifier<bool> isMenuOpen = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final cert = widget.cert.certificates.single;
    final holder = cert.holder;
    final eeudc = widget.cert;
    return Container(
        //width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ]),
        child: WillPopScope(
          onWillPop: () async {
            if (isMenuOpen.value) {
              isMenuOpen.value = false;
              return false;
            } else {
              return true;
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: [
                Center(
                  child: Column(children: [
                    Align(
                        alignment: Alignment.topRight,
                        child: SpeedDial(
                          openCloseDial: isMenuOpen,
                          overlayColor: Colors.grey,
                          overlayOpacity: 0.5,
                          spacing: 5,
                          spaceBetweenChildren: 5,
                          closeManually: false,
                          dialRoot: (ctx, open, toggle) {
                            return IconButton(
                                onPressed: toggle,
                                icon: const Icon(
                                  Icons.menu,
                                  color: Colors.grey,
                                ));
                          },
                          direction: SpeedDialDirection.down,
                          buttonSize: 40,
                          childrenButtonSize: 40,
                          children: [
                            SpeedDialChild(
                                child: const Icon(Icons.delete_forever,
                                    color: Colors.redAccent),
                                label: 'Delete',
                                onTap: () {
                                  widget.onDeleted!();
                                }),
                          ],
                        )),
                    const CircleAvatar(
                      child: Image(image: AssetImage('assets/avatar_man.png')),
                      backgroundColor: Colors.transparent,
                      radius: 40,
                    ),
                    Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          prettyPrintName(holder.firstName, holder.givenName),
                          style: const TextStyle(
                              fontSize: 22, color: Colors.black),
                        )),
                    Text(
                        prettyPrintName(
                            holder.firstNameICAO9303, holder.givenNameICAO9303),
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey)),
                  ]),
                ),
                QrImage(
                  data: eeudc.qr!,
                  version: QrVersions.auto,
                  constrainErrorBounds: true,
                  //size: MediaQuery.of(context).size.width,
                ),
                ExpandablePanel(
                    theme: const ExpandableThemeData(
                      headerAlignment: ExpandablePanelHeaderAlignment.center,
                      tapHeaderToExpand: true,
                    ),
                    header: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(children: [
                          RichText(
                              text: TextSpan(
                                  text: "delivered: ",
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                  children: [
                                TextSpan(
                                  text: eeudc.issuedAt.toString(),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black),
                                )
                              ])),
                          RichText(
                              text: TextSpan(
                                  text: eeudc.expiresAt.toString(),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.black))),
                        ])),
                    collapsed: Row(),
                    expanded: Row()),
              ],
            ),
          ),
        ));
  }
}
