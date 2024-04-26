import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poem/business_logic/model/learning.dart';
import 'package:poem/business_logic/model/poem.dart';
import 'package:poem/business_logic/utils/app_colors.dart';
import 'package:poem/business_logic/utils/text_styles.dart';
import 'package:poem/business_logic/view_models/edit_view_model.dart';
import 'package:poem/ui/ui_helpers.dart';
import 'package:easy_localization/easy_localization.dart';

final editProvider = ChangeNotifierProvider((_) => EditViewModel());

class EditView extends ConsumerStatefulWidget {
  final Poem poem;
  const EditView({required Key key, required this.poem}) : super(key: key);

  @override
  EditViewState createState() => EditViewState();
}

class EditViewState extends ConsumerState<EditView> {
  //final EditViewModel model = serviceLocator<EditViewModel>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    ref.read(editProvider).init(widget.poem);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      EditViewModel model = ref.watch(editProvider);

      List<Widget> children = <Widget>[
        TextField(
          controller: TextEditingController(text: model.poem.author),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'poem.autor'.tr(),
          ),
          onChanged: (text) => model.poem.author = text,
        ),
        UIHelper.verticalSpaceSmall,
        TextField(
          controller: TextEditingController(text: model.poem.title),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'poem.title'.tr(),
          ),
          onChanged: (text) => model.poem.title = text,
        ),
        UIHelper.verticalSpaceSmall,
        DropdownButton<String>(
          value: model.poem.lang,
          icon: const Icon(Icons.arrow_downward),
          iconSize: 24,
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) model.poem.lang = newValue;
          },
          items: <String>['en', 'sk']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                  value == 'en' ? 'lang.standard'.tr() : 'lang.slovak'.tr()),
            );
          }).toList(),
        ),
        UIHelper.verticalSpaceSmall,
        UIHelper.verticalSpaceSmall,
        ElevatedButton(
          onPressed: () {
            _savePoem(model);
          },
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(primaryColor),
              foregroundColor: MaterialStateProperty.all(whiteColor)),
          child: Text('btn.save'.tr()),
        ),
        UIHelper.verticalSpaceSmall,
        ElevatedButton(
          onPressed: () {
            _deletePoem(context);
          },
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(alertColor),
              foregroundColor: MaterialStateProperty.all(whiteColor)),
          child: Text('btn.delete'.tr()),
        ),
        UIHelper.verticalSpaceSmall,
        ElevatedButton(
          onPressed: () {
            _resetPoem();
          },
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(alertColor),
              foregroundColor: MaterialStateProperty.all(whiteColor)),
          child: Text('btn.reset'.tr()),
        ),
      ];
      for (int i = 0; i < model.poem.learning!.length; i++) {
        children.add(UIHelper.verticalSpaceSmall);
        Learning l = model.poem.learning![i];
        children.add(Row(
          children: [
            Expanded(
                flex: 10, child: Text(l.line, style: poemStyle, maxLines: 10)),
            Expanded(
                flex: 1,
                child: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editLearning(l, model))),
          ],
        ));
        if (l.isLearning) {
          children.add(
            Row(
              children: [
                Text(
                  'learn.repeat'.tr(args: [(UIHelper.dateFormat(l.nextLearn))]),
                ),
                const Spacer(),
                FilledButton(
                  child: Text('btn.reset'.tr()),
                  onPressed: () {
                    _resetLearning(l, model);
                  },
                ),
              ],
            ),
          );
        }
      }

      var scaffold = Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('edit.poem').tr(),
        ),
        backgroundColor: backgroundColor,
        body: ListView(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ))
          ],
        ),
      );
      return scaffold;
    });
  }

  void _editLearning(Learning l, EditViewModel model) async {
    TextEditingController textFieldController = TextEditingController();
    textFieldController.text = l.line;

    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('edit.poem'.tr()),
          content: TextField(
            controller: textFieldController,
          ),
          actions: <Widget>[
            FilledButton(
              child: Text('back'.tr()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('btn.save'.tr()),
              onPressed: () async {
                if (textFieldController.text.isNotEmpty) {
                  l.line = textFieldController.text;
                  model.updateLearning(l);
                  Navigator.of(context).pop();
                }
              },
            )
          ],
        );
      },
    );
  }

  void _savePoem(EditViewModel model) async {
    if (model.poem.author.isEmpty || model.poem.title.isEmpty) {
      final snackBar = SnackBar(
          content: const Text('err.alldata').tr(), backgroundColor: alertColor);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    try {
      model.updatePoem();
      Navigator.pop(context);
    } catch (e) {
      final snackBar = SnackBar(
          content: Text('err.error'.tr(args: [e.toString()])),
          backgroundColor: alertColor);

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _resetLearning(Learning l, EditViewModel model) async {
    model.resetLearning(l);
  }

  Future<void> _deletePoem(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('delete.title'.tr()),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('delete.text1'.tr()),
                Text('delete.text2'.tr()),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('back'.tr()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('btn.delete'.tr()),
              onPressed: () async {
                ref.read(editProvider).deletePoem();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Future<void> _resetPoem() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('reset.title'.tr()),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('reset.text1'.tr()),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('back'.tr()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('btn.reset'.tr()),
              onPressed: () async {
                ref.read(editProvider).resetPoem();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}
