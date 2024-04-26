import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:poem/business_logic/model/poem.dart';
import 'package:poem/services/poems/poem_service.dart';
import 'package:poem/services/service_locator.dart';
import 'package:poem/services/storage/store_service.dart';

class HomeViewModel extends ChangeNotifier {
  final StoreService _storeService = serviceLocator<StoreService>();

  bool _busy = false;
  bool get busy => _busy;
  List<Poem> _poems = [];
  late Timer _timer;

  void setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  HomeViewModel() {
    _timer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      loadDataA();
    });
  }

  loadDataA() async {
    setBusy(true);
    await loadDataB();
    setBusy(false);
  }

  loadDataB() async {
    //
    _poems = _storeService.getPoems();
    _poems.sort((a, b) {
      return a.nextTime().compareTo(b.nextTime());
      /*
      if (b.repeatItems != a.repeatItems) {
        return b.repeatItems - a.repeatItems;
      }
      double af = a.unseenItems / a.learning!.length;
      double bf = b.unseenItems / b.learning!.length;
      if (af < bf) {
        return 1;
      } else if (af > bf) {
        return -1;
      } else {
        return 0;
      }
      */
    });
    if (kIsWeb) {
      //web platform without badge
    } else {
      if (await FlutterAppBadger.isAppBadgeSupported()) {
        int badge = 0;
        for (var element in _poems) {
          badge = badge + element.repeatItems;
        }
        if (badge == 0) {
          FlutterAppBadger.removeBadge();
        } else {
          FlutterAppBadger.updateBadgeCount(badge);
        }
      }
    }

    //setBusy(false);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  List<Poem> get poems {
    return _poems;
  }

  savePoem(Map<String, dynamic> m) async {
    setBusy(true);
    Poem poem = Poem(
        author: m['Author'],
        title: m['Title'],
        isPoem: true,
        lang: m['Lang'],
        diff: 3.5);
    List<dynamic> lines = m['Lines'];
    List<String> sLines = lines.map((l) => l as String).toList();
    await _storeService.insertPoem(poem, sLines);
    await loadDataA();
    setBusy(false);
  }

  Future<void> exportData() async {
    //json
    setBusy(true);
    String json = jsonEncode(poems);
    //export
    await serviceLocator<PoemService>().exportJson(json);
    setBusy(false);
  }

  Future<String> importData() async {
    setBusy(true);
    String msg = await serviceLocator<PoemService>().importJson();
    setBusy(false);
    return msg;
  }
}
