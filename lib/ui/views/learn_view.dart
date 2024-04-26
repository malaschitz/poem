// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poem/business_logic/utils/app_colors.dart';
import 'package:poem/business_logic/model/poem.dart';
import 'package:poem/business_logic/utils/text_styles.dart';
import 'package:poem/business_logic/view_models/learning_view_model.dart';
import 'package:poem/services/service_locator.dart';
import 'package:poem/services/sound/sound_service.dart';
import 'package:poem/ui/ui_helpers.dart';
import 'package:poem/ui/views/edit_view.dart';
import 'package:poem/ui/widgets/info_dialog.dart';

final learnViewProvider = ChangeNotifierProvider((_) => LearningViewModel());

class LearnView extends ConsumerStatefulWidget {
  final Poem poem;
  const LearnView({required Key key, required this.poem}) : super(key: key);

  @override
  LearnViewState createState() => LearnViewState();
}

class LearnViewState extends ConsumerState<LearnView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ref.read(learnViewProvider).scrollCallback = _scrollCallback;
    ref.read(learnViewProvider).init(widget.poem);
    ref.read(learnViewProvider).alertCallback = _alertCallback;
  }

  @override
  Widget build(BuildContext context) {
    LearningViewModel model = ref.watch(learnViewProvider);

    return model.busy
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              backgroundColor: model.learnMode == 0
                  ? barColorMode0
                  : model.learnMode == 1
                      ? barColorMode1
                      : barColorMode2,
              title: Text(model.title),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'learn.info'.tr(),
                  onPressed: () {
                    _infoPoem(context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'edit.poem'.tr(),
                  onPressed: () {
                    _editPoem();
                  },
                )
              ],
            ),
            backgroundColor: backgroundColor,
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    '${model.repeatItems}-${model.unseenItems}-${model.poem.learning!.length - model.unseenItems - model.repeatItems}',
                    textAlign: TextAlign.right,
                    style: statsStyle,
                  ),
                  Expanded(
                      child: ListView(
                          controller: _scrollController,
                          children: <Widget>[
                        Card(
                            color: questionCardColor,
                            elevation: 4.0,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                  children: model.attrText
                                      .map((e) => e.attr == 't'
                                          ? Text(e.text,
                                              style: poemStyleT,
                                              textAlign: TextAlign.center)
                                          : Text(
                                              e.text,
                                              style: poemStyle,
                                              textAlign: TextAlign.center,
                                            ))
                                      .toList()),
                            )),
                        Card(
                          color: _cardColor(),
                          elevation: 4.0,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Wrap(
                              spacing: 5,
                              runSpacing: 0,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              verticalDirection: VerticalDirection.down,
                              alignment: WrapAlignment.center,
                              children: _answer(model.answer),
                            ),
                          ),
                        ),
                      ])),
                  (model.answerMode > 0
                      ? Center(
                          child: Text('learn.repeat'.tr(args: [
                          (UIHelper.dateFormat(model.learning.nextLearn))
                        ])))
                      : model.learning.level == 0
                          ? _buttonsNext()
                          : _letters()),
                  UIHelper.verticalSpaceSmall,
                ],
              ),
            ),
          );
  }

  Widget _buttonsNext() {
    if (ref.read(learnViewProvider).learnMode == 0) {
      return _btnNext();
    }
    return Row(
      children: [
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
          },
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(alertColor),
              foregroundColor: MaterialStateProperty.all(whiteColor)),
          child: Text('learn.stop'.tr(), style: const TextStyle(fontSize: 20)),
        ),
        UIHelper.horizontalSpaceSmall,
        Expanded(child: _btnNext()),
      ],
    );
  }

  ElevatedButton _btnNext() {
    return ElevatedButton(
      onPressed: () async {
        ref.read(learnViewProvider).dalej();
      },
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(primaryColor),
          foregroundColor: MaterialStateProperty.all(whiteColor)),
      child: Text('learn.next'.tr(), style: const TextStyle(fontSize: 20)),
    );
  }

  List<Widget> _answer(List<String> list) {
    List<Widget> answers = [];
    for (var element in list) {
      if (element.startsWith('_')) {
        answers.add(Chip(
          avatar: CircleAvatar(
            backgroundColor: Colors.blue.shade200,
            child: const Text('?'),
          ),
          label:
              Text(element.substring(1), style: const TextStyle(fontSize: 15)),
          backgroundColor: Colors.blue.shade100,
        ));
      } else {
        answers.add(
          Text(element, style: poemStyle),
        );
      }
    }
    return answers;
  }

  Widget _letters() {
    LearningViewModel model = ref.read(learnViewProvider);
    List<Widget> buttons = [];
    for (var l in model.poem.firstLetters) {
      buttons.add(MaterialButton(
        height: 40,
        minWidth: 50,
        onPressed: () async {
          DateTime n = DateTime.now();
          if (n.difference(model.lastClick) < UIHelper.dblClick &&
              model.lastClickLetter == l) {
            return;
          }
          model.lastClick = n;
          model.lastClickLetter = l;
          serviceLocator<SoundService>().click();
          model.nextLetter(l);
        },
        color: primaryColor,
        textColor: whiteColor,
        child: Text(l, style: const TextStyle(fontSize: 20)),
      ));
    }
    buttons.add(MaterialButton(
      onPressed: () async {
        model.neviem();
      },
      color: alertColor,
      textColor: whiteColor,
      child: Text('learn.idontknow'.tr(), style: const TextStyle(fontSize: 20)),
    ));
    return Center(
      child: Wrap(
        spacing: 10,
        runSpacing: 2.0,
        crossAxisAlignment: WrapCrossAlignment.start,
        verticalDirection: VerticalDirection.down,
        children: buttons,
      ),
    );
  }

  _editPoem() async {
    LearningViewModel model = ref.read(learnViewProvider);
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditView(key: UniqueKey(), poem: model.poem)));
    if (model.poem.isInBox) {
      model.reread(model.poem);
    } else {
      Navigator.pop(context);
    }
  }

  Color _cardColor() {
    LearningViewModel model = ref.read(learnViewProvider);
    switch (model.answerMode) {
      case 1:
        return okCardColor;
      case 2:
        return wrongCardColor;
      default:
        return questionCardColor;
    }
  }

  void _infoPoem(BuildContext context2) {
    LearningViewModel model = ref.read(learnViewProvider);
    showDialog(
        context: context2,
        builder: (BuildContext context) {
          return InfoDialog(key: UniqueKey(), model: model);
        });
  }

  void _alertCallback(String msg) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('alert.warning'.tr()),
            content: Text(msg),
            actions: <Widget>[
              TextButton(
                child: Text('alert.break'.tr()),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('alert.continue'.tr()),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.elasticOut);
    } else {
      Timer(const Duration(milliseconds: 400), () => _scrollToBottom());
    }
  }

  void _scrollCallback() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }
}
