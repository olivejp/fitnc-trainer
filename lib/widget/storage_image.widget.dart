import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fitnc_trainer/service/firestorage.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class StoragePair {
  Uint8List? fileBytes;
  String? fileName;
}

class StorageImageWidget extends StatelessWidget {
  static const List<String> DEFAULT_ALLOWED_EXTENSIONS = ['jpg', 'jpeg', 'png', 'gif'];
  final FirestorageService firestorageService = FirestorageService.getInstance();
  final BehaviorSubject<StoragePair?> _streamSelectedImage = BehaviorSubject();
  final StoragePair _storagePair = StoragePair();

  final FormFieldSetter<StoragePair> onSaved;
  final FormFieldValidator<StoragePair>? validator;
  final List<String> allowedExtensions;
  final Stream<StoragePair?> streamInitialStoragePair;
  final void Function(StoragePair? storagePair)? onDeleted;

  StorageImageWidget(
      {required this.onSaved,
      required this.streamInitialStoragePair,
      this.validator,
      this.allowedExtensions = DEFAULT_ALLOWED_EXTENSIONS,
      this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StoragePair?>(
      stream: streamInitialStoragePair,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _storagePair.fileName = snapshot.data!.fileName;
          _storagePair.fileBytes = snapshot.data!.fileBytes;
          _streamSelectedImage.sink.add(_storagePair);
          return StorageImageFormField<StoragePair>(
            builder: builderWidget,
          );
        } else {
          return InkWell(
            child: CircleAvatar(
                child: Icon(
                  Icons.add_photo_alternate,
                  color: Color(Colors.white.value),
                ),
                radius: 50,
                backgroundColor: Color(Colors.amber.value)),
            onTap: () => onTap(),
            borderRadius: BorderRadius.all(Radius.circular(50)),
          );
        }
      },
    );
  }

  Widget builderWidget(FormFieldState<StoragePair> field) {
    return Row(
      children: [
        InkWell(
          child: StreamBuilder<StoragePair?>(
              stream: _streamSelectedImage.stream,
              builder: (context, snapshot) {
                ImageProvider? provider;
                if (snapshot.hasData && snapshot.data != null && snapshot.data!.fileBytes != null) {
                  provider = MemoryImage(snapshot.data!.fileBytes!);
                }
                return CircleAvatar(
                    child: Icon(
                      Icons.add_photo_alternate,
                      color: Color(Colors.white.value),
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
