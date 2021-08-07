import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase/service/firestorage.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:rxdart/rxdart.dart';

class StorageFile {
  Uint8List? fileBytes;
  String? fileName;
}

class StorageImageWidget extends StatelessWidget {
  static const List<String> DEFAULT_ALLOWED_EXTENSIONS = ['jpg', 'jpeg', 'png', 'gif'];
  final FirestorageService firestorageService = FirestorageService.instance();
  final BehaviorSubject<StorageFile?> _streamSelectedImage = BehaviorSubject();
  final StorageFile _storagePair = StorageFile();

  final FormFieldSetter<StorageFile> onSaved;
  final FormFieldValidator<StorageFile>? validator;
  final List<String> allowedExtensions;
  final StorageFile? initialValue;
  final void Function(StorageFile? storagePair)? onDeleted;

  StorageImageWidget(
      {required this.onSaved, required this.initialValue, this.validator, this.allowedExtensions = DEFAULT_ALLOWED_EXTENSIONS, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    _storagePair.fileName = initialValue?.fileName;
    _storagePair.fileBytes = initialValue?.fileBytes;
    _streamSelectedImage.sink.add(_storagePair);
    return StorageImageFormField<StorageFile>(
      builder: builderWidget,
    );
  }

  Widget builderWidget(FormFieldState<StorageFile> field) {
    return Row(
      children: [
        InkWell(
          child: StreamBuilder<StorageFile?>(
              stream: _streamSelectedImage.stream,
              builder: (context, snapshot) {
                ImageProvider? provider;
                if (snapshot.hasData && snapshot.data != null && snapshot.data!.fileBytes != null) {
                  provider = MemoryImage(snapshot.data!.fileBytes!);
                }
                return CircleAvatar(
                    child: Icon(
                      Icons.add_photo_alternate,
                      color: Colors.white,
                    ),
                    radius: 50,
                    foregroundImage: provider,
                    backgroundColor: Theme.of(context).primaryColor);
              }),
          onTap: () => onTap(),
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
        IconButton(
            tooltip: 'Supprimer la photo',
            onPressed: () {
              if (this.onDeleted != null) {
                this.onDeleted!(_storagePair);
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
    FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: this.allowedExtensions).then((result) {
      if (result != null) {
        _storagePair.fileBytes = result.files.first.bytes;
        _storagePair.fileName = result.files.first.name;
        this.onSaved(_storagePair);
        _streamSelectedImage.sink.add(_storagePair);
      }
    });
  }

  void dispose() {
    _streamSelectedImage.close();
  }
}

class StorageFutureImageWidget extends StatelessWidget {
  static const List<String> DEFAULT_ALLOWED_EXTENSIONS = ['jpg', 'jpeg', 'png', 'gif'];
  final FirestorageService firestorageService = FirestorageService.instance();
  final BehaviorSubject<StorageFile?> _streamSelectedImage = BehaviorSubject();
  final StorageFile _storagePair = StorageFile();

  final FormFieldSetter<StorageFile> onSaved;
  final FormFieldValidator<StorageFile>? validator;
  final List<String> allowedExtensions;
  final Future<StorageFile?> futureInitialStorageFile;
  final void Function(StorageFile? storagePair)? onDeleted;

  StorageFutureImageWidget(
      {required this.onSaved,
      required this.futureInitialStorageFile,
      this.validator,
      this.allowedExtensions = DEFAULT_ALLOWED_EXTENSIONS,
      this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StorageFile?>(
      future: futureInitialStorageFile,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            _storagePair.fileName = snapshot.data!.fileName;
            _storagePair.fileBytes = snapshot.data!.fileBytes;
          }
          _streamSelectedImage.sink.add(_storagePair);
          return StorageImageFormField<StorageFile>(
            builder: builderWidget,
          );
        } else {
          return LoadingRotating.square(
            backgroundColor: Theme.of(context).primaryColor,
          );
        }
      },
    );
  }

  Widget builderWidget(FormFieldState<StorageFile> field) {
    return Row(
      children: [
        InkWell(
          child: StreamBuilder<StorageFile?>(
              stream: _streamSelectedImage.stream,
              builder: (context, snapshot) {
                ImageProvider? provider;
                if (snapshot.hasData && snapshot.data != null && snapshot.data!.fileBytes != null) {
                  provider = MemoryImage(snapshot.data!.fileBytes!);
                }
                return CircleAvatar(
                    child: Icon(
                      Icons.add_photo_alternate,
                      color: Colors.white,
                    ),
                    radius: 50,
                    foregroundImage: provider,
                    backgroundColor: Theme.of(context).primaryColor);
              }),
          onTap: () => onTap(),
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
        IconButton(
            tooltip: 'Supprimer la photo',
            onPressed: () {
              if (this.onDeleted != null) {
                this.onDeleted!(_storagePair);
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
    FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: this.allowedExtensions).then((result) {
      if (result != null) {
        _storagePair.fileBytes = result.files.first.bytes;
        _storagePair.fileName = result.files.first.name;
        this.onSaved(_storagePair);
        _streamSelectedImage.sink.add(_storagePair);
      }
    });
  }

  void dispose() {
    _streamSelectedImage.close();
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

  final FirestorageService firestorageService = FirestorageService.instance();
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
  final FormFieldBuilder<T> builder;
  final FormFieldSetter<T>? onSaved;
  final FormFieldValidator<T>? validator;

  StorageImageFormField({required this.builder, this.onSaved, this.validator}) : super(builder: builder, onSaved: onSaved, validator: validator);
}
