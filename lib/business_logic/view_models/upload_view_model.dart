import 'package:flutter/widgets.dart';
import 'package:poem/business_logic/model/poem.dart';
import 'package:poem/services/service_locator.dart';
import 'package:poem/services/storage/store_service.dart';
import 'package:poem/services/text/text_service.dart';

class UploadViewModel extends ChangeNotifier {
  final StoreService _storeService = serviceLocator<StoreService>();
  final TextsService _textsService = serviceLocator<TextsService>();

  bool _busy = false;
  bool get busy => _busy;
  void setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  Future<void> upload(
      String author, title, bool isPoem, String body, String lang) async {
    setBusy(true);
    Poem poem = Poem(
        author: author, title: title, isPoem: isPoem, lang: lang, diff: 3.5);
    List<String> lines = _textsService.splitBody(body, isPoem);
    await _storeService.insertPoem(poem, lines);
    setBusy(false);
  }
}
