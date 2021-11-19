import 'package:eudcc/eudcc.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CertificateWidget extends StatefulWidget {
  const CertificateWidget(this.cert, {Key? key}) : super(key: key);

  final EUDigitalCovidCertificate cert;

  @override
  State<CertificateWidget> createState() => CertificateWidgetState();
}

class CertificateWidgetState extends State<CertificateWidget> {
  @override
  Widget build(BuildContext context) {
    final cert = widget.cert;
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
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Center(
              child: Column(children: [
                const CircleAvatar(
                  child: Image(image: AssetImage('assets/avatar_man.png')),
                  backgroundColor: Colors.transparent,
                  radius: 40,
                ),
                Padding(
                    padding: const EdgeInsets.all(5),
                    child: RichText(
                      text: TextSpan(
                          text: (cert.certificates.single.holder.givenName ??
                                  "") +
                              " " +
                              cert.certificates.single.holder.firstName,
                          style: const TextStyle(
                              fontSize: 22, color: Colors.black)),
                    )),
                RichText(
                    text: TextSpan(
                        text: (cert.certificates.single.holder
                                    .givenNameICAO9303 ??
                                "") +
                            " " +
                            cert.certificates.single.holder.firstNameICAO9303,
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey))),
              ]),
            ),
            QrImage(
              data: cert.qr!,
              version: QrVersions.auto,
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
                              text: cert.issuedAt.toString(),
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black),
                            )
                          ])),
                      RichText(
                          text: TextSpan(
                              text: cert.expiresAt.toString(),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.black))),
                    ])),
                collapsed: Row(),
                expanded: Row(
                  children: [
                    const Text("plop"),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
