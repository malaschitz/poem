import 'package:hive/hive.dart';

part 'learning.g.dart';

@HiveType(typeId: 2)
class Learning extends HiveObject {
  @HiveField(0)
  bool isLearning;

  @HiveField(1)
  DateTime nextLearn;

  @HiveField(2)
  int level;

  @HiveField(3)
  int interval; //seconds

  @HiveField(4)
  int counter;

  @HiveField(5)
  int wrong;

  @HiveField(6)
  int index;

  @HiveField(7)
  int stars;

  @HiveField(8)
  String line;

  Learning(
      {required this.isLearning,
      required this.nextLearn,
      required this.level,
      required this.interval,
      required this.counter,
      required this.wrong,
      required this.index,
      required this.stars,
      required this.line});

  //json serialization
  factory Learning.fromJson(Map<String, dynamic> json) {
    return Learning(
        isLearning: json['islearning'] ?? true,
        nextLearn: DateTime.fromMillisecondsSinceEpoch(json['nextlearn']),
        level: json['level'],
        interval: json['interval'],
        counter: json['counter'],
        wrong: json['wrong'],
        index: json['index'],
        stars: json['stars'],
        line: json['line']);
  }

  Map<String, dynamic> toJson() => {
        'islearning': isLearning,
        'nextlearn': nextLearn.millisecondsSinceEpoch,
        'level': level,
        'interval': interval,
        'counter': counter,
        'wrong': wrong,
        'index': index,
        'stars': stars,
        'line': line,
      };
}
