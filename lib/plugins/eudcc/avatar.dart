import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:flex_color_picker/flex_color_picker.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:item_selector/item_selector.dart';
import 'package:myqrwallet/plugins/eudcc/qrcode.dart';

class AvatarSelector extends StatefulWidget {
  final EUDCCQrCode qrcode;
  const AvatarSelector({Key? key, required this.qrcode}) : super(key: key);

  @override
  State<AvatarSelector> createState() => AvatarSelectorState();
}

class AvatarSelectorState extends State<AvatarSelector> {
  Color color = Colors.orange;
  List<Uint8List> images = [];
  int current = -1;

  static String assetName = 'assets/avatars_128x128_36.png';
  static Rect crop = const Rect.fromLTWH(0, 0, 128, 128);
  static int limit = 36;

  @override
  initState() {
    super.initState();
    _load();
  }

  Future<bool> _load() async {
    var data = await rootBundle.load(assetName);
    var image = img.decodeImage(data.buffer.asUint8List());
    List<Uint8List> images = [];
    if (image == null) {
      return false;
    }
    for (var row = 0; row * (crop.bottom - crop.top) < image.height; row++) {
      for (var col = 0; col * (crop.right - crop.left) < image.width; col++) {
        var cropped = img.copyCrop(
            image,
            (crop.right.floor() - crop.left.floor()) * col,
            (crop.bottom.floor() - crop.top.floor()) * row,
            crop.right.floor() - crop.left.floor(),
            crop.bottom.floor() - crop.top.floor());
        images.add(Uint8List.fromList(img.encodePng(cropped)));
        if (images.length >= limit) break;
      }
    }
    setState(() {
      this.images = images;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.selectAvatarTitle),
          actions: [
            IconButton(
                onPressed: () {
                  if (current >= 0) {
                    widget.qrcode.setAvatar(images[current], color);
                    Navigator.of(context).maybePop();
                  }
                },
                icon: const Icon(Icons.done))
          ]),
      body: Column(children: [
        Padding(
            padding: const EdgeInsets.all(5),
            child: widget.qrcode
                .avatarFrom(current < 0 ? null : images[current], color)),
        Padding(
            padding: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(AppLocalizations.of(context)!.selectAvatarColor),
              trailing: ColorIndicator(
                width: 44,
                height: 44,
                borderRadius: 4,
                color: color,
                onSelectFocus: false,
                onSelect: () async {
                  // Store current color before we open the dialog.
                  final Color colorBeforeDialog = color;
                  // Wait for the picker to close, if dialog was dismissed,
                  // then restore the color we had before it was opened.
                  if (!(await colorPickerDialog())) {
                    setState(() {
                      color = colorBeforeDialog;
                    });
                  }
                },
              ),
            )),
        Flexible(
            child: ItemSelectionController(
                selectionMode: ItemSelectionMode.single,
                onSelectionStart: (start, end) {
                  setState(() {
                    current = end;
                  });
                  return true;
                },
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 92),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return ItemSelectionBuilder(
                        index: index,
                        builder:
                            (BuildContext context, int index, bool selected) {
                          return Card(
                            margin: const EdgeInsets.all(10),
                            shape: const CircleBorder(),
                            elevation: selected ? 2 : 10,
                            child: GridTile(
                              child: Center(
                                child: CircleAvatar(
                                  backgroundImage:
                                      Image.memory(images[index]).image,
                                  backgroundColor: color,
                                  radius: 64,
                                ),
                              ),
                            ),
                          );
                        });
                  },
                ))),
      ]),
    );
  }

  Future<bool> colorPickerDialog() async {
    return ColorPicker(
      // Use the dialogPickerColor as start color.
      color: color,
      // Update the dialogPickerColor using the callback.
      onColorChanged: (Color color) => setState(() => this.color = color),
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      heading: Text(
        AppLocalizations.of(context)!.selectAvatarColor,
        style: Theme.of(context).textTheme.subtitle1,
      ),
      subheading: Text(
        AppLocalizations.of(context)!.selectAvatarColorShade,
        style: Theme.of(context).textTheme.subtitle1,
      ),
      wheelSubheading: Text(
        AppLocalizations.of(context)!.selectedAvatarColorAndShade,
        style: Theme.of(context).textTheme.subtitle1,
      ),
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
      ),
      materialNameTextStyle: Theme.of(context).textTheme.caption,
      colorNameTextStyle: Theme.of(context).textTheme.caption,
      colorCodeTextStyle: Theme.of(context).textTheme.caption,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: false,
        ColorPickerType.wheel: true,
      },
    ).showPickerDialog(
      context,
      constraints:
          const BoxConstraints(minHeight: 460, minWidth: 300, maxWidth: 320),
    );
  }
}
