import 'package:fitnc_trainer/bloc/my-home-page.bloc.dart';
import 'package:fitnc_trainer/widget/abonne.page.dart';
import 'package:fitnc_trainer/widget/workout.page.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  static final int PAGE_WORKOUT = 0;
  static final int PAGE_ABONNE = 1;
  final MyHomePageBloc bloc = MyHomePageBloc.getInstance();
  final String title;

  MyHomePage(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: StreamBuilder(
        stream: bloc.currentPageObs,
        builder: (context, snapshot) {
          if (snapshot.data == PAGE_WORKOUT) {
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/add_workout');
              },
              label: Text('Ajouter un workout'),
              icon: Icon(
                Icons.sports,
                size: 20.0,
              ),
            );
          }
          if (snapshot.data == PAGE_ABONNE) {
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/add_abonne');
              },
              label: Text('Ajouter un abonné'),
              icon: Icon(
                Icons.sports,
                size: 20.0,
              ),
            );
          }
          return Container();
        },
      ),
      appBar: AppBar(
        title: Text(this.title),
        actions: [
          IconButton(onPressed: () => bloc.logout(), icon: Icon(Icons.person))
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Row(
            children: [
              Flexible(
                flex: 1,
                child: getLeftDrawer(),
              ),
              Flexible(
                flex: 5,
                child: getMainPage(),
              ),
            ],
          );
        } else {
          return getMainPage();
        }
      }),
    );
  }

  StreamBuilder<int> getMainPage() {
    return StreamBuilder<int>(
      builder: (context, snapshot) {
        if (snapshot.data == PAGE_WORKOUT) {
          return WorkoutPage();
        }
        if (snapshot.data == PAGE_ABONNE) {
          return AbonnePage();
        }
        return Text('Aie');
      },
      stream: bloc.currentPageObs,
    );
  }

  Container getLeftDrawer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.shade900,
            blurRadius: 5.0,
            spreadRadius: 0.0,
            offset: Offset(0.5, 0.5), // shadow direction: bottom right
          )
        ],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => bloc.changePage(PAGE_WORKOUT),
            subtitle: Text('Gérer vos entraînements'),
            title: Text('Workout'),
            trailing: Icon(Icons.sports),
          ),
          Divider(),
          ListTile(
            onTap: () => bloc.changePage(PAGE_ABONNE),
            subtitle: Text('Gérer vos abonnés'),
            title: Text('Abonnés'),
            trailing: Icon(Icons.group),
          ),
        ],
      ),
    );
  }
}
