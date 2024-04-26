import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Contains useful consts to reduce boilerplate and duplicate code
class UIHelper {
  // Vertical spacing constants. Adjust to your liking.
  static const double _verticalSpaceSmall = 10.0;
  static const double _verticalSpaceMedium = 20.0;
  static const double _verticalSpaceLarge = 60.0;

  // Vertical spacing constants. Adjust to your liking.
  static const double _horizontalSpaceSmall = 10.0;
  static const double _horizontalSpaceMedium = 20.0;
  static const double _horizontalSpaceLarge = 60.0;

  // duble click speed
  static const Duration dblClick = Duration(milliseconds: 500);

  static const Widget verticalSpaceSmall =
      SizedBox(height: _verticalSpaceSmall);
  static const Widget verticalSpaceMedium =
      SizedBox(height: _verticalSpaceMedium);
  static const Widget verticalSpaceLarge =
      SizedBox(height: _verticalSpaceLarge);

  static const Widget horizontalSpaceSmall =
      SizedBox(width: _horizontalSpaceSmall);
  static const Widget horizontalSpaceMedium =
      SizedBox(width: _horizontalSpaceMedium);
  static const Widget horizontalSpaceLarge =
      SizedBox(width: _horizontalSpaceLarge);

  static String dateFormat(DateTime d) {
    var format = DateFormat.yMMMMd('en_US')..add_Hm();
    return format.format(d);
  }

  static String dateFormatNext(DateTime d) {
    if (d.year > 9000) return '';
    DateTime now = DateTime.now();
    Duration dur;
    String sign = '';
    if (now.isAfter(d)) {
      dur = now.difference(d);
      sign = '-';
    } else {
      dur = d.difference(now);
      sign = '+';
    }
    if (dur.inDays >= 2) {
      return '$sign${dur.inDays}D';
    }
    if (dur.inHours >= 2) {
      return '$sign${dur.inHours}H';
    }
    print(dur);
    return '$sign${dur.inMinutes}M';
  }
}
