import 'package:flutter/material.dart';

class BottomCu extends StatelessWidget {
  const BottomCu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.directional(
      bottom: 0,
      start: 0,
      end: 0,
      textDirection: TextDirection.ltr,
      child: BottomAppBar(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 50, minHeight: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () => print('hello'),
                  child: Text(
                    'Copyrigth @Deveo.nc',
                    style: TextStyle(color: Colors.grey),
                  )),
              TextButton(
                  onPressed: () => print('hello'),
                  child: Text(
                    'Conditions d\'utilisation',
                    style: TextStyle(color: Colors.grey),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
