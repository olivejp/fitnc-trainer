import 'dart:ui';

import 'package:fitnc_trainer/controller/home.page.controller.dart';
import 'package:fitnc_trainer/main.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:fitness_domain/service/display.service.dart';
import 'package:fitnc_trainer/widget/exercice/exercice.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../constants/constants.dart';
import 'abonne/abonne.page.dart';
import 'programme/programme.page.dart';
import 'workout/workout.page.dart';

class Destination {
  Destination({required this.page, required this.icon, required this.pageName, required this.index});

  final Icon icon;
  final String pageName;
  final int index;
  final Widget page;
}

class MyHomePage extends StatelessWidget {
  final HomePageController controller = Get.put(HomePageController());

  @override
  Widget build(BuildContext context) {
    final List<Destination> destinations = <Destination>[
      Destination(icon: const Icon(Icons.account_tree_outlined), pageName: 'Programme', index: 0, page: ProgrammePage()),
      Destination(icon: const Icon(Icons.sports_volleyball_outlined), pageName: 'Workout', index: 1, page: const WorkoutPage()),
      Destination(icon: const Icon(Icons.sports_handball_outlined), pageName: 'Exercice', index: 2, page: ExercicePage()),
      Destination(icon: const Icon(Icons.group), pageName: 'Abonné', index: 3, page: AbonnePage()),
    ];

    return Scaffold(
      body: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FitnessDrawer(
            destinations: destinations,
            appName: FitnessConstants.appTitle,
          ),
          Expanded(
            child: Obx(
              () {
                final Iterable<Destination> destinationsFiltered =
                    destinations.where((Destination dest) => dest.index == controller.currentPage.value);
                if (destinationsFiltered.isNotEmpty) {
                  return destinationsFiltered.first.page;
                } else {
                  throw Exception('Index ne correspond à aucune page.');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FitnessDrawer extends StatefulWidget {
  const FitnessDrawer({required this.destinations, required this.appName});

  final String appName;
  final List<Destination> destinations;

  @override
  State<FitnessDrawer> createState() => _FitnessDrawerState();
}

class _FitnessDrawerState extends State<FitnessDrawer> with SingleTickerProviderStateMixin {
  late AnimationController _iconAnimation;
  late Animation<double> _animation;
  final AuthService authService = Get.find();
  final HomePageController controller = Get.find();
  final DisplayTypeService displayTypeController = Get.find();

  @override
  void dispose() {
    _iconAnimation.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    displayTypeController.displayType.listen((DisplayType displayType) {
      controller.changeExpanded(displayType == DisplayType.desktop);
    });
    _iconAnimation = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_iconAnimation);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isExpanded.value) {
        _iconAnimation.reverse();
      } else {
        _iconAnimation.forward();
      }

      return NavigationRail(
          elevation: 5,
          extended: controller.isExpanded.value,
          selectedIndex: controller.currentPage.value,
          trailing: _NavigationRailFolderSection(folders: <_NavigationFolder>[
            _NavigationFolder(
              label: 'Profil',
              iconData: Icons.person,
              onTap: () => authService.signOut(),
            ),
            _NavigationFolder(
              label: 'Déconnexion',
              iconData: Icons.exit_to_app_outlined,
              onTap: () => authService.signOut(),
            ),
          ]),
          leading: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: TextButton.icon(
                  onPressed: () => controller.changeExpanded(!controller.isExpanded.value),
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.home_menu,
                    color: Theme.of(context).primaryColor,
                    progress: _iconAnimation,
                  ),
                  label: AnimatedBuilder(
                    animation: _iconAnimation,
                    builder: (BuildContext context, Widget? child) {
                      return Align(
                        alignment: AlignmentDirectional.centerStart,
                        widthFactor: _animation.value,
                        child: Opacity(
                          opacity: _animation.value,
                          child: Text(
                            widget.appName,
                            style: Theme.of(context).textTheme.headline2,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
          onDestinationSelected: (int value) => controller.changePage(value),
          destinations: widget.destinations.map((Destination e) {
            return NavigationRailDestination(
              label: Text(e.pageName),
              icon: Material(
                key: ValueKey<String>('fit-${e.pageName}'),
                color: Colors.transparent,
                child: e.icon,
              ),
            );
          }).toList());
    });
  }
}

class _NavigationFolder {
  _NavigationFolder({required this.label, required this.iconData, required this.onTap});

  final IconData iconData;
  final String label;
  final void Function() onTap;
}

class _NavigationRailFolderSection extends StatelessWidget {
  const _NavigationRailFolderSection({required this.folders});

  final List<_NavigationFolder> folders;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NavigationRailThemeData navigationRailTheme = theme.navigationRailTheme;
    final Animation<double> animation = NavigationRail.extendedAnimation(context);

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Visibility(
          maintainAnimation: true,
          maintainState: true,
          visible: animation.value > 0,
          child: Opacity(
            opacity: animation.value,
            child: Align(
              widthFactor: animation.value,
              alignment: AlignmentDirectional.centerStart,
              child: SizedBox(
                height: 485,
                width: 256,
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    const Divider(
                      color: FitnessNcColors.blue200,
                      thickness: 0.4,
                      indent: 14,
                      endIndent: 16,
                    ),
                    const SizedBox(height: 16),
                    for (_NavigationFolder folder in folders)
                      InkWell(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(36),
                        ),
                        onTap: folder.onTap,
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                const SizedBox(width: 12),
                                Icon(
                                  folder.iconData,
                                  color: navigationRailTheme.unselectedLabelTextStyle!.color,
                                ),
                                const SizedBox(width: 24),
                                Text(
                                  folder.label,
                                  style: navigationRailTheme.unselectedLabelTextStyle,
                                ),
                                const SizedBox(height: 72),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
