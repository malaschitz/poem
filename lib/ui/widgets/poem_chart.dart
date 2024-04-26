import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class PoemChart extends StatelessWidget {
  final List<int> stats;
  const PoemChart({required Key key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<charts.Color> greens = charts.MaterialPalette.green.makeShades(5);
    List<StatsCh> data = <StatsCh>[
      StatsCh('new', stats[1], charts.MaterialPalette.red.shadeDefault.lighter),
      StatsCh('repeat', stats[2], charts.MaterialPalette.red.shadeDefault),
      StatsCh('hour', stats[3], greens[4]),
      StatsCh('day', stats[4], greens[3]),
      StatsCh('week', stats[5], greens[2]),
      StatsCh('month', stats[6], greens[1]),
      StatsCh('month2', stats[7], greens[0])
    ];

    List<charts.Series<StatsCh, int>> series = <charts.Series<StatsCh, int>>[
      charts.Series<StatsCh, int>(
        id: 'new',
        domainFn: (StatsCh a, int? i) => i ?? 0,
        measureFn: (StatsCh a, int? i) => a.amount,
        data: data,
        colorFn: (StatsCh a, int? i) => a.color,
      )
    ];

    return charts.PieChart(
      series,
      animate: false,
      layoutConfig: charts.LayoutConfig(
          leftMarginSpec: charts.MarginSpec.fixedPixel(0),
          topMarginSpec: charts.MarginSpec.fixedPixel(0),
          rightMarginSpec: charts.MarginSpec.fixedPixel(0),
          bottomMarginSpec: charts.MarginSpec.fixedPixel(0)),
      defaultInteractions: false,
    );
  }
}

class StatsCh {
  final String type;
  final int amount;
  final charts.Color color;

  StatsCh(this.type, this.amount, this.color);
}
