import 'package:fitnc_trainer/bloc/my-home-page.bloc.dart';
import 'package:fitnc_trainer/widget/workout.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  final MyHomePageBloc bloc = MyHomePageBloc.getInstance();
  final String title;

  MyHomePage(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: StreamBuilder(
        stream: bloc.currentPageObs,
        builder: (context, snapshot) {
          if (snapshot.data == 0) {
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
          if (snapshot.data == 1) {
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
      ),
      body: Row(
        children: [
          Flexible(
            flex: 1,
            child: Container(
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
                    onTap: () => bloc.changePage(0),
                    subtitle: Text('Gérer vos entraînements'),
                    title: Text('Workout'),
                    trailing: Icon(Icons.sports),
                  ),
                  ListTile(
                    onTap: () => bloc.changePage(1),
                    subtitle: Text('Gérer vos abonnés'),
                    title: Text('Abonnés'),
                    trailing: Icon(Icons.group),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 5,
            child: StreamBuilder<int>(
              builder: (context, snapshot) {
                if (snapshot.data == 0) {
                  return WorkoutPage();
                }
                return Text('Aie');
              },
              stream: bloc.currentPageObs,
            ),
          ),
        ],
      ),
    );
  }
}
