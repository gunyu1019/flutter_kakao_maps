import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kakao_map_sdk_example/components/title_component.dart';
import 'package:kakao_map_sdk_example/models/menu_info.dart';

class HomeMenu extends StatefulWidget {
  HomeMenu({super.key});

  @override
  State<HomeMenu> createState() => _HomeMenuState();
  
  final MenuInfo menuInfo = MenuInfo("/", "홈", "");
}

class _HomeMenuState extends State<HomeMenu> with TitleComponent {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        title(),
        cardButtom(FaIcon(FontAwesomeIcons.camera), "카메라 이동", "카메라 이동 관련 기능")
      ],
    );
  }

  Widget cardButtom(Widget icon, String title, String description, [void Function()? onPressed]) =>
      Card(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onPressed,
          child: ListTile(
            leading: icon,
            title: Text(title, style: cardTitleTextStyle,),
            subtitle: Text(description, style: cardDescriptionTextStyle,)
          ),
        )
      );
}
