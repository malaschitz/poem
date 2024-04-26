// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:poem/business_logic/utils/app_colors.dart';
import 'package:poem/business_logic/view_models/home_view_model.dart';
import 'package:poem/main.dart';
import 'package:poem/services/poems/poem_service.dart';
import 'package:poem/services/service_locator.dart';
import 'package:poem/ui/ui_helpers.dart';
import 'package:poem/ui/views/upload_view.dart';
import 'package:poem/ui/widgets/info_dialog2.dart';
import 'package:poem/ui/widgets/poems.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends ConsumerState<HomeView> {
  @override
  void initState() {
    super.initState();
    HomeViewModel model = ref.read(homeProvider);
    model.loadDataB();
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    return Consumer(
      builder: (context, watch, child) {
        ref.watch(homeProvider);

        return Scaffold(
          appBar: AppBar(
            title: const Text('appTitle').tr(),
            actions: <Widget>[
              TextButton(
                child: Text(context.locale.languageCode,
                    style: const TextStyle(fontSize: 20, color: whiteColor)),
                onPressed: () {
                  _changeLang();
                },
              ),
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Info',
                  onPressed: () {
                    _popupMenu(context);
                  },
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              UIHelper.verticalSpaceSmall,
              Expanded(
                child: Poems(key: UniqueKey()),
              )
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              _addPoem();
            },
            icon: const Icon(Icons.add),
            label: Text('addNewPoem'.tr()),
          ),
        );
      },
    );
  }

  void _changeLang() async {
    String? lang = await showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(200, 80, 0, 100),
      items: [
        const PopupMenuItem<String>(value: 'en', child: Text('English')),
        const PopupMenuItem<String>(value: 'sk', child: Text('Slovenčina')),
      ],
      elevation: 8.0,
    );
    if (lang != null && (lang == 'sk' || lang == 'en')) {
      context.setLocale(Locale(lang));
    }
  }

  void _popupMenu(BuildContext context) async {
    String? choice = await showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(200, 80, 0, 100),
      items: [
        const PopupMenuItem<String>(value: 'info', child: Text('info')),
        PopupMenuItem<String>(value: 'about', child: Text('home.about'.tr())),
        const PopupMenuItem<String>(value: 'export', child: Text('export')),
        const PopupMenuItem<String>(value: 'import', child: Text('import')),
      ],
      elevation: 8.0,
    );

    if (choice == 'info') {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return InfoDialog2(key: UniqueKey());
          });
    } else if (choice == 'about') {
      _infoPoem();
    } else if (choice == 'export') {
      _export(context);
    } else if (choice == 'import') {
      _import(context);
    }
  }

  void _infoPoem() {
    showAboutDialog(
        context: context,
        applicationIcon: const FlutterLogo(),
        applicationName: 'title'.tr(),
        applicationVersion: '2.2',
        applicationLegalese: 'applicationLegalese'.tr(),
        children: <Widget>[
          const Text('info.1').tr(),
          UIHelper.verticalSpaceSmall,
          const Text('info.2').tr(),
          UIHelper.verticalSpaceSmall,
          const Text('info.3').tr(),
          UIHelper.verticalSpaceSmall,
          const Text('info.4').tr(),
          UIHelper.verticalSpaceSmall,
          const Text('info.5').tr(),
        ]);
  }

  void _export(BuildContext context) async {
    //prepare json and share it
    HomeViewModel model = ref.read(homeProvider);
    await model.exportData();
  }

  void _import(BuildContext context) async {
    HomeViewModel model = ref.read(homeProvider);
    String msg = await model.importData();
    print('imported 3 $msg');
    if (msg != '') {
      final snackBar =
          SnackBar(content: Text(msg), backgroundColor: alertColor);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      model.loadDataA();
    }
  }

  void _addPoem() async {
    HomeViewModel model = ref.read(homeProvider);
    List<Map<String, dynamic>> poems = await serviceLocator<PoemService>()
        .poems(context, context.locale.languageCode);

    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          List<Widget> widgets = [
            ListTile(
                leading: const Icon(Icons.edit),
                title: Text('new.poem'.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                onTap: () => _newPoem())
          ];
          for (var p in poems) {
            widgets.add(ListTile(
                leading: const Icon(Icons.cloud_download),
                title: Text(p['Author']),
                subtitle: Text(p['Title']),
                onTap: () async {
                  Navigator.pop(context);
                  await model.savePoem(p);
                }));
          }
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: ListView(
              children: widgets,
            ),
          );
        },
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)));
  }

  _newPoem() async {
    HomeViewModel model = ref.read(homeProvider);
    Navigator.pop(context);
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const UploadView()));
    model.loadDataA();
  }
}
