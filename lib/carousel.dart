import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:myqrwallet/controller.dart';
import 'package:myqrwallet/popmenu.dart';

typedef OnDeletedCallback = void Function();
typedef OnAddedCallback = void Function(String qrcode);

abstract class QrCodeWidget extends StatefulWidget {
  final OnDeletedCallback? onDeleted;
  final OnAddedCallback? onAdded;

  const QrCodeWidget({Key? key, this.onDeleted, this.onAdded})
      : super(key: key);
}

class Carousel extends StatefulWidget {
  const Carousel({required this.controller, Key? key}) : super(key: key);

  final Controller controller;

  @override
  State<Carousel> createState() => CarouselState();
}

class CarouselState extends State<Carousel> {
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  int _current = 0;
  final CarouselController _controller = CarouselController();

  onAdded(String qrcode) {
    widget.controller.addFromQr(qrcode).then((res) {
      if (!res) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("cannot save the certificate")),
        );
      }
      setState(() {});
    });
  }

  onDeleted(QrCode qr) {
    widget.controller.remove(qr).then((done) {
      if (done) {
        setState(() => {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cannot delete"),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return PopMenu(
        onAdded: onAdded,
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
              items: widget.controller
                  .map((QrCode cert) => cert.widget(
                      onDeleted: () => {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Row(
                                  children: const [
                                    Icon(Icons.delete_forever,
                                        color: Colors.white),
                                    Text("Please confirm deletion"),
                                  ],
                                ),
                                action: SnackBarAction(
                                  label: 'delete',
                                  onPressed: () => onDeleted(cert),
                                )))
                          }))
                  .toList(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.controller.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _controller.animateToPage(entry.key),
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                ),
              );
            }).toList(),
          ),
        ]));
  }
}