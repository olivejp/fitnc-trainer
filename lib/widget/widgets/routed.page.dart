import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

// TODO Class expérimentale.

class CustomRoute {
  String route;
  dynamic params;

  CustomRoute(this.route, {this.params});
}

class RouteDefiner {
  String route;
  Widget Function(dynamic param) builder;

  RouteDefiner(this.route, this.builder);
}

class RoutedPage extends StatefulWidget {
  final List<RouteDefiner> routeList;
  final String initialRoute;
  final Widget? noRouteFound;

  Widget getRouteWidget(CustomRoute route) {
    for (var i = 0; i < routeList.length; i++) {
      if (routeList[i].route == route.route) {
        return routeList[i].builder(route.params);
      }
    }
    throw Exception("Aucune route définie pour ${route.route}");
  }

  RoutedPage({required this.routeList, required this.initialRoute, this.noRouteFound});

  @override
  State<StatefulWidget> createState() {
    return new RoutedPageState();
  }
}

class RoutedPageState extends State<RoutedPage> {
  late BehaviorSubject<CustomRoute> _routeSubject = BehaviorSubject();

  @override
  Widget build(BuildContext context) {
    _routeSubject.sink.add(CustomRoute(widget.initialRoute));
    return StreamBuilder<CustomRoute>(
      stream: _routeSubject,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return widget.getRouteWidget(snapshot.data!);
        } else {
          return (widget.noRouteFound != null) ? widget.noRouteFound! : Container();
        }
      },
    );
  }

  void pushRoute(CustomRoute route) {
    _routeSubject.sink.add(route);
  }

  @override
  void dispose() {
    super.dispose();
    _routeSubject.close();
  }
}

class Router {
  static RoutedPageState of(BuildContext context) {
    RoutedPageState? state;
    if (context is StatefulElement && context.state is NavigatorState) {
      state = context.state as RoutedPageState;
    }
    state = state ?? context.findAncestorStateOfType<RoutedPageState>();
    assert(() {
      if (state == null) {
        throw FlutterError('Aucun state RoutedPageState trouvé.');
      }
      return true;
    }());
    return state!;
  }

  static pushRoute(BuildContext context, String route, dynamic params) {
    Router.of(context).pushRoute(CustomRoute(route, params: params));
  }
}
