import 'package:canokey_console/generated/l10n.dart';
import 'package:get/get.dart';
import 'package:platform_detector/platform_detector.dart';

class Hints {
  static String get pollCanoKeyPrompt {
    if (isAndroidApp()) {
      return S.of(Get.context!).androidPollCanoKeyPrompt;
    }
    if (isIOSApp()) {
      return S.of(Get.context!).iosPollCanoKeyPrompt;
    }
    if (isWeb()) {
      return S.of(Get.context!).webPollCanoKeyPrompt;
    }
    if (isDesktop()) {
      return S.of(Get.context!).desktopPollCanoKeyPrompt;
    }
    return "";
  }
}
