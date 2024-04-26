import 'dart:collection';
import 'package:diacritic/diacritic.dart';

class TextsService {
  List<String> splitBody(String body, bool isPoem) {
    List<String> verse = [];
    if (!isPoem) {
      //remove new line
      body = body.replaceAll('\n', ' ');
    }
    body = body.trim();
    int len = body.length;
    for (; true;) {
      body = body.replaceAll('  ', ' ');
      body = body.replaceAll('\n\n', '\n');
      if (body.length == len) {
        break;
      }
      len = body.length;
    }

    int f = -1;
    for (; true;) {
      int f2 = -1;
      String v;
      if (isPoem) {
        f2 = body.indexOf('\n', f + 1);
        if (f2 == -1) {
          v = body.substring(f + 1);
        } else {
          v = body.substring(f + 1, f2);
        }
      } else {
        f2 = body.indexOf(RegExp('[.!?]'), f + 1);
        if (f2 == -1) {
          v = body.substring(f + 1);
        } else {
          v = body.substring(f + 1, f2 + 1);
        }
      }
      v = v.trim();
      if (v.isNotEmpty) {
        verse.add(v);
      }
      if (f2 == -1) {
        break;
      }
      f = f2;
    }
    return verse;
  }

  String firstLetter(String word, String lang) {
    for (int i = 0; i < word.length; i++) {
      if (lang == 'sk' || lang == 'cs') {
        String ch = ('$word ').substring(i, i + 2);
        ch = ch.toUpperCase();
        if (ch == 'CH') {
          return ch;
        }
      }
      //
      String fl = word.substring(i, i + 1);
      fl = fl.toUpperCase();
      if (fl.compareTo('A') >= 0 && fl.compareTo('Z') <= 0) {
        return fl;
      } else if (fl.toLowerCase().compareTo(fl) != 0) {
        return fl;
      }
    }
    return '';
  }

  List<String> firstLetters(String body, String lang) {
    SplayTreeSet<String> st = SplayTreeSet();
    body = body.replaceAll(',', ', ');
    body = body.replaceAll(';', '; ');
    body = body.replaceAll('  ', ' ');
    body = body.replaceAll('  ', ' ');
    body = body.replaceAll('\n', ' ');
    List<String> list = body.split(' ');
    for (var word in list) {
      String fl = firstLetter(word, lang);
      if (fl.isNotEmpty) {
        st.add(fl);
      }
    }
    List<String> res = st.toList();
    res.sort((a, b) {
      String ad = removeDiacritics(a);
      String bd = removeDiacritics(b);
      if (ad == 'CH') {
        ad = 'HA';
      }
      if (bd == 'CH') {
        bd = 'HA';
      }
      int w = ad.compareTo(bd);

      if (w == 0) {
        return a.compareTo(b);
      } else {
        return w;
      }
    });
    return res;
  }
}
