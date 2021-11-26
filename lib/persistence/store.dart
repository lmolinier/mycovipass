import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:localstorage/localstorage.dart';

import '../qrcodes/model.dart';

class SecureStore extends Store {
  final storage = const FlutterSecureStorage();

  @override
  Future<void> load() async {
    var json = await storage.read(key: "list");
    if (json == null) {
      await save();
      return;
    }
    items.clear();
    jsonDecode(json).forEach((item) {
      items.add(QrCode.fromJson(item));
    });
  }

  @override
  Future<bool> get ready async => true;

  @override
  Future<void> save() async {
    return storage.write(key: "list", value: jsonEncode(items));
  }
}

class LocalStore extends Store {
  final String name;
  late LocalStorage storage;

  LocalStore(this.name) : super();

  @override
  Future<bool> get ready async {
    storage = LocalStorage(name);
    if (await storage.ready) {
      await load();
      return true;
    }
    return false;
  }

  @override
  Future<void> save() async {
    return storage.setItem("list", jsonEncode(items));
  }

  @override
  Future<void> load() async {
    var json = await storage.getItem("list");
    if (json == null) {
      await save();
      return;
    }
    items.clear();
    jsonDecode(json).forEach((item) {
      items.add(QrCode.fromJson(item));
    });
  }
}

abstract class Store {
  List<QrCode> items = [];

  Store();

  Future<bool> get ready;

  Future<void> save();

  Future<void> load();

  int get length {
    return items.length;
  }

  Future<bool> add(QrCode qr) async {
    items.add(qr);
    await save();
    return true;
  }

  Future<bool> remove(QrCode qr) async {
    var done = items.remove(qr);
    if (done) {
      await save();
      return true;
    }
    return false;
  }

  loadDefaultTestValuesIfEmpty() async {
    if (items.isNotEmpty) {
      return;
    }

    for (var element in [
      "HC1:NCFK60DG0/3WUWGSLKH47GO0Y%5S.PK%96L79CK-500XK0JCV496F3PYJ-982F3:OR2B8Y50.FK6ZK7:EDOLOPCO8F6%E3.DA%EOPC1G72A6YM86G7/F6/G80X6H%6946746T%6C46/96SF60R6FN8UPC0JCZ69FVCPD0LVC6JD846Y96C463W5307+EDG8F3I80/D6\$CBECSUER:C2\$NS346\$C2%E9VC- CSUE145GB8JA5B\$D% D3IA4W5646646-96:96.JCP9EJY8L/5M/5546.96SF63KC.SC4KCD3DX47B46IL6646H*6Z/ER2DD46JH8946JPCT3E5JDLA7\$Q69464W51S6..DX%DZJC2/DYOA\$\$E5\$C JC3/D9Z95LEZED1ECW.C8WE2OA3ZAGY8MPCG/DU2DRB8MTA8+9\$PC5\$CUZC\$\$5Y\$5FBB*10GBH A81QK UV-\$SOGD1APAB4\$5UV C-EWB4T*6H%QV/DAP9L7J3Y4O/WVI5IW3672HO-HV16IW3JHV-FI%WJCPBI8QTE008I+FPR01MYFA6EBN2SR3H+4KH1M9RCIM2 VV15REG 516N93SS70RBUCH-RJM2JMULZ6*/HBBW7W7:S2BU7T6PRTMF4ALUNEXH3P7 LE0YF0TGE461PBK9TD68HDIT4AIFD9NH14V%GBCONJOV\$KN  C+3U-IT\$SE-A2V+9UO9WYRJ4HN+M/Z5W\$QEDT/8C:88OQ4DXOBBIQ453863NPW0EJXG8\$GH1T 38C*UI6T /FCDC%6VLNOA6W6BEYJJUH2Z-SOJO1D7JMALD8 \$1%5B.GH\$7AQOHZ:K3BNO1",
      "HC1:NCFR606G0/3WUWGSLKH47GO0Y%5S.PK%96L79CK3600XK0JCV496F3RYJPGL2F31PRVHLY50.FK6ZKZWEDOLOPCO8F6%E3.DA%EOPC1G72A6YM8KG7FM8/A8.Q6X%61R6157//60S8P46%A8V%6B56UPC0JCZ69+EDG8F3I80/D6\$CBECSUER:C2\$NS346\$C2%E9VC- CSUE145GB8JA5B\$DE8C9/D:OC:M83KCZPCNF6OF63W59%6VF6.SA W66461G73564KCPPC5UA QEKPCG/D5\$C4KCD3DX47B46IL6646H*6KWEKDDC%6-Q6QW66464KCAWE6T9G%6G%67W5JPCT3E5JDLA7\$Q69464W51S6..DX%DZJC2/D/IANPCIEC JC3/DMP8\$ILZEDZ CW.C8WEBIAYM8TB8MPCG/DY-CAY81C9XY8O/EZKEZ967L6256V50A4AS0OHO5TXA03EE-Q39S5.QSJI*7BZ/7EI7L4WF42F*O:-K*21 YHPHEKSN/Q6IPIR1QKWTX0OJUN-785VGJD0+1FX6NSYJV31 -MBI7PRDP3O9.F16I\$JP9VM*AW4W3B%EBRT6HH4YV:/4UEO*EOIJ4KKR6%IX-47Y64R78Y3J REZN:\$S/Q4P.H*AT75V:0O+G4\$/E/EIE*JX32P-FMKE%59KL0/FJ*6WTVPGREF*FR8N\$WIIGT4:N8YJG:HQSVQE0XJA6TLSG47\$ONOO-+8 OH8K3UDJ\$34Z7PIYL3LCTYAIU2VU9ZC8%C60GH\$:8F5S5V5GRSAO3N%NDRR4NN/NN-7B5BEI-QWUH*ZHZ%9J3ONR32VF/I1P3RJKEPT62-CCYR",
      "HC1:NCF 50.G0/3WUWGSLKH47GO0Y%5S.PK%96L78CKR7U*70YM8FN0GWC MCWY0/AC9%VD97TK0F90GECQHGWJC0FDL:4:KEPH7M/ESDD746KG7+59V*8H:6TL6657-R8RM8AL6W*8SX8457UW6QW6WJCT3EYM8XJCS.CNF6OF63W59%6%96XJC/\$ENF6OF64W5Y96UF6ZJC+KENF6OF63W59%6746%JC+QE\$.32%E6VCHQEU\$DE44NXOBJE719\$QE0/D+8D-ED.24-G8\$:84KCD3DX47B46IL6646I*6GVC*JC1A6G%63W56L6-96TPCBEC7ZKW.CI C14EPQE JC2/DB190%EMEDLPCG/DI CC1A NAMPCG/D%-C8C9:S9:B8O/EZKEZ967L6256V50N:HS3M*AUM.0R:3O Q-RBKL9PGCK+J1KV9W9KRB1:827NW0E5/0Q HL*M VI END26KPA-/NBSBXX1NCCKHN7+23478K5I9L.-72U06SJ/89PT9OGM1/0CZUU4JYNM/O39LK3.N1JQHU7+Z3SOP0/A3JUTKPVC73UTM%ECV1+CQSUT--8EJH4ZOM-N\$*SOC3-NB2GJJ-69YL 59V3G\$ 4%Y4Z6R.9PFWGP\$TGWHHK61N757O JJS 58DJ69984MEA41YGTXAB.CTPG-+RDHLVQBEWPFVK%L90+JCW1F30PL7ZOQ% QCRRPYJXYAA.M.*D HJ H985E\$4QA915SJEPQZ*J.6HATCDF16IARXM3FG0QE2N2C%7E%FXADONSY*R7S33IQ",
    ]) {
      items.add(QrCode.fromJson({
        "type": "eudcc",
        "qr": element,
      }));
    }
    await save();
  }
}