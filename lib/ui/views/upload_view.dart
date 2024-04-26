// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poem/business_logic/utils/app_colors.dart';
import 'package:poem/business_logic/view_models/upload_view_model.dart';
import 'package:poem/services/service_locator.dart';
import 'package:poem/ui/ui_helpers.dart';
import 'package:poem/services/text/text_service.dart';
import 'package:easy_localization/easy_localization.dart';

final uploadProvider = ChangeNotifierProvider((_) => UploadViewModel());

class UploadView extends ConsumerStatefulWidget {
  const UploadView({super.key});

  @override
  UploadViewState createState() => UploadViewState();
}

class UploadViewState extends ConsumerState<UploadView> {
  final TextsService _textsService = serviceLocator<TextsService>();

  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final bodyController = TextEditingController();

  bool isPoem = true;
  int learning = 0;
  String lang = 'en';

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    print('init upload view');
    super.initState();
  }

  void addPoem(UploadViewModel model) async {
    learning = _textsService.splitBody(bodyController.text, isPoem).length;
    if (authorController.text.isEmpty ||
        titleController.text.isEmpty ||
        learning == 0) {
      final snackBar = SnackBar(
          content: const Text('err.alldata').tr(), backgroundColor: alertColor);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    if (learning < 4) {
      final snackBar = SnackBar(
          content: const Text('err.tooshort').tr(),
          backgroundColor: alertColor);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    try {
      await model.upload(authorController.text, titleController.text, isPoem,
          bodyController.text, lang);
      Navigator.pop(context);
    } catch (e) {
      final snackBar = SnackBar(
          content: Text('err.error'.tr(args: [e.toString()])),
          backgroundColor: alertColor);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      UploadViewModel model = ref.watch(uploadProvider);
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('new.poem').tr(),
        ),
        backgroundColor: backgroundColor,
        body: ListView(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextField(
                        controller: authorController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'poem.autor'.tr(),
                        )),
                    UIHelper.verticalSpaceSmall,
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'poem.title'.tr(),
                      ),
                    ),
                    UIHelper.verticalSpaceSmall,
                    CheckboxListTile(
                        value: isPoem,
                        onChanged: (checked) => setState(() {
                              isPoem = checked ?? true;
                              learning = _textsService
                                  .splitBody(bodyController.text, isPoem)
                                  .length;
                            }),
                        title: Text(isPoem ? 'poem'.tr() : 'prose'.tr()),
                        subtitle: const Text('poem.help').tr()),
                    UIHelper.verticalSpaceSmall,
                    DropdownButton<String>(
                      value: lang,
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          lang = newValue ?? lang;
                        });
                      },
                      items: <String>['en', 'sk']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value == 'en'
                              ? 'lang.standard'.tr()
                              : 'lang.slovak'.tr()),
                        );
                      }).toList(),
                    ),
                    UIHelper.verticalSpaceSmall,
                    TextField(
                      controller: bodyController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Text',
                      ),
                      minLines: 3,
                      maxLines: null,
                      onChanged: (body) {
                        setState(() {
                          learning =
                              _textsService.splitBody(body, isPoem).length;
                        });
                      },
                    ),
                    Text(
                      'edit.stats'.tr(args: ['$learning']),
                      style: const TextStyle(color: Colors.black26),
                    ),
                    UIHelper.verticalSpaceSmall,
                    ElevatedButton(
                      onPressed: () {
                        addPoem(model);
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(primaryColor),
                          foregroundColor:
                              MaterialStateProperty.all(whiteColor)),
                      child: Text('btn.save'.tr()),
                    ),
                    Text('info.6'.tr(args: ['$learning']),
                        style: const TextStyle(color: Colors.black87)),
                    UIHelper.verticalSpaceSmall,
                    Text('info.7'.tr(args: ['$learning']),
                        style: const TextStyle(color: Colors.black87)),
                  ],
                ))
          ],
        ),
      );
    });
  }
}
