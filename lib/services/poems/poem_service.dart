// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:poem/business_logic/model/learning.dart';
import 'package:poem/business_logic/model/poem.dart';
import 'package:poem/services/service_locator.dart';
import 'package:poem/services/storage/store_service.dart';
import 'package:share_plus/share_plus.dart';

class PoemService {
  Future<List<Map<String, dynamic>>> poems(
      BuildContext context, String locale) async {
    String data = await DefaultAssetBundle.of(context)
        .loadString('assets/poem$locale.json');
    List<dynamic> list = jsonDecode(data);
    List<Map<String, dynamic>> poems = <Map<String, dynamic>>[];
    list.forEach((md) async {
      Map<String, dynamic> map = md as Map<String, dynamic>;
      poems.add(map);
    });
    return poems;
  }

  Future<void> exportJson(String json) async {
    print(json);
    Uint8List bytes = utf8.encode(json);
    var xf =
        XFile.fromData(bytes, name: 'poem.json', mimeType: 'application/json');
    await Share.shareXFiles([xf], subject: 'poem.json');
  }

  Future<String> importJson() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        File file = File(result.files.single.path ?? '');
        String data = await file.readAsString();
        print(data);
        //save
        List<dynamic> list = jsonDecode(data);
        StoreService storeService = serviceLocator<StoreService>();
        list.forEach((md) async {
          Map<String, dynamic> map = md as Map<String, dynamic>;
          Poem poem = Poem.fromJson(map);
          List<dynamic> llist = md['learning'];
          List<Learning> learnings = <Learning>[];
          llist.forEach((l) {
            learnings.add(Learning.fromJson(l));
          });
          await storeService.insertImportedPoem(poem, learnings);
        });

        print('imported');
      }
    } catch (e) {
      return e.toString();
    }
    print('imported 2');
    return '';
  }
}
