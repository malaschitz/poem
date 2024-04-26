import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:poem/business_logic/model/learning.dart';
import 'package:poem/business_logic/model/poem.dart';
import 'package:poem/business_logic/utils/text_styles.dart';
import 'package:poem/services/service_locator.dart';
import 'package:poem/services/storage/store_service.dart';
import 'package:poem/services/text/text_service.dart';

Random random = Random(DateTime.now().millisecondsSinceEpoch);

class LearningViewModel extends ChangeNotifier {
  final StoreService _storeService = serviceLocator<StoreService>();

  late Poem poem;
  late Learning learning;
  late int repeatItems;
  late int unseenItems;
  late Guessing guess;
  late int learnMode; //0 - opakovanie, 1 - learning, 2 - drill
  late int answerMode; //0 - answer 1 - after answer 2 - after wrong answer
  late int
      maxMode; //najlepsi mode v danom learningu aby som sa stale nepytal na to iste
  late Function alertCallback;
  late Function scrollCallback;
  late Map drill;

  bool _busy = false;
  bool _disposed = false;

  DateTime lastClick = DateTime.now();
  String lastClickLetter = '';

  bool get busy => _busy;
  void setBusy(bool value) {
    if (value != _busy) {
      _busy = value;
      notifyListeners();
    }
  }

  void init(Poem p) {
    poem = p;
    learnMode = 0;
    answerMode = 0;
    maxMode = -1;
    drill = {};
    _nextLearning2();
  }

  void reread(Poem p) {
    p = _storeService.getPoem(p.key);
    init(p);
  }

  //vola sa ked je mode = 0
  void dalej() async {
    assert(learning.level == 0);
    setBusy(true);
    learning.isLearning = true;
    learning.nextLearn = DateTime.now().add(const Duration(hours: -1));
    learning.level = 1;
    learning.interval = 1;
    learning.counter = learning.counter + 1;
    _storeService.updateLearning(learning);
    _nextLearning2();
    setBusy(false);
  }

  void neviem() async {
    setBusy(true);
    //nevedel
    poem.diff = poem.safeDiff - 0.09;
    _storeService.updatePoem(poem);

    learning.isLearning = true;
    learning.nextLearn = DateTime.now().add(const Duration(seconds: -1));
    learning.level = 0;
    learning.interval = 0;
    learning.counter = learning.counter + 1;
    learning.wrong = learning.wrong + 1;
    _storeService.updateLearning(learning);
    answerMode = 2;
    _learnAfterDelay();
    setBusy(false);
  }

  void nextLetter(String letter) {
    setBusy(true);
    guess.guessed.add(letter);
    //check
    int ind = guess.guessed.length - 1;
    if (guess.guessed[ind] != guess.letters[ind]) {
      neviem();
      return;
    }
    //add empties
    for (int i = ind + 1; i < guess.letters.length; i++) {
      if (guess.letters[i] == '') {
        guess.guessed.add('');
      } else {
        break;
      }
    }
    //is end ?
    if (guess.guessed.length == guess.letters.length) {
      poem.diff = poem.safeDiff + 0.01;
      _storeService.updatePoem(poem);

      if (learnMode != 2) {
        int planned;
        if (learning.level == 1) {
          planned = 20;
        } else if (DateTime.now().isBefore(learning.nextLearn)) {
          planned =
              (learning.interval * (1.0 + random.nextDouble() / 2)).round();
        } else {
          int realInterval =
              ((DateTime.now().difference(learning.nextLearn).inSeconds +
                          learning.interval) *
                      (1.0 + random.nextDouble() / 2))
                  .round();
          planned = (learning.interval * poem.diff).round();
          if (realInterval > planned) {
            planned = realInterval;
          }
        }
        if (learning.level > 0 && planned < 20) {
          planned = 20;
        }
        learning.isLearning = true;
        learning.nextLearn = DateTime.now().add(Duration(seconds: planned));
        learning.interval = planned;
        learning.stars = learning.stars + 1;
        learning.level = learning.level + 1;
        learning.counter = learning.counter + 1;
        _storeService.updateLearning(learning);
      }
      answerMode = 1;
      _learnAfterDelay();
    }
    setBusy(false);
  }

  void _learnAfterDelay() {
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!_disposed) {
        setBusy(true);
        _nextLearning2();
        setBusy(false);
      }
    });
  }

  void _nextLearning2() {
    answerMode = 0;
    repeatItems = 0;
    unseenItems = 0;
    final DateTime now = DateTime.now();
    for (var l in poem.learning!) {
      if (l.isLearning) {
        if (now.isAfter(l.nextLearn)) {
          repeatItems++;
        }
      } else {
        unseenItems++;
      }
    }
    //
    if (repeatItems > 0) {
      //ideme opakovat
      int bestIndex = 9999999;
      DateTime hour = now.subtract(const Duration(minutes: 10));
      for (var l in poem.learning!) {
        if (l.isLearning &&
            now.isAfter(l.nextLearn) &&
            l.nextLearn.isBefore(hour)) {
          if (l.index < bestIndex) {
            learning = l;
            bestIndex = l.index;
          }
        }
      }
      if (bestIndex == 9999999) {
        Duration best = const Duration();
        for (var l in poem.learning!) {
          if (l.isLearning && now.isAfter(l.nextLearn)) {
            Duration diff = now.difference(l.nextLearn);
            if (diff.compareTo(best) > 0) {
              best = diff;
              learning = l;
            }
          }
        }
      }
      learnMode = 0;
    } else if (unseenItems > 0) {
      //ideme sa ucit nieco nove
      for (int i = 0; i < poem.learning!.length; i++) {
        Learning l = poem.learning![i];
        if (!l.isLearning) {
          learning = l;
          break;
        }
      }
      learnMode = 1;
    } else {
      //mali by sme sa na to ...
      int bestLevel = 1000000000;
      for (var l in poem.learning!) {
        if ((drill[l.index] ?? 0) < bestLevel) {
          bestLevel = drill[l.index] ?? 0;
          learning = l;
        }
      }
      learnMode = 2;
      drill[learning.index] = bestLevel + 1;
    }
    if (maxMode < learnMode) {
      if (maxMode == -1) {
        maxMode = learnMode;
      } else {
        maxMode = learnMode;
        if (maxMode == 1) {
          alertCallback('learning.question.1'.tr());
        } else {
          alertCallback('learning.question.2'.tr());
        }
      }
    }
    guess = Guessing(poem, learning);
    scrollCallback();
  }

  String get title {
    String t;
    if (learning.level > 0) {
      t = 'mode.repeat'.tr();
    } else if (learning.isLearning) {
      t = 'mode.learning'.tr();
    } else {
      t = 'mode.new'.tr();
    }
    return t;
  }

  List<AttrString> get attrText {
    List<AttrString> as = [];
    int f1 = learning.index - 4;
    if (f1 < 0) {
      as.add(AttrString(poem.author, 't'));
      as.add(AttrString(poem.title, 't'));
      f1 = 0;
    }
    //lines
    for (int i = f1; i < learning.index; i++) {
      as.add(AttrString(poem.learning![i].line, ''));
    }
    return as;
  }

  List<String> get answer {
    if (learning.level == 0) {
      //ucenie
      List<String> t = <String>[];
      for (int i = learning.index;
          i < learning.index + guess.rows.length && i < poem.learning!.length;
          i++) {
        if (i > learning.index) {
          //nothing
          //t += "\n";
        }
        t.add(poem.learning![i].line);
      }
      return t;
    }
    //casti slov
    int guessed = guess.guessed.length;
    List<String> t = <String>[];
    for (int i = 0; i < guess.rows.length; i++) {
      if (i > 0) {
        //nothing
        //t = t.trim() + "\n";
      }
      List<String> row = guess.rows[i];
      for (int j = 0; j < row.length; j++) {
        if (guessed > 0) {
          t.add(row[j]);
        } else {
          String z = '_${_underscore(learning.level < 5 ? row[j].length : 4)}';
          t.add(z);
        }
        guessed--;
      }
    }
    //t = t.trim();
    return t;
  }

  //return date of nearest learning
  DateTime nextLearning() {
    DateTime best = DateTime.now();
    bool z = false;
    for (var l in poem.learning!) {
      if (l.isLearning) {
        if (!z) {
          best = l.nextLearn;
          z = true;
        }
        if (l.nextLearn.isBefore(best)) {
          best = l.nextLearn;
        }
      }
    }
    return best;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  String _underscore(int n) {
    if (n < 3) {
      return '';
    }
    String t = '_';
    do {
      t = t + t;
    } while (t.length < n);
    return t.substring(0, n - 2);
  }
}

class Guessing {
  List<List<String>> rows = [];
  List<String> letters = [];
  List<String> guessed = [];

  factory Guessing(Poem poem, Learning learning) {
    final TextsService textsService = serviceLocator<TextsService>();
    Guessing g = Guessing._internal();
    g.rows = <List<String>>[];
    g.letters = [];
    g.guessed = [];
    //parse
    int rows = 1;
    //rows += (learning.level / 5).floor();  -- asi to nie je dobry napad
    for (int i = 0; i < rows; i++) {
      if (learning.index + i < poem.learning!.length) {
        List<String> row = [];
        String line = poem.learning![learning.index + i].line;
        line = line.replaceAll(',', ', ');
        line = line.replaceAll(';', '; ');
        line = line.replaceAll('  ', ' ');
        line = line.replaceAll('  ', ' ');
        line = line.trim();
        List<String> list = line.split(' ');
        for (var w in list) {
          String fl = textsService.firstLetter(w, poem.lang);
          row.add(w);
          g.letters.add(fl);
        }
        g.rows.add(row);
      }
    }
    //initial guesses
    for (int i = 0; i < g.letters.length; i++) {
      if (g.letters[i] == '') {
        g.guessed.add('');
      } else {
        break;
      }
    }
    return g;
  }

  Guessing._internal();
}
