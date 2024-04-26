import 'package:poem/business_logic/model/learning.dart';
import 'package:poem/business_logic/model/poem.dart';

abstract class StoreService {
  Future<void> initDb();

  List<Poem> getPoems();

  Future<void> insertPoem(Poem poem, List<String> lines);

  Future<void> insertImportedPoem(Poem poem, List<Learning> learnings);

  Future<void> deletePoem(Poem poem);

  Future<void> updatePoem(Poem poem);

  Future<void> updateLearning(Learning l);

  Poem getPoem(dynamic key);
}
