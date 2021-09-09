import 'package:file_picker/file_picker.dart';
import 'package:fitness_domain/domain/storage-file.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:rxdart/rxdart.dart';

///
/// Classe permettant d'afficher une image.
/// On peut lui passer une ImageUrl (String?) ou un StorageFile?
/// Par défaut c'est l'ImageUrl qui prime et c'est celle là qu'on affichera.
/// Si l'ImageUrl est null, on affichera le StorageFile.
class StorageImageWidget extends StatelessWidget {
  const StorageImageWidget(
      {required this.imageUrl, this.storageFile, this.allowedExtensions = defaultAllowedExtensions, required this.onSaved, this.onDeleted});

  static const List<String> defaultAllowedExtensions = <String>['jpg', 'jpeg', 'png', 'gif'];

  final FormFieldSetter<StorageFile> onSaved;
  final void Function()? onDeleted;
  final List<String> allowedExtensions;
  final String? imageUrl;
  final StorageFile? storageFile;

  @override
  Widget build(BuildContext context) {
    const Widget icon = Icon(
      Icons.add_photo_alternate,
      color: Colors.white,
    );

    const double radius = 50;

    final Color color = Theme.of(context).primaryColor;

    Widget? child;
    if (imageUrl != null) {
      child = CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor: color,
        child: icon,
      );
    } else if (storageFile != null && storageFile!.fileBytes != null) {
      child = CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(storageFile!.fileBytes!),
        backgroundColor: color,
        child: icon,
      );
    } else {
      child = CircleAvatar(
        radius: radius,
        backgroundColor: color,
        child: icon,
      );
    }

    return Row(
      children: <Widget>[
        InkWell(
          onTap: () => onTap(),
          borderRadius: const BorderRadius.all(Radius.circular(50)),
          child: child,
        ),
        IconButton(
            tooltip: 'Supprimer la photo',
            onPressed: () {
              if (onDeleted != null) {
                onDeleted!();
              }
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.amber,
            )),
      ],
    );
  }

  void onTap() {
    FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: allowedExtensions).then((FilePickerResult? result) {
      if (result != null) {
        final StorageFile storageFileResult = StorageFile();
        storageFileResult.fileBytes = result.files.first.bytes;
        storageFileResult.fileName = result.files.first.name;
        onSaved(storageFileResult);
      }
    });
  }
}

class StorageFutureImageWidget extends StatelessWidget {
  StorageFutureImageWidget(
      {required this.onSaved,
      required this.future,
      this.validator,
      this.allowedExtensions = defaultAuthorizedExtensions,
      this.onDeleted,
      this.radius = 50});

  static const List<String> defaultAuthorizedExtensions = <String>['jpg', 'jpeg', 'png', 'gif'];

  final ValueNotifier<StorageFile?> _vnSelectedImage = ValueNotifier<StorageFile?>(null);
  final StorageFile _storagePair = StorageFile();
  final FormFieldSetter<StorageFile> onSaved;
  final FormFieldValidator<StorageFile>? validator;
  final List<String> allowedExtensions;
  final Future<StorageFile?> future;
  final void Function(StorageFile? storagePair)? onDeleted;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StorageFile?>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<StorageFile?> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            _storagePair.fileName = snapshot.data!.fileName;
            _storagePair.fileBytes = snapshot.data!.fileBytes;
          }
          _vnSelectedImage.value = _storagePair;
          return StorageImageFormField<StorageFile>(
            builder: builderWidget,
          );
        } else {
          return SizedBox(
            height: radius * 2,
            child: LoadingRotating.square(
              backgroundColor: Theme.of(context).primaryColor,
            ),
          );
        }
      },
    );
  }

  Widget builderWidget(FormFieldState<StorageFile> field) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          child: ValueListenableBuilder<StorageFile?>(
              valueListenable: _vnSelectedImage,
              builder: (BuildContext context, StorageFile? storage, __) {
                ImageProvider? provider;
                if (storage != null && storage.fileBytes != null) {
                  provider = MemoryImage(storage.fileBytes!);
                }
                return CircleAvatar(
                    radius: radius,
                    foregroundImage: provider,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(
                      Icons.add_photo_alternate,
                      color: Colors.white,
                    ));
              }),
        ),
        IconButton(
            tooltip: 'Supprimer la photo',
            onPressed: () {
              if (onDeleted != null) {
                onDeleted!(null);
              }
              _storagePair.fileName = null;
              _storagePair.fileBytes = null;
              _vnSelectedImage.value = _storagePair;
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.amber,
            )),
      ],
    );
  }

  void onTap() {
    FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: this.allowedExtensions).then((result) {
      if (result != null) {
        _storagePair.fileBytes = result.files.first.bytes;
        _storagePair.fileName = result.files.first.name;
        onSaved(_storagePair);
        _vnSelectedImage.value = _storagePair;
      }
    });
  }
}

class StorageStreamImageWidget extends StatelessWidget {
  StorageStreamImageWidget(
      {required this.onSaved,
      required this.streamInitialStorageFile,
      this.validator,
      this.allowedExtensions = defaultAllowedExtensions,
      this.onDeleted,
      this.radius = 50,
      this.icon = defaultIcon});

  static const Icon defaultIcon = Icon(
    Icons.add_photo_alternate,
    color: Colors.white,
  );
  static const List<String> defaultAllowedExtensions = ['jpg', 'jpeg', 'png', 'gif'];

  final BehaviorSubject<StorageFile?> _streamSelectedImage = BehaviorSubject<StorageFile?>();
  final StorageFile _storagePair = StorageFile();
  final FormFieldSetter<StorageFile> onSaved;
  final FormFieldValidator<StorageFile>? validator;
  final List<String> allowedExtensions;
  final Stream<StorageFile?> streamInitialStorageFile;
  final Icon icon;
  final double radius;
  final void Function(StorageFile? storagePair)? onDeleted;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StorageFile?>(
      stream: streamInitialStorageFile,
      builder: (BuildContext context, AsyncSnapshot<StorageFile?> snapshot) {
        if (snapshot.hasData) {
          _storagePair.fileName = snapshot.data!.fileName;
          _storagePair.fileBytes = snapshot.data!.fileBytes;
          _streamSelectedImage.sink.add(_storagePair);
          return StorageImageFormField<StorageFile>(
            builder: builderWidget,
          );
        } else {
          return InkWell(
            onTap: () => onTap(),
            borderRadius: const BorderRadius.all(Radius.circular(50)),
            child: CircleAvatar(radius: radius, backgroundColor: Theme.of(context).primaryColor, child: icon),
          );
        }
      },
    );
  }

  Widget builderWidget(FormFieldState<StorageFile> field) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () => onTap(),
          borderRadius: const BorderRadius.all(Radius.circular(50)),
          child: StreamBuilder<StorageFile?>(
              stream: _streamSelectedImage.stream,
              builder: (BuildContext context, AsyncSnapshot<StorageFile?> snapshot) {
                ImageProvider? provider;
                if (snapshot.hasData && snapshot.data != null && snapshot.data!.fileBytes != null) {
                  provider = MemoryImage(snapshot.data!.fileBytes!);
                }
                return CircleAvatar(radius: radius, foregroundImage: provider, backgroundColor: Theme.of(context).primaryColor, child: icon);
              }),
        ),
        IconButton(
            tooltip: 'Supprimer la photo',
            onPressed: () {
              if (onDeleted != null) {
                onDeleted!(_storagePair);
              }
              _storagePair.fileName = null;
              _storagePair.fileBytes = null;
              _streamSelectedImage.sink.add(_storagePair);
            },
            icon: Icon(
              Icons.delete,
              color: Colors.amber,
            )),
      ],
    );
  }

  void onTap() {
    FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: allowedExtensions).then((result) {
      if (result != null) {
        _storagePair.fileBytes = result.files.first.bytes;
        _storagePair.fileName = result.files.first.name;
        onSaved(_storagePair);
        _streamSelectedImage.sink.add(_storagePair);
      }
    });
  }

  void dispose() {
    _streamSelectedImage.close();
  }
}

class StorageImageFormField<T> extends FormField<T> {
  const StorageImageFormField({required this.builder, this.onSaved, this.validator})
      : super(builder: builder, onSaved: onSaved, validator: validator);

  final FormFieldBuilder<T> builder;
  final FormFieldSetter<T>? onSaved;
  final FormFieldValidator<T>? validator;
}
