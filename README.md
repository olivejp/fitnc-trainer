# fitnc_trainer

Application dedicated to trainers.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


You can specify in the command line :

## The web rendering
--web-renderer auto

## The port for the web browser 
--web-port 5555

## Special args to emulate some firebase functionality
Possibles attributes FIRESTORE, FUNCTIONS, STORAGE, AUTH
--dart-define="EMULATORS=FIRESTORE;FUNCTIONS"

## Special args to specify you are in dev mode
--dart-define="PROFILE=DEV"