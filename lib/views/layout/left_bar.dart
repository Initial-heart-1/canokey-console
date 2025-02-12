import 'package:canokey_console/generated/l10n.dart';
import 'package:canokey_console/helper/theme/theme_customizer.dart';
import 'package:canokey_console/helper/utils/shadow.dart';
import 'package:canokey_console/helper/utils/ui_mixins.dart';
import 'package:canokey_console/helper/widgets/customized_card.dart';
import 'package:canokey_console/helper/widgets/customized_container.dart';
import 'package:canokey_console/helper/widgets/spacing.dart';
import 'package:canokey_console/helper/widgets/customized_text.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:platform_detector/platform_detector.dart';

typedef LeftbarMenuFunction = void Function(String key);

class LeftbarObserver {
  static Map<String, LeftbarMenuFunction> observers = {};

  static attachListener(String key, LeftbarMenuFunction fn) {
    observers[key] = fn;
  }

  static detachListener(String key) {
    observers.remove(key);
  }

  static notifyAll(String key) {
    for (var fn in observers.values) {
      fn(key);
    }
  }
}

class LeftBar extends StatefulWidget {
  final bool isCondensed;

  const LeftBar({super.key, this.isCondensed = false});

  @override
  _LeftBarState createState() => _LeftBarState();
}

class _LeftBarState extends State<LeftBar> with SingleTickerProviderStateMixin, UIMixin {
  final ThemeCustomizer customizer = ThemeCustomizer.instance;

  bool isCondensed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isCondensed = widget.isCondensed;
    return CustomizedCard(
      paddingAll: 0,
      shadow: Shadow(position: ShadowPosition.centerRight, elevation: 0.2),
      child: AnimatedContainer(
        color: leftBarTheme.background,
        width: isCondensed ? 70 : 260,
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMobile()) Spacing.height(60),
            SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(child: Image.asset('assets/images/logo/logo_icon_dark.png', height: widget.isCondensed ? 24 : 32)),
                  if (!widget.isCondensed)
                    Flexible(
                      fit: FlexFit.loose,
                      child: Spacing.width(16),
                    ),
                  if (!widget.isCondensed)
                    Flexible(
                      fit: FlexFit.loose,
                      child: CustomizedText.labelLarge(
                        "CanoKey",
                        style: GoogleFonts.raleway(fontSize: 24, fontWeight: FontWeight.w800, color: contentTheme.primary, letterSpacing: 1),
                        maxLines: 1,
                      ),
                    )
                ],
              ),
            ),
            Expanded(
                child: SingleChildScrollView(
              physics: PageScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  labelWidget(S.of(context).applets),
                  NavigationItem(
                    iconData: LucideIcons.key,
                    title: 'WebAuthn',
                    isCondensed: isCondensed,
                    route: '/applets/webauthn',
                  ),
                  NavigationItem(
                    iconData: LucideIcons.timer,
                    title: 'TOTP / HOTP',
                    isCondensed: isCondensed,
                    route: '/applets/oath',
                  ),
                  NavigationItem(
                    iconData: LucideIcons.keyboard,
                    title: 'Pass',
                    isCondensed: isCondensed,
                    route: '/applets/pass',
                  ),
                  // NavigationItem(
                  //   iconData: LucideIcons.creditCard,
                  //   title: 'PIV',
                  //   isCondensed: isCondensed,
                  //   route: '/applets/piv',
                  // ),
                  // NavigationItem(
                  //   iconData: LucideIcons.lock,
                  //   title: "OpenPGP",
                  //   isCondensed: isCondensed,
                  //   route: '/applets/openpgp',
                  // ),
                  labelWidget(S.of(context).other),
                  NavigationItem(
                    iconData: LucideIcons.settings,
                    title: S.of(context).settings,
                    isCondensed: isCondensed,
                    route: '/settings',
                  ),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

  Widget labelWidget(String label) {
    return isCondensed
        ? Spacing.empty()
        : Container(
            padding: Spacing.xy(24, 8),
            child: CustomizedText.labelSmall(
              label.toUpperCase(),
              color: leftBarTheme.labelColor,
              muted: true,
              maxLines: 1,
              overflow: TextOverflow.clip,
              fontWeight: 700,
            ),
          );
  }
}

class NavigationItem extends StatefulWidget {
  final IconData? iconData;
  final String title;
  final bool isCondensed;
  final String? route;

  const NavigationItem({super.key, this.iconData, required this.title, this.isCondensed = false, this.route});

  @override
  _NavigationItemState createState() => _NavigationItemState();
}

class _NavigationItemState extends State<NavigationItem> with UIMixin {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    bool isActive = Get.currentRoute == widget.route;
    return GestureDetector(
      onTap: () {
        if (widget.route != null) {
          Get.offNamed(widget.route!);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: (event) {
          setState(() => isHover = true);
        },
        onExit: (event) {
          setState(() => isHover = false);
        },
        child: CustomizedContainer.transparent(
          margin: Spacing.fromLTRB(16, 0, 16, 8),
          color: isActive || isHover ? leftBarTheme.activeItemBackground : Colors.transparent,
          padding: Spacing.xy(8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.iconData != null)
                Center(
                  child: Icon(widget.iconData, color: (isHover || isActive) ? leftBarTheme.activeItemColor : leftBarTheme.onBackground, size: 20),
                ),
              if (!widget.isCondensed) Flexible(fit: FlexFit.loose, child: Spacing.width(16)),
              if (!widget.isCondensed)
                Expanded(
                  flex: 3,
                  child: CustomizedText.labelLarge(widget.title,
                      overflow: TextOverflow.clip, maxLines: 1, color: isActive || isHover ? leftBarTheme.activeItemColor : leftBarTheme.onBackground),
                )
            ],
          ),
        ),
      ),
    );
  }
}
