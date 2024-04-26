import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:poem/business_logic/view_models/learning_view_model.dart';
import 'package:poem/ui/ui_helpers.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:poem/ui/widgets/poem_chart.dart';

class InfoDialog extends StatelessWidget {
  final LearningViewModel model;
  const InfoDialog({required Key key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<int> statsI = model.poem.statsInfo();
    List<int> statsR = model.poem.statsRepeat();

    return AlertDialog(
      title: Text('learn.info'.tr()),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('info.autor'.tr(args: [(model.poem.author)])),
            Text('info.work'.tr(args: [(model.poem.title)])),
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
            Text('info.nearest'
                .tr(args: [(UIHelper.dateFormat(model.nextLearning()))])),
            Text(
                'info.diff'.tr(args: [model.poem.safeDiff.toStringAsFixed(2)])),
            Container(
              width: 200,
              height: 200,
              color: Colors.white,
              child: PoemChart(key: UniqueKey(), stats: model.poem.statsInfo()),
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
