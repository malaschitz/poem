import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poem/business_logic/model/learning.dart';
import 'package:poem/business_logic/model/poem.dart';
import 'package:poem/services/storage/store_service.dart';

class StoreServiceHive implements StoreService {
  @override
  Future<void> initDb() async {
    print('Init DB start 1');
    DateTime t = DateTime.now();
    print('Init DB start 2');
    await Hive.initFlutter();
    print('Init DB start 3');
    Hive.registerAdapter(PoemAdapter());
    print('Init DB start 4');
    Hive.registerAdapter(LearningAdapter());
    print('Init DB start 5');

    try {
      Box boxP = await Hive.openBox<Poem>('poems');
      print('Init DB start 6');
      Box boxL = await Hive.openBox<Learning>('learnings');
      print('Init DB start 7');
      Box boxU = await Hive.openBox('prop');
      print('Init DB start 8');
      await boxP.compact();
      await boxL.compact();
      await boxU.compact();
    } catch (e) {
      //if is problem then delete\
      if (kIsWeb) {
        print('Init DB start 6.01');
        Hive.deleteBoxFromDisk('poems');
        print('Init DB start 6.02');
        Hive.deleteBoxFromDisk('learnings');
        print('Init DB start 6.03');
        Hive.deleteBoxFromDisk('prop');
        print('Init DB start 6.04');
        Box boxP = await Hive.openBox<Poem>('poems');
        print('Init DB start 6.1');
        Box boxL = await Hive.openBox<Learning>('learnings');
        print('Init DB start 7.1');
        Box boxU = await Hive.openBox('prop');
        print('Init DB start 8.1');
        await boxP.compact();
        await boxL.compact();
        await boxU.compact();
      }
    }
    print('Init DB start 9');

    print('Database initialized in ${DateTime.now().difference(t)}');
  }

  @override
  List<Poem> getPoems() {
    Box<Poem> pBox = Hive.box<Poem>('poems');
    List<Poem> poems = pBox.values.toList();
    return poems;
  }

  @override
  Future<void> insertPoem(Poem poem, List<String> lines) async {
    Box<Poem> pBox = Hive.box<Poem>('poems');
    Box<Learning> lBox = Hive.box<Learning>('learnings');
    poem.learning = HiveList(lBox);

    for (int i = 0; i < lines.length; i++) {
      Learning l = Learning(
          isLearning: false,
          nextLearn: DateTime.fromMillisecondsSinceEpoch(0),
          level: 0,
          interval: 0,
          counter: 0,
          wrong: 0,
          index: i,
          stars: 0,
          line: lines[i]);
      lBox.add(l);
      poem.learning!.add(l);
    }
    await pBox.add(poem);
  }

  @override
  Future<void> insertImportedPoem(Poem poem, List<Learning> learnings) async {
    Box<Poem> pBox = Hive.box<Poem>('poems');
    Box<Learning> lBox = Hive.box<Learning>('learnings');
    poem.learning = HiveList(lBox);
    for (var l in learnings) {
      lBox.add(l);
      poem.learning!.add(l);
    }
    await pBox.add(poem);
  }

  @override
  Future<void> deletePoem(Poem poem) async {
    await poem.delete();
  }

  @override
  Future<void> updatePoem(Poem poem) async {
    await poem.save();
  }

  @override
  Future<void> updateLearning(Learning l) async {
    await l.save();
  }

  @override
  Poem getPoem(dynamic key) {
    Box<Poem> pBox = Hive.box<Poem>('poems');
    Poem poem = pBox.get(key) ??
        Poem(
            author: 'author',
            title: 'title',
            isPoem: true,
            lang: 'lang',
            diff: 3.5);

    return poem;
  }
}
