import 'package:hive/hive.dart';
import 'package:poem/services/service_locator.dart';
import 'package:poem/services/text/text_service.dart';

import 'learning.dart';

part 'poem.g.dart';

@HiveType(typeId: 1)
class Poem extends HiveObject {
  @HiveField(0)
  bool isPoem;

  @HiveField(1)
  String title;

  @HiveField(2)
  String author;

  @HiveField(3)
  HiveList<Learning>? learning;

  @HiveField(4)
  String lang;

  @HiveField(5)
  double diff;

  final TextsService _textsService = serviceLocator<TextsService>();

  //dynamic fields

  Poem({
    required this.author,
    required this.title,
    required this.isPoem,
    required this.lang,
    required this.diff,
  });

  //json serialization
  factory Poem.fromJson(Map<String, dynamic> json) {
    return Poem(
        author: json['author'],
        title: json['title'],
        isPoem: json['ispoem'],
        lang: json['lang'] ?? 'en',
        diff: json['diff'] ?? 3.5);
  }

  Map<String, dynamic> toJson() => {
        'ispoem': isPoem,
        'title': title,
        'author': author,
        'lang': lang,
        'learning': learning,
        'diff': diff,
      };

  List<String> get firstLetters {
    String body = '';
    learning?.forEach((l) => body = '$body${l.line} ');
    return _textsService.firstLetters(body, lang);
  }

  DateTime nextTime() {
    DateTime next = DateTime.parse('9999-01-01');
    learning?.forEach((l) {
      if (l.isLearning && next.isAfter(l.nextLearn)) {
        next = l.nextLearn;
      }
    });
    return next;
  }

  int get repeatItems {
    int w = 0;
    DateTime now = DateTime.now();
    learning?.forEach((l) {
      if (l.isLearning && now.isAfter(l.nextLearn)) {
        w++;
      }
    });
    return w;
  }

  double get safeDiff {
    double d = diff == 0 ? 3.5 : diff;
    if (d == 0) {
      d = 3.5;
    }
    if (d < 1.5) {
      d = 1.5;
    } else if (d > 10.0) {
      d = 10.0;
    }
    return d;
  }

  int get unseenItems {
    int w = 0;
    learning?.forEach((l) {
      if (!l.isLearning) {
        w++;
      }
    });
    return w;
  }

  List<int> statsInfo() {
    DateTime now = DateTime.now();
    List<int> z = List<int>.filled(9, 0);
    learning?.forEach((l) {
      z[0]++;
      if (l.isLearning) {
        if (l.nextLearn.isBefore(now)) {
          z[2]++;
        } else if (l.interval < 60 * 60) {
          z[3]++;
        } else if (l.interval < 60 * 60 * 24) {
          z[4]++;
        } else if (l.interval < 60 * 60 * 24 * 7) {
          z[5]++;
        } else if (l.interval < 60 * 60 * 24 * 30) {
          z[6]++;
        } else if (l.interval < 60 * 60 * 24 * 365) {
          z[7]++;
        } else {
          z[8]++;
        }
      } else {
        z[1]++;
      }
    });
    return z;
  }

  List<int> statsRepeat() {
    DateTime now = DateTime.now();
    List<int> z = List<int>.filled(9, 0);
    learning?.forEach((l) {
      z[0]++;
      if (l.isLearning) {
        if (l.nextLearn.isBefore(now)) {
          z[2]++;
        } else if (l.nextLearn
                .difference(now)
                .compareTo(const Duration(hours: 1)) <
            0) {
          z[3]++;
        } else if (l.nextLearn
                .difference(now)
                .compareTo(const Duration(hours: 24)) <
            0) {
          z[4]++;
        } else if (l.nextLearn
                .difference(now)
                .compareTo(const Duration(days: 7)) <
            0) {
          z[5]++;
        } else if (l.nextLearn
                .difference(now)
                .compareTo(const Duration(days: 30)) <
            0) {
          z[6]++;
        } else if (l.nextLearn
                .difference(now)
                .compareTo(const Duration(days: 365)) <
            0) {
          z[7]++;
        } else {
          z[8]++;
        }
      } else {
        z[1]++;
      }
    });
    return z;
  }
}
