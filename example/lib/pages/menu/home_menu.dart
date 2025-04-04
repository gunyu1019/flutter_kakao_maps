import 'package:flutter/material.dart';
import 'package:kakao_map_sdk_example/components/title_component.dart';
import 'package:kakao_map_sdk_example/enums/routes.dart';
import 'package:kakao_map_sdk_example/models/menu_info.dart';
import 'package:kakao_map_sdk_example/pages/routers.dart';

class HomeMenu extends StatefulWidget {
  const HomeMenu({super.key});

  @override
  State<HomeMenu> createState() => _HomeMenuState();

  static const MenuInfo menuInfo = MenuInfo("/", "홈", "");
}

class _HomeMenuState extends State<HomeMenu> with TitleComponent {
  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    children.addAll(Routes.values.map((element) {
      if (!element.menuInfo.visible || element.menuInfo.icon == null) {
        return const SizedBox.shrink();
      }
      return cardButtom(element.menuInfo.iconWidget!, element.menuInfo.title,
          element.menuInfo.description, () {
            router.push(element.menuInfo.id);
          });
    }));
    return Column(
      spacing: 1,
      children: [
        title(),
        Expanded(child: SingleChildScrollView(
          child: Column(children: children),
        ))
      ],
    );
  }

  Widget title() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: titleText()),
            Row(spacing: 8, children: [
              flutterCard(),
              platformCard(),
            ])
          ],
        ));
  }

  Widget cardButtom(Widget icon, String title, String description,
          [void Function()? onPressed]) =>
      Card(
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
                padding: const EdgeInsets.all(2),
                child: ListTile(
                    leading: icon,
                    title: Text(
                      title,
                      style: cardTitleTextStyle,
                    ),
                    subtitle: Text(
                      description,
                      style: cardDescriptionTextStyle,
                    ))),
          ));
  
  final cardTitleTextStyle = const TextStyle(
      fontSize: 16, color: Colors.black, decoration: TextDecoration.none);
  final cardDescriptionTextStyle = const TextStyle(
      fontSize: 12, color: Colors.black, decoration: TextDecoration.none);
}
