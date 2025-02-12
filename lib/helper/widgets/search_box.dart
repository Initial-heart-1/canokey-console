import 'package:canokey_console/generated/l10n.dart';
import 'package:canokey_console/helper/utils/smartcard.dart';
import 'package:canokey_console/helper/utils/ui_mixins.dart';
import 'package:canokey_console/helper/widgets/customized_text_style.dart';
import 'package:canokey_console/helper/widgets/spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SearchBox extends StatelessWidget with UIMixin {
  const SearchBox({super.key, this.formKey});

  final GlobalKey<FormState>? formKey;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: TextFormField(
        maxLines: 1,
        style: CustomizedTextStyle.bodyMedium(),
        onChanged: (value) {
          if (Get.currentRoute == '/applets/oath') {
            Get.find<RxString>(tag: 'oath_search').value = value;
          } else if (Get.currentRoute == '/applets/webauthn') {
            Get.find<RxString>(tag: 'webauthn_search').value = value;
          }
        },
        onTap: SmartCard.eject,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        decoration: InputDecoration(
          hintText: S.of(context).search,
          hintStyle: CustomizedTextStyle.bodySmall(xMuted: true),
          border: outlineInputBorder,
          enabledBorder: outlineInputBorder,
          focusedBorder: focusedInputBorder,
          prefixIcon: const Align(
            alignment: Alignment.center,
            child: Icon(LucideIcons.search, size: 14),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 36, maxWidth: 36, minHeight: 32, maxHeight: 32),
          contentPadding: Spacing.xy(16, 12),
          isCollapsed: true,
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
      ),
    );
  }
}
