import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:poem/business_logic/model/poem.dart';
import 'package:poem/services/service_locator.dart';
import 'package:poem/services/storage/store_service.dart';
import 'package:poem/ui/ui_helpers.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:poem/ui/widgets/poem_chart.dart';

class InfoDialog2 extends StatelessWidget {
  const InfoDialog2({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    StoreService storeService = serviceLocator<StoreService>();
    List<Poem> poems = storeService.getPoems();
    List<int> statsI = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    List<int> statsR = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    DateTime next = DateTime(9999);
    for (var p in poems) {
      List<int> zI = p.statsInfo();
      List<int> zR = p.statsRepeat();
      for (int i = 0; i < 8; i++) {
        statsI[i] = statsI[i] + zI[i];
        statsR[i] = statsR[i] + zR[i];
      }
      if (p.nextTime().isBefore(next)) {
        next = p.nextTime();
      }
    }

    return AlertDialog(
      title: Text('learn.info'.tr()),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('info.repeat.title'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w900)),
            Text('info.new'.tr(args: ['${statsI[1]}'])),
            Text('info.repeat'.tr(args: ['${statsI[2]}'])),
            Text('info.hour'.tr(args: ['${statsI[3]}/${statsR[3]}'])),
            Text('info.day'.tr(args: ['${statsI[4]}/${statsR[4]}'])),
            Text('info.week'.tr(args: ['${statsI[5]}/${statsR[5]}'])),
            Text('info.month'.tr(args: ['${statsI[6]}/${statsR[6]}'])),
            Text('info.year'.tr(args: ['${statsI[7]}/${statsR[7]}'])),
            Text('info.year.2'.tr(args: ['${statsI[8]}/${statsR[8]}'])),
            Text('info.sum'.tr(args: ['${statsI[0]}'])),
            Text('info.nearest'.tr(args: [(UIHelper.dateFormat(next))])),
            Container(
              width: 200,
              height: 200,
              color: Colors.white,
              child: PoemChart(key: UniqueKey(), stats: statsI),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('info.btn.close'.tr()))
      ],
    );
  }
}

class StatsCh {
  final String type;
  final int amount;
  final charts.Color color;

  StatsCh(this.type, this.amount, this.color);
}
