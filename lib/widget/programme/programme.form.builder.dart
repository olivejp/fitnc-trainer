import 'package:fitnc_trainer/bloc/programme/programme_update.bloc.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgrammeFormBuilder {
  static Widget getForm(GlobalKey<FormState> _formKey, ProgrammeUpdateBloc bloc) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 800),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StorageStreamImageWidget(
                    onSaved: (StorageFile? storagePair) => bloc.setStoragePair(storagePair),
                    streamInitialStorageFile: bloc.obsStoragePair,
                    onDeleted: (StorageFile? storagePair) => bloc.setStoragePair(null),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: TextFormField(
                          initialValue: bloc.programme.name,
                          autofocus: true,
                          onChanged: (String value) => bloc.setName(value),
                          decoration: const InputDecoration(helperText: 'Nom'),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Merci de renseigner le nom du programme.';
                            }
                            return null;
                          }),
                    ),
                  ),
                ],
              ),
            ),
            TextFormField(
              initialValue: bloc.programme.description,
              maxLength: 2000,
              minLines: 5,
              maxLines: 20,
              onChanged: (String value) => bloc.setDescription(value),
              decoration: const InputDecoration(helperText: 'Description (optionel)'),
            ),
          ],
        ),
      ),
    );
  }
}
