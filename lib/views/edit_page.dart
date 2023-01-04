import 'package:flutter/material.dart';
import 'package:jp_stock_mini_memo/components/adbanner.dart';
import 'package:jp_stock_mini_memo/components/custom_alert_dialog.dart';
import 'package:jp_stock_mini_memo/components/custom_text_form_field.dart';
import 'package:jp_stock_mini_memo/constants/text_style.dart';
import 'package:jp_stock_mini_memo/models/stock_memo.dart';
import 'package:jp_stock_mini_memo/viewmodels/edit_model.dart';
import 'package:jp_stock_mini_memo/views/list_page.dart';
import 'package:provider/provider.dart';

class EditPage extends StatelessWidget {
  final StockMemo? stockmemo;
  EditPage({
    super.key,
    required this.stockmemo,
  });
  final _key = GlobalKey<FormState>();

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool isUpdate = stockmemo != null;
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final memoController = TextEditingController();

    if (isUpdate) {
      nameController.text = stockmemo!.name;
      codeController.text = stockmemo!.code;
      memoController.text = stockmemo!.memo;
    }

    return ChangeNotifierProvider<EditModel>(
      create: (_) => EditModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isUpdate ? '$appName - 編集' : '$appName - 新規作成',
            style: appBarTitleTextStyle,
          ),
        ),
        body: Consumer<EditModel>(
          builder: (
            BuildContext context,
            EditModel model,
            Widget? child,
          ) =>
              Column(
            children: [
              AdBanner(),
              Expanded(
                child: Form(
                  key: _key,
                  child: ListView(
                    children: <Widget>[
                      const SizedBox(
                        height: 8,
                      ),
                      CustomTextFormField(
                        controller: codeController,
                        labelText: '証券コード',
                        maxLength: 4,
                        onChanged: (text) {
                          model.stockCode = text;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return '証券コードを入力してください';
                          } else if (!RegExp(r"\d{4}").hasMatch(value)) {
                            return '４桁の半角数字を入力してください';
                          }
                        },
                        keyboardType: TextInputType.number,
                      ),
                      CustomTextFormField(
                        controller: nameController,
                        labelText: '銘柄名',
                        onChanged: (text) {
                          model.stockName = text;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return '銘柄名を入力してください';
                          }
                        },
                        keyboardType: TextInputType.text,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ListTile(
                            title: const Text(
                              '市場',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            subtitle: DropdownButton<String>(
                              isExpanded: true,
                              underline: Container(
                                height: 1,
                                color: Colors.black26,
                              ),
                              onChanged: (String? value) {
                                model.onChanged(value!);
                                stockmemo?.market = value;
                              },
                              value: isUpdate
                                  ? stockmemo?.market
                                  : model.dropdownValue,
                              items:
                                  model.markets.map<DropdownMenuItem<String>>(
                                (String text) {
                                  return DropdownMenuItem<String>(
                                    value: text,
                                    child: Text(text),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ],
                      ),
                      CustomTextFormField(
                        controller: memoController,
                        labelText: 'メモ',
                        maxLines: 10,
                        onChanged: (text) {
                          model.stockMemo = text;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'メモを入力してください';
                          }
                        },
                        keyboardType: TextInputType.multiline,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            model.startLoading();
                            if (_key.currentState!.validate()) {
                              if (!isUpdate) {
                                await addMemo(model, context);
                              } else {
                                await updateMemo(model, context);
                              }
                            }
                            model.endLoading();
                          },
                          child: Text(
                            isUpdate ? '編集完了' : '保存',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future addMemo(
    EditModel model,
    BuildContext context,
  ) async {
    try {
      final navigator = Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ListPage(),
        ),
      );
      await model.addMemo();
      await showDialog(
        context: context,
        builder: (
          BuildContext context,
        ) {
          return const CustomAlertDialog(
            title: '保存しました',
            buttonText: 'OK',
          );
        },
      );
      await navigator;
    } catch (e) {
      showDialog(
        context: context,
        builder: (
          BuildContext context,
        ) {
          return CustomAlertDialog(
            title: e.toString(),
            buttonText: 'OK',
          );
        },
      );
    }
  }

  Future updateMemo(
    EditModel model,
    BuildContext context,
  ) async {
    try {
      final navigator = Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ListPage(),
        ),
      );
      await model.updateMemo(stockmemo!);
      await showDialog(
        context: context,
        builder: (
          BuildContext context,
        ) {
          return const CustomAlertDialog(
            title: '変更しました',
            buttonText: 'OK',
          );
        },
      );
      await navigator;
    } catch (e) {
      showDialog(
        context: context,
        builder: (
          BuildContext context,
        ) {
          return CustomAlertDialog(
            title: e.toString(),
            buttonText: 'OK',
          );
        },
      );
    }
  }
}
