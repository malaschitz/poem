import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:poem/business_logic/model/poem.dart';
import 'package:poem/services/poems/poem_service.dart';
import 'package:poem/services/service_locator.dart';
import 'package:poem/services/storage/store_service.dart';

Future<void> firstStart(BuildContext context, String locale) async {
  Box prop = Hive.box('prop');
  bool wasStart = prop.containsKey('firstStart');
  if (!wasStart) {
    try {
      StoreService storeService = serviceLocator<StoreService>();
      List<Map<String, dynamic>> poems =
          await serviceLocator<PoemService>().poems(context, locale);
      for (var i = 0; i < poems.length && i < 2; i++) {
        Map<String, dynamic> m = poems[i];
        Poem poem = Poem(
            author: m['Author'],
            title: m['Title'],
            isPoem: true,
            lang: m['Lang'],
            diff: 3.5);
        List<dynamic> lines = m['Lines'];
        List<String> sLines = lines.map((l) => l as String).toList();
        await storeService.insertPoem(poem, sLines);
      }
    } catch (e) {
      print('Chyba $e');
    }
  }
  await prop.put('firstStart', true);
}
