import 'package:flutter/widgets.dart';
import 'package:poem/business_logic/model/learning.dart';
import 'package:poem/business_logic/model/poem.dart';
import 'package:poem/services/service_locator.dart';
import 'package:poem/services/storage/store_service.dart';

class EditViewModel extends ChangeNotifier {
  final StoreService _storeService = serviceLocator<StoreService>();
  late Poem poem;

  bool _busy = false;
  bool get busy => _busy;

  void setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  void init(Poem p) {
    poem = p;
  }

  Future<void> deletePoem() async {
    setBusy(true);
    await _storeService.deletePoem(poem);
    setBusy(false);
  }

  Future<void> resetLearning(Learning l) async {
    setBusy(true);
    l.isLearning = false;
    l.nextLearn = DateTime.fromMillisecondsSinceEpoch(0);
    l.level = 0;
    l.interval = 0;
    l.counter = 0;
    l.wrong = 0;
    l.stars = 0;
    await _storeService.updateLearning(l);
    setBusy(false);
  }

  Future<void> updateLearning(Learning l) async {
    setBusy(true);
    await _storeService.updateLearning(l);
    setBusy(false);
  }

  Future<void> resetPoem() async {
    setBusy(true);
    if (poem.learning != null) {
      for (int i = 0; i < poem.learning!.length; i++) {
        Learning l = poem.learning![i];
        l.isLearning = false;
        l.nextLearn = DateTime.fromMillisecondsSinceEpoch(0);
        l.level = 0;
        l.interval = 0;
        l.counter = 0;
        l.wrong = 0;
        l.stars = 0;
        await _storeService.updateLearning(l);
      }
    }

    await _storeService.updatePoem(poem);
    setBusy(false);
  }

  Future<void> updatePoem() async {
    setBusy(true);

    await _storeService.updatePoem(poem);
    setBusy(false);
  }
}
