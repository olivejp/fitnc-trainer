import 'dart:ui';

import 'package:fitnc_trainer/bloc/home.page.bloc.dart';
import 'package:fitnc_trainer/widget/exercice/exercice.page.dart';
import 'package:fitnc_trainer/widget/widgets/generic_container.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

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
  MyHomePage(this.title);

  final MyHomePageBloc bloc = MyHomePageBloc.instance();
  final String title;
  final List<Destination> destinations = <Destination>[
    Destination(icon: const Icon(Icons.account_tree_outlined), pageName: 'Programme', index: 0, page: ProgrammePage()),
    Destination(icon: const Icon(Icons.sports_volleyball_outlined), pageName: 'Workout', index: 1, page: WorkoutPage()),
    Destination(icon: const Icon(Icons.sports_handball_outlined), pageName: 'Exercice', index: 2, page: ExercicePage()),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      bloc.isExpanded = true;
      if (constraints.maxWidth <= 1024) {
        bloc.isExpanded = false;
      }
      return Scaffold(
        body: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Drawer(bloc: bloc, destinations: destinations),
            Expanded(
              child: GenericContainerWidget(
                opacity: 0.5,
                child: StreamBuilder<int>(
                    stream: bloc.currentPageObs,
                    builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.hasData) {
                        final Iterable<Destination> destinationsFiltered = destinations.where((Destination dest) => dest.index == snapshot.data!);
                        if (destinationsFiltered.isNotEmpty) {
                          return destinationsFiltered.first.page;
                        }
                      }
                      return Container();
                    }),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class Drawer extends StatefulWidget {
  const Drawer({required this.bloc, required this.destinations});

  final MyHomePageBloc bloc;
  final List<Destination> destinations;

  @override
  State<Drawer> createState() => _DrawerState();
}

class _DrawerState extends State<Drawer> with SingleTickerProviderStateMixin {
  late ValueNotifier<bool> _vnIsExtended;
  late ValueNotifier<int> _vnSelectedIndex;
  late AnimationController _iconAnimation;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _iconAnimation = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _vnIsExtended = ValueNotifier<bool>(widget.bloc.isExpanded);
    _vnSelectedIndex = ValueNotifier<int>(0);
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_iconAnimation);

    widget.bloc.currentIsExpanded.listen((bool event) {
      _vnIsExtended.value = event;
      if (event) {
        _iconAnimation.reverse();
      } else {
        _iconAnimation.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _vnSelectedIndex,
      builder: (BuildContext context, int value, Widget? child) {
        return ValueListenableBuilder<bool>(
          valueListenable: _vnIsExtended,
          builder: (BuildContext context, bool isExtended, Widget? child) {
            return NavigationRail(
                backgroundColor: const Color(0xff385c79),
                extended: isExtended,
                selectedIndex: _vnSelectedIndex.value,
                leading: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: TextButton.icon(
                        onPressed: () {
                          _vnIsExtended.value = !_vnIsExtended.value;
                          widget.bloc.isExpanded = _vnIsExtended.value;
                        },
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
                                  'Fitness Nc',
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
                onDestinationSelected: (int value) {
                  _vnSelectedIndex.value = value;
                  widget.bloc.changePage(value);
                },
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
          },
        );
      },
    );
  }
}
