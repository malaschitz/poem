// ignore_for_file: prefer_single_quotes

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poem/business_logic/view_models/home_view_model.dart';
import 'package:poem/main.dart';
import 'package:poem/ui/views/learn_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:poem/ui/widgets/poemlist_item.dart';

class Poems extends StatelessWidget {
  const Poems({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        HomeViewModel model = ref.watch(homeProvider);

        return model.busy
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : (model.poems.isNotEmpty
                ? ListView.builder(
                    itemCount: model.poems.length,
                    itemBuilder: (context, index) => PoemListItem(
                      poem: model.poems[index],
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LearnView(
                                    key: UniqueKey(),
                                    poem: model.poems[index])));
                        model.loadDataA();
                      },
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "label.nopoems".tr(),
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                  ));
      },
    );
  }
}
