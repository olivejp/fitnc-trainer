import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fitnc_trainer/service/firestorage.service.dart';
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
  final FirestorageService firestorageService = FirestorageService.getInstance();
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
                    backgroundColor: Colors.amber);
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
  final FirestorageService firestorageService = FirestorageService.getInstance();
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
          return LoadingBouncingGrid.circle(backgroundColor: Colors.amber,);
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
                    backgroundColor: Color(Colors.amber.value));
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
              color: Color(Colors.amber.value),
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
  static const List<String> DEFAULT_ALLOWED_EXTENSIONS = ['jpg', 'jpeg', 'png', 'gif'];
  final FirestorageService firestorageService = FirestorageService.getInstance();
  final BehaviorSubject<StorageFile?> _streamSelectedImage = BehaviorSubject();
  final StorageFile _storagePair = StorageFile();

  final FormFieldSetter<StorageFile> onSaved;
  final FormFieldValidator<StorageFile>? validator;
  final List<String> allowedExtensions;
  final Stream<StorageFile?> streamInitialStorageFile;
  final void Function(StorageFile? storagePair)? onDeleted;

  StorageStreamImageWidget(
      {required this.onSaved,
      required this.streamInitialStorageFile,
      this.validator,
      this.allowedExtensions = DEFAULT_ALLOWED_EXTENSIONS,
      this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StorageFile?>(
      stream: streamInitialStorageFile,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _storagePair.fileName = snapshot.data!.fileName;
          _storagePair.fileBytes = snapshot.data!.fileBytes;
          _streamSelectedImage.sink.add(_storagePair);
          return StorageImageFormField<StorageFile>(
            builder: builderWidget,
          );
        } else {
          return InkWell(
            child: CircleAvatar(
                child: Icon(
                  Icons.add_photo_alternate,
                  color: Colors.white,
                ),
                radius: 50,
                backgroundColor: Colors.amber),
            onTap: () => onTap(),
            borderRadius: BorderRadius.all(Radius.circular(50)),
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
                    backgroundColor: Color(Colors.amber.value));
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
              color: Color(Colors.amber.value),
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

class StorageImageFormField<T> extends FormField<T> {
  final FormFieldBuilder<T> builder;
  final FormFieldSetter<T>? onSaved;
  final FormFieldValidator<T>? validator;

  StorageImageFormField({required this.builder, this.onSaved, this.validator}) : super(builder: builder, onSaved: onSaved, validator: validator);
}
