import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:canokey_console/controller/applets/piv.dart';
import 'package:canokey_console/generated/l10n.dart';
import 'package:canokey_console/helper/extensions/date_time_extension.dart';
import 'package:canokey_console/helper/theme/admin_theme.dart';
import 'package:canokey_console/helper/theme/app_style.dart';
import 'package:canokey_console/helper/theme/app_theme.dart';
import 'package:canokey_console/helper/utils/prompts.dart';
import 'package:canokey_console/helper/utils/shadow.dart';
import 'package:canokey_console/helper/utils/smartcard.dart';
import 'package:canokey_console/helper/utils/ui_mixins.dart';
import 'package:canokey_console/helper/widgets/customized_button.dart';
import 'package:canokey_console/helper/widgets/customized_card.dart';
import 'package:canokey_console/helper/widgets/customized_container.dart';
import 'package:canokey_console/helper/widgets/customized_text.dart';
import 'package:canokey_console/helper/widgets/field_validator.dart';
import 'package:canokey_console/helper/widgets/form_validator.dart';
import 'package:canokey_console/helper/widgets/responsive.dart';
import 'package:canokey_console/helper/widgets/spacing.dart';
import 'package:canokey_console/helper/widgets/validators.dart';
import 'package:canokey_console/models/piv.dart';
import 'package:canokey_console/views/layout/layout.dart';
import 'package:convert/convert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pem/pem.dart';

final log = Logger('Console:PIV:View');

class PivPage extends StatefulWidget {
  const PivPage({Key? key}) : super(key: key);

  @override
  State<PivPage> createState() => _PivPageState();
}

class _PivPageState extends State<PivPage> with SingleTickerProviderStateMixin, UIMixin {
  late PivController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(PivController());
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: 'PIV',
      topActions: InkWell(
        onTap: () {
          if (controller.polled) {
            controller.refreshData('');
          } else {
            Prompts.showInputPinDialog(
              title: S.of(context).settingsInputPin,
              label: "PIN",
              prompt: S.of(context).passInputPinPrompt,
            ).then((value) {
              controller.refreshData(value);
            }).onError((error, stackTrace) => null); // User canceled
          }
        },
        child: Icon(LucideIcons.refreshCw, size: 20, color: topBarTheme.onBackground),
      ),
      child: GetBuilder(
        init: controller,
        builder: (_) {
          if (!controller.polled) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacing.height(MediaQuery.of(context).size.height / 2 - 120),
                Center(
                    child: Padding(
                  padding: Spacing.horizontal(36),
                  child: CustomizedText.bodyMedium(S.of(context).pollCanoKey, fontSize: 24),
                )),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: Spacing.x(flexSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Spacing.height(20),
                    CustomizedCard(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      shadow: Shadow(elevation: 0.5, position: ShadowPosition.bottom),
                      paddingAll: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            color: contentTheme.primary.withOpacity(0.08),
                            padding: Spacing.xy(16, 12),
                            child: Row(
                              children: [
                                Icon(LucideIcons.keyboard, color: contentTheme.primary, size: 16),
                                Spacing.width(12),
                                CustomizedText.titleMedium(S.of(context).pivPinManagement, fontWeight: 600, color: contentTheme.primary)
                              ],
                            ),
                          ),
                          Padding(
                            padding: Spacing.xy(flexSpacing, 16),
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                CustomizedButton(
                                  onPressed: () {
                                    _showChangePinDialog(
                                      title: S.of(context).changePin,
                                      oldValueLabel: S.of(context).oldPin,
                                      newValueLabel: S.of(context).newPin,
                                      prompt: S.of(context).changePinPrompt(6, 8),
                                      validators: [LengthValidator(min: 6, max: 8)],
                                      handler: controller.changePin,
                                    );
                                  },
                                  elevation: 0,
                                  padding: Spacing.xy(20, 16),
                                  backgroundColor: contentTheme.primary,
                                  borderRadiusAll: AppStyle.buttonRadius.medium,
                                  child: CustomizedText.bodySmall(S.of(context).changePin, color: contentTheme.onPrimary),
                                ),
                                CustomizedButton(
                                  onPressed: () {
                                    _showChangePinDialog(
                                      title: S.of(context).pivChangePUK,
                                      oldValueLabel: S.of(context).pivOldPUK,
                                      newValueLabel: S.of(context).pivNewPUK,
                                      prompt: S.of(context).pivChangePUKPrompt(6, 8),
                                      validators: [LengthValidator(min: 6, max: 8)],
                                      handler: controller.changePUK,
                                    );
                                  },
                                  elevation: 0,
                                  padding: Spacing.xy(20, 16),
                                  backgroundColor: contentTheme.primary,
                                  borderRadiusAll: AppStyle.buttonRadius.medium,
                                  child: CustomizedText.bodySmall(S.of(context).pivChangePUK, color: contentTheme.onPrimary),
                                ),
                                CustomizedButton(
                                  onPressed: _showChangeManagementKeyDialog,
                                  elevation: 0,
                                  padding: Spacing.xy(20, 16),
                                  backgroundColor: contentTheme.primary,
                                  borderRadiusAll: AppStyle.buttonRadius.medium,
                                  child: CustomizedText.bodySmall(S.of(context).pivChangeManagementKey, color: contentTheme.onPrimary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacing.height(20),
                    CustomizedCard(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      shadow: Shadow(elevation: 0.5, position: ShadowPosition.bottom),
                      paddingAll: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            color: contentTheme.primary.withOpacity(0.08),
                            padding: Spacing.xy(16, 12),
                            child: Row(
                              children: [
                                Icon(LucideIcons.keyboard, color: contentTheme.primary, size: 16),
                                Spacing.width(12),
                                CustomizedText.titleMedium(S.of(context).pivSlots, fontWeight: 600, color: contentTheme.primary)
                              ],
                            ),
                          ),
                          Padding(
                              padding: Spacing.xy(flexSpacing, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfo(S.of(context).pivAuthentication, '9A', controller.slots[0x9A]),
                                  Spacing.height(16),
                                  _buildInfo(S.of(context).pivSignature, '9C', controller.slots[0x9C]),
                                  Spacing.height(16),
                                  _buildInfo(S.of(context).pivKeyManagement, '9D', controller.slots[0x9D]),
                                  Spacing.height(16),
                                  _buildInfo(S.of(context).pivCardAuthentication, '9E', controller.slots[0x9E]),
                                  Spacing.height(16),
                                  _buildInfo(S.of(context).pivRetired1, '82', controller.slots[0x82]),
                                  Spacing.height(16),
                                  _buildInfo(S.of(context).pivRetired2, '83', controller.slots[0x83]),
                                ],
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  _showChangePinDialog({
    required String title,
    required String oldValueLabel,
    required String newValueLabel,
    required String prompt,
    List<FieldValidatorRule> validators = const [],
    required Function(String, String) handler,
  }) {
    RxBool showOldPin = false.obs;
    RxBool showNewPin = false.obs;
    FormValidator validator = FormValidator();
    validator.addField('old', required: true, controller: TextEditingController(), validators: validators);
    validator.addField('new', required: true, controller: TextEditingController(), validators: validators);

    Get.dialog(Dialog(
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: Spacing.all(16),
              child: CustomizedText.labelLarge(title),
            ),
            Divider(height: 0, thickness: 1),
            Padding(
                padding: Spacing.all(16),
                child: Form(
                    key: validator.formKey,
                    child: Column(
                      children: [
                        CustomizedText.bodyMedium(prompt),
                        Spacing.height(16),
                        Obx(() => TextFormField(
                              autofocus: true,
                              onTap: () => SmartCard.eject(),
                              obscureText: !showOldPin.value,
                              controller: validator.getController('old'),
                              validator: validator.getValidator('old'),
                              decoration: InputDecoration(
                                labelText: oldValueLabel,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1, strokeAlign: 0, color: AppTheme.theme.colorScheme.onBackground.withAlpha(80)),
                                ),
                                floatingLabelBehavior: FloatingLabelBehavior.auto,
                                suffixIcon: IconButton(
                                  onPressed: () => showOldPin.value = !showOldPin.value,
                                  icon: Icon(showOldPin.value ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                ),
                              ),
                            )),
                        Spacing.height(16),
                        Obx(() => TextFormField(
                              onTap: () => SmartCard.eject(),
                              obscureText: !showNewPin.value,
                              controller: validator.getController('new'),
                              validator: validator.getValidator('new'),
                              decoration: InputDecoration(
                                labelText: newValueLabel,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1, strokeAlign: 0, color: AppTheme.theme.colorScheme.onBackground.withAlpha(80)),
                                ),
                                floatingLabelBehavior: FloatingLabelBehavior.auto,
                                suffixIcon: IconButton(
                                  onPressed: () => showNewPin.value = !showNewPin.value,
                                  icon: Icon(showNewPin.value ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                ),
                              ),
                            )),
                      ],
                    ))),
            Divider(height: 0, thickness: 1),
            Padding(
              padding: Spacing.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomizedButton.rounded(
                    onPressed: () {
                      Navigator.pop(Get.context!);
                    },
                    elevation: 0,
                    padding: Spacing.xy(20, 16),
                    backgroundColor: ContentThemeColor.secondary.color,
                    child: CustomizedText.labelMedium(S.of(Get.context!).cancel, color: ContentThemeColor.secondary.onColor),
                  ),
                  Spacing.width(16),
                  CustomizedButton.rounded(
                    onPressed: () {
                      if (validator.validateForm()) {
                        handler(validator.getController('old')!.text, validator.getController('new')!.text);
                      }
                    },
                    elevation: 0,
                    padding: Spacing.xy(20, 16),
                    backgroundColor: ContentThemeColor.primary.color,
                    child: CustomizedText.labelMedium(S.of(Get.context!).confirm, color: ContentThemeColor.primary.onColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  _showChangeManagementKeyDialog() {
    FormValidator validator = FormValidator();
    validator.addField('old', required: true, controller: TextEditingController(), validators: [LengthValidator(exact: 48), HexStringValidator()]);
    validator.addField('new', required: true, controller: TextEditingController(), validators: [LengthValidator(exact: 48), HexStringValidator()]);

    Get.dialog(Dialog(
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: Spacing.all(16),
              child: CustomizedText.labelLarge(S.of(context).pivChangeManagementKey),
            ),
            Divider(height: 0, thickness: 1),
            Padding(
                padding: Spacing.all(16),
                child: Form(
                    key: validator.formKey,
                    child: Column(children: [
                      CustomizedText.bodyMedium(S.of(context).pivChangeManagementKeyPrompt),
                      Spacing.height(16),
                      Row(children: [
                        SizedBox(
                          width: 235,
                          child: TextFormField(
                            autofocus: true,
                            onTap: () => SmartCard.eject(),
                            controller: validator.getController('old'),
                            validator: validator.getValidator('old'),
                            decoration: InputDecoration(
                              labelText: S.of(context).pivOldManagementKey,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1, strokeAlign: 0, color: AppTheme.theme.colorScheme.onBackground.withAlpha(80)),
                              ),
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                            ),
                          ),
                        ),
                        Spacing.width(16),
                        CustomizedButton(
                          onPressed: () {
                            validator.getController('old')!.text = '010203040506070801020304050607080102030405060708';
                          },
                          elevation: 0,
                          padding: Spacing.xy(20, 16),
                          backgroundColor: ContentThemeColor.primary.color,
                          child: CustomizedText.labelMedium(S.of(context).pivUseDefaultManagementKey, color: ContentThemeColor.primary.onColor),
                        ),
                      ]),
                      Spacing.height(16),
                      Row(children: [
                        SizedBox(
                          width: 235,
                          child: TextFormField(
                            onTap: () => SmartCard.eject(),
                            controller: validator.getController('new'),
                            validator: validator.getValidator('new'),
                            decoration: InputDecoration(
                              labelText: S.of(context).pivNewManagementKey,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1, strokeAlign: 0, color: AppTheme.theme.colorScheme.onBackground.withAlpha(80)),
                              ),
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                            ),
                          ),
                        ),
                        Spacing.width(16),
                        CustomizedButton(
                          onPressed: () {
                            final random = Random.secure();
                            final values = List<int>.generate(24, (i) => random.nextInt(256));
                            validator.getController('new')!.text = hex.encode(values);
                          },
                          elevation: 0,
                          padding: Spacing.xy(20, 16),
                          backgroundColor: ContentThemeColor.primary.color,
                          child: CustomizedText.labelMedium(S.of(context).pivRandomManagementKey, color: ContentThemeColor.primary.onColor),
                        ),
                      ])
                    ]))),
            Divider(height: 0, thickness: 1),
            Padding(
              padding: Spacing.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomizedButton.rounded(
                    onPressed: () {
                      Navigator.pop(Get.context!);
                    },
                    elevation: 0,
                    padding: Spacing.xy(20, 16),
                    backgroundColor: ContentThemeColor.secondary.color,
                    child: CustomizedText.labelMedium(S.of(Get.context!).cancel, color: ContentThemeColor.secondary.onColor),
                  ),
                  Spacing.width(16),
                  CustomizedButton.rounded(
                    onPressed: () async {
                      if (validator.validateForm()) {
                        final oldKey = validator.getController('old')!.text;
                        if (!await controller.verifyManagementKey(oldKey)) {
                          Prompts.showPrompt(S.of(Get.context!).pivManagementKeyVerificationFailed, ContentThemeColor.danger);
                          return;
                        }
                        controller.setManagementKey(validator.getController('new')!.text);
                      }
                    },
                    elevation: 0,
                    padding: Spacing.xy(20, 16),
                    backgroundColor: ContentThemeColor.primary.color,
                    child: CustomizedText.labelMedium(S.of(Get.context!).confirm, color: ContentThemeColor.primary.onColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildInfo(String title, String slotNumber, SlotInfo? slot) {
    return InkWell(
      onTap: () {
        _showSlotDetailDialog(title, slotNumber, slot);
      },
      child: Row(
        children: [
          CustomizedContainer(
            paddingAll: 4,
            height: 32,
            width: 32,
            child: Icon(LucideIcons.fileLock, size: 20),
          ),
          Spacing.width(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomizedText.bodyMedium('$title - $slotNumber', fontSize: 16),
                if (slot != null) ...[
                  InkWell(child: CustomizedText.bodySmall('${S.of(context).pivAlgorithm}: ${slot.algorithm.name.toUpperCase()}')),
                  InkWell(
                      child: CustomizedText.bodySmall(
                          '${S.of(context).pivCertificate}: ${_displayDN(slot.cert!.tbsCertificate!.subject) ?? S.of(context).pivEmpty}')),
                ] else ...[
                  CustomizedText.bodySmall(S.of(context).pivEmpty),
                ],
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios)
        ],
      ),
    );
  }

  _showSlotDetailDialog(String title, String slotNumber, SlotInfo? slot) {
    Get.dialog(Dialog(
      child: SizedBox(
        width: slot == null ? 400 : max(430, MediaQuery.of(context).size.width * 0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: Spacing.all(16),
              child: CustomizedText.labelLarge('$title - $slotNumber'),
            ),
            Divider(height: 0, thickness: 1),
            if (slot != null && slot.cert != null) ...[
              Padding(
                  padding: Spacing.all(16),
                  child: Form(
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: _displayDN(slot.cert!.tbsCertificate!.subject),
                          readOnly: true,
                          decoration: InputDecoration(labelText: 'Subject', border: outlineInputBorder, floatingLabelBehavior: FloatingLabelBehavior.auto),
                        ),
                        Spacing.height(16),
                        TextFormField(
                          initialValue: _displayDN(slot.cert!.tbsCertificate!.issuer),
                          readOnly: true,
                          decoration: InputDecoration(labelText: 'Issuer', border: outlineInputBorder, floatingLabelBehavior: FloatingLabelBehavior.auto),
                        ),
                        Spacing.height(16),
                        TextFormField(
                          initialValue: slot.cert!.tbsCertificate!.serialNumber.toRadixString(16),
                          readOnly: true,
                          decoration: InputDecoration(labelText: 'Serial', border: outlineInputBorder, floatingLabelBehavior: FloatingLabelBehavior.auto),
                        ),
                        Spacing.height(16),
                        TextFormField(
                          initialValue: slot.cert!.sha256Thumbprint,
                          readOnly: true,
                          decoration:
                              InputDecoration(labelText: 'Fingerprint (SHA256)', border: outlineInputBorder, floatingLabelBehavior: FloatingLabelBehavior.auto),
                        ),
                        Spacing.height(16),
                        TextFormField(
                          initialValue: slot.cert!.tbsCertificate!.validity.notBefore.toIsoDateString(),
                          readOnly: true,
                          decoration: InputDecoration(labelText: 'Valid from', border: outlineInputBorder, floatingLabelBehavior: FloatingLabelBehavior.auto),
                        ),
                        Spacing.height(16),
                        TextFormField(
                          initialValue: slot.cert!.tbsCertificate!.validity.notAfter.toIsoDateString(),
                          readOnly: true,
                          decoration: InputDecoration(labelText: 'Valid to', border: outlineInputBorder, floatingLabelBehavior: FloatingLabelBehavior.auto),
                        ),
                        Spacing.height(16),
                      ],
                    ),
                  )),
              Divider(height: 0, thickness: 1)
            ],
            Padding(
              padding: Spacing.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomizedButton.rounded(
                    onPressed: () {},
                    elevation: 0,
                    padding: Spacing.xy(20, 16),
                    backgroundColor: contentTheme.primary,
                    child: CustomizedText.labelMedium(S.of(context).pivGenerate, color: contentTheme.onSecondary),
                  ),
                  Spacing.width(12),
                  CustomizedButton.rounded(
                    onPressed: _showImportDialog,
                    elevation: 0,
                    padding: Spacing.xy(20, 16),
                    backgroundColor: contentTheme.primary,
                    child: CustomizedText.labelMedium(S.of(context).pivImport, color: contentTheme.onPrimary),
                  ),
                  if (slot != null) ...[
                    Spacing.width(12),
                    CustomizedButton.rounded(
                      onPressed: () => _showExportDialog(slot),
                      elevation: 0,
                      padding: Spacing.xy(20, 16),
                      backgroundColor: contentTheme.primary,
                      child: CustomizedText.labelMedium(S.of(context).pivExport, color: contentTheme.onPrimary),
                    ),
                    Spacing.width(12),
                    CustomizedButton.rounded(
                      onPressed: () {},
                      elevation: 0,
                      padding: Spacing.xy(20, 16),
                      backgroundColor: contentTheme.danger,
                      child: CustomizedText.labelMedium(S.of(context).pivDelete, color: contentTheme.onDanger),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  _showExportDialog(SlotInfo slot) {
    Get.dialog(Dialog(
        child: SizedBox(
            width: 300,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: Spacing.all(16), child: CustomizedText.labelLarge(S.of(context).pivExportCertificate)),
              Divider(height: 0, thickness: 1),
              Padding(
                  padding: Spacing.all(16),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    CustomizedButton.rounded(
                      onPressed: () async {
                        // Export DER
                        await FileSaver.instance.saveFile(name: 'certificate.der', bytes: slot.certBytes! as Uint8List);
                        Get.back();
                      },
                      elevation: 0,
                      padding: Spacing.xy(20, 16),
                      backgroundColor: contentTheme.primary,
                      child: CustomizedText.labelMedium('DER', color: contentTheme.onPrimary),
                    ),
                    Spacing.width(12),
                    CustomizedButton.rounded(
                      onPressed: () async {
                        String pem = PemCodec(PemLabel.certificate).encode(slot.certBytes!);
                        await FileSaver.instance.saveFile(name: 'certificate.pem', bytes: utf8.encode(pem));
                        Get.back();
                      },
                      elevation: 0,
                      padding: Spacing.xy(20, 16),
                      backgroundColor: contentTheme.primary,
                      child: CustomizedText.labelMedium('PEM', color: contentTheme.onPrimary),
                    )
                  ]))
            ]))));
  }

  _showImportDialog() {
    Rx<int> step = 0.obs;
    Rx<bool> hasCert = false.obs;
    Rx<bool> hasKey = false.obs;
    Rx<bool> selected = false.obs;
    String? pinPolicy;

    void nextStep() {
      if (step < 2) {
        setState(() => step.value++);
      } else {
        // TODO: Generate certificate
        Get.back();
      }
    }

    Get.dialog(Dialog(
      child: Obx(
        () => SizedBox(
          width: 400,
          child: Stepper(
            currentStep: step.value,
            onStepContinue: nextStep,
            onStepCancel: () => Get.back(),
            controlsBuilder: (BuildContext context, ControlsDetails details) {
              return Row(
                children: <Widget>[
                  if (details.stepIndex > 0) ...{
                    CustomizedButton.rounded(
                      onPressed: details.onStepContinue,
                      elevation: 0,
                      backgroundColor: ContentThemeColor.primary.color,
                      child: CustomizedText.labelMedium('Next', color: ContentThemeColor.primary.onColor),
                    ),
                    Spacing.width(12),
                  },
                  CustomizedButton.rounded(
                    onPressed: details.onStepCancel,
                    elevation: 0,
                    backgroundColor: ContentThemeColor.secondary.color,
                    child: CustomizedText.labelMedium('Cancel', color: ContentThemeColor.secondary.onColor),
                  ),
                ],
              );
            },
            steps: [
              Step(
                title: Text('Select Your Certificate'),
                content: InkWell(
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles();
                    final file = result?.files.firstOrNull;
                    if (file != null) {
                      selected.value = true;
                      final pem = utf8.decode(file.bytes!);
                      pem.split('-----BEGIN ').forEach((element) {
                        if (element.isNotEmpty) {
                          final item = '-----BEGIN $element';
                          if (item.startsWith(CryptoUtils.BEGIN_EC_PRIVATE_KEY)) {
                            final ecPrivateKey = CryptoUtils.ecPrivateKeyFromPem(item);
                            hasKey.value = true;
                          } else if (item.startsWith(CryptoUtils.BEGIN_RSA_PRIVATE_KEY)) {
                            final rsaPrivateKey = CryptoUtils.rsaPrivateKeyFromPem(item);
                            hasKey.value = true;
                          } else if (item.startsWith(X509Utils.BEGIN_CERT)) {
                            final cert = X509Utils.x509CertificateFromPem(item);
                            hasCert.value = true;
                          }
                        }
                      });
                      if (hasKey.value && hasCert.value) {
                        nextStep();
                      }
                    }
                  },
                  child: CustomizedContainer.bordered(
                    child: Center(
                      heightFactor: 1.2,
                      child: Padding(
                        padding: Spacing.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.uploadCloud, size: 24),
                            CustomizedContainer(
                              width: 340,
                              alignment: Alignment.center,
                              paddingAll: 0,
                              child: CustomizedText.titleMedium(
                                "Click to select a certificate",
                                fontWeight: 600,
                                muted: true,
                                fontSize: 18,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (selected.value && !hasCert.value && !hasKey.value)
                              CustomizedContainer(
                                alignment: Alignment.center,
                                child: CustomizedText.titleMedium(
                                  "(Make sure the file contains a plaintext key and a certificate)",
                                  muted: true,
                                  fontWeight: 500,
                                  fontSize: 12,
                                  textAlign: TextAlign.center,
                                  color: contentTheme.danger,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Step(
                title: Text('PIN and Touch Policy'),
                content: Column(
                  children: [
                    DropdownButtonFormField(
                      value: pinPolicy,
                      items: ['Default', 'Never', 'Once', 'Always'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (value) => setState(() => pinPolicy = value),
                      decoration: InputDecoration(labelText: 'PIN Policy'),
                      dropdownColor: contentTheme.background,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }

  String _pinPolicy(PinPolicy policy) {
    switch (policy) {
      case PinPolicy.never:
        return S.of(context).pivPinPolicyNever;
      case PinPolicy.once:
        return S.of(context).pivPinPolicyOnce;
      case PinPolicy.always:
        return S.of(context).pivPinPolicyAlways;
      default:
        return S.of(context).pivPinPolicyDefault;
    }
  }

  String _touchPolicy(TouchPolicy policy) {
    switch (policy) {
      case TouchPolicy.never:
        return S.of(context).pivTouchPolicyNever;
      case TouchPolicy.always:
        return S.of(context).pivTouchPolicyAlways;
      case TouchPolicy.cached:
        return S.of(context).pivTouchPolicyCached;
      default:
        return S.of(context).pivTouchPolicyDefault;
    }
  }

  String _origin(Origin origin) {
    if (origin == Origin.generated) {
      return S.of(context).pivOriginGenerated;
    }
    return S.of(context).pivOriginImported;
  }

  String? _displayDN(Map<String, String?>? data) {
    if (data == null) {
      return null;
    }
    final dnMap = Map.fromEntries(X509Utils.DN.entries.map((e) => MapEntry(e.value, e.key)));
    return data.keys.map((e) => '${dnMap[e]}=${data[e]}').join(', ');
  }
}
