import 'package:flutter/material.dart';
import 'package:poem/business_logic/model/poem.dart';
import 'package:poem/business_logic/utils/text_styles.dart';
import 'package:poem/ui/ui_helpers.dart';
import 'package:poem/ui/widgets/poem_chart.dart';

class PoemListItem extends StatelessWidget {
  final Poem poem;
  final VoidCallback onTap;
  const PoemListItem({super.key, required this.poem, required this.onTap});

  @override
  Widget build(BuildContext context) {
    DateTime nextTime = poem.nextTime();
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: const [
              BoxShadow(
                  blurRadius: 3.0,
                  offset: Offset(0.0, 2.0),
                  color: Color.fromARGB(80, 0, 0, 0))
            ]),
        child: Row(
          children: <Widget>[
            Column(
              children: [
                poem.repeatItems + poem.unseenItems > 0
                    ? Text(
                        ' ${poem.repeatItems}-${poem.unseenItems}-${poem.learning!.length - poem.unseenItems - poem.repeatItems} ',
                        style: poem.repeatItems == 0
                            ? poemBadgeStyle
                            : poemBadgeStyleRed)
                    : const Icon(
                        Icons.thumb_up,
                        color: Colors.grey,
                        size: 40.0,
                        semanticLabel: 'Všetko je prebrané',
                      ),
                const SizedBox(height: 3),
                Text(UIHelper.dateFormatNext(nextTime),
                    style: DateTime.now().isAfter(nextTime)
                        ? TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.pink[200])
                        : TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.grey[500])),
              ],
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(poem.author,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 16.0),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  Text(poem.title, maxLines: 2, overflow: TextOverflow.ellipsis)
                ],
              ),
            ),
            SizedBox(
              width: 70,
              height: 70,
              child: PoemChart(key: UniqueKey(), stats: poem.statsInfo()),
            )
          ],
        ),
      ),
    );
  }
}
