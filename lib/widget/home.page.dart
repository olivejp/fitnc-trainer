import 'package:fitnc_trainer/controller/auth.controller.dart';
import 'package:fitnc_trainer/controller/home.page.controller.dart';
import 'package:fitnc_trainer/widget/exercice/exercice.page.dart';
import 'package:fitnc_trainer/widget/profil/profil.page.dart';
import 'package:fitnc_trainer/widget/program/program.page.dart';
import 'package:fitness_domain/constants.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:fitness_domain/service/display.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'abonne/abonne.page.dart';
import 'workout/workout.page.dart';

class Destination {
  Destination({required this.page, this.icon, required this.pageName, required this.index, this.child})
      : assert((icon != null && child == null) || (icon == null && child != null), 'icon or child, but not both.');

  final Icon? icon;
  final Widget? child;
  final String pageName;
  final int index;
  final Widget page;
}

class HomePage extends StatelessWidget {
  final HomePageController controller = Get.put(HomePageController());
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    final List<Destination> destinations = <Destination>[
      Destination(
        icon: const Icon(Icons.account_tree_outlined),
        pageName: 'program'.tr,
        index: 0,
        page: ProgramPage(),
      ),
      Destination(
        icon: const Icon(Icons.sports_volleyball_outlined),
        pageName: 'workout'.tr,
        index: 1,
        page: WorkoutPage(),
      ),
      Destination(
        icon: const Icon(Icons.sports_handball_outlined),
        pageName: 'exercise'.tr,
        index: 2,
        page: ExercisePage(),
      ),
      Destination(
        icon: const Icon(Icons.group),
        pageName: 'subscriber'.tr,
        index: 3,
        page: AbonnePage(),
      ),
      Destination(
          child: Obx(() {
            if (authController.trainer.value?.imageUrl != null) {
              return CircleAvatar(
                foregroundImage: NetworkImage(authController.trainer.value!.imageUrl!),
                radius: 15,
              );
            } else {
              return const Icon(Icons.person);
            }
          }),
          pageName: 'profile'.tr,
          index: 4,
          page: ProfilPage()),
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
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: _NavigationRailFolderSection(folders: <_NavigationFolder>[
                  _NavigationFolder(
                    label: 'signOut'.tr,
                    iconData: Icons.exit_to_app_outlined,
                    onTap: () => authService.signOut(),
                  ),
                ]),
              ),
            ],
          ),
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
          destinations: widget.destinations.map((Destination dest) {
            Widget child;
            if (dest.child != null) {
              child = dest.child!;
            } else {
              child = Material(
                key: ValueKey<String>('fit-${dest.pageName}'),
                color: Colors.transparent,
                child: dest.icon,
              );
            }
            return NavigationRailDestination(
              label: Text(dest.pageName),
              icon: child,
            );
          }).toList());
    });
  }
}

class _NavigationFolder {
  _NavigationFolder({required this.label, this.iconData, required this.onTap, this.child})
      : assert((iconData != null && child == null) || (iconData == null && child != null),
            'iconData or child, but not both.');

  final IconData? iconData;
  final Widget? child;
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
    final List<Widget> listWidget = <Widget>[
      const Divider(
        color: FitnessNcColors.blue200,
        thickness: 0.4,
        indent: 14,
        endIndent: 16,
      ),
      const SizedBox(height: 16),
    ];

    listWidget.addAll(folders.map((_NavigationFolder folder) {
      return InkWell(
        borderRadius: const BorderRadius.all(
          Radius.circular(36),
        ),
        onTap: folder.onTap,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                const SizedBox(width: 12),
                Builder(builder: (_) {
                  if (folder.iconData != null) {
                    return Icon(
                      folder.iconData,
                      color: navigationRailTheme.unselectedLabelTextStyle!.color,
                    );
                  }
                  if (folder.child != null) {
                    return folder.child!;
                  }
                  return Container();
                }),
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
      );
    }).toList());

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
                  children: listWidget,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
