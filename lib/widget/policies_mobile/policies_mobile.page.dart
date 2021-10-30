import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PoliciesMobilePage extends StatefulWidget {
  const PoliciesMobilePage({Key? key}) : super(key: key);

  @override
  _PoliciesMobilePageState createState() {
    return _PoliciesMobilePageState();
  }
}

class _PoliciesMobilePageState extends State<PoliciesMobilePage> {
  _PoliciesMobilePageState();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100, bottom: 100, left: 200, right: 200),
              child: Column(
                children: <Widget>[
                  Text(
                    'Application Mobile : Règles de confidentialité',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Text(
                    'Règles de confidentialité',
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  Text(
                    'Fitness Nc est éditée par DEVEO, Société à responsabilité limitée '
                    'au capital de 100 000 xpf domiciliée au 257-259 rue Arnold-Daly,'
                    ' Ouémo, 98800 NOUMEA - 1 411 016 RCS Nouméa. Le terme Application'
                    ' s\'applique à l\'application pour mobile ou tablette Android '
                    'et IOS nommée \'Fitness Nc\'. Le terme Serveur Firebase '
                    's\'applique aux composants logiciels et physiques utilisés par l\'application '
                    'pour stocker les données des utilisateurs.',
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  Text(
                    'Données personnelles',
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  Text(
                    'Depuis notre application, nous collectons les informations suivantes'
                    ' : nom, prénom, sexe, téléphone et adresse mail. '
                    'Ces informations sont retenues lors de l\'usage de l\'application '
                    'par l\'utilisateur et sont stockées sur le Serveur '
                    'Firebase mis à disposition par Google. Les dites informations sont '
                    'nécessaires pour l\'usage de l\'application, cependant nous ne les communiquons '
                    'pas à des tiers. En tant qu\'utilisateur vous restez maître de voss données et pouvez donc '
                    'demander leur suppression ou leur modification à n\'importe quel moment.',
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  Text(
                    'Récupération, modification ou suppression des données personnelles',
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  Text(
                    'Si vous souhaitez récupérer, modifier ou supprimer merci d\'envoyer un mail précisant votre nom et prénom à l\'adresse orlanth23@gmail.com.',
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
