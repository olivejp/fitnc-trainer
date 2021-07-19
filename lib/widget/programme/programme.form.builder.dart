import 'package:fitnc_trainer/bloc/programme/programme_update.bloc.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgrammeFormBuilder {
  static Widget getForm(GlobalKey<FormState> _formKey, ProgrammeUpdateBloc bloc) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 800),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StorageStreamImageWidget(
                    onSaved: (storagePair) => bloc.setStoragePair(storagePair),
                    streamInitialStoragePair: bloc.obsStoragePair,
                    onDeleted: (storagePair) => bloc.setStoragePair(null),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: TextFormField(
                          initialValue: bloc.programme.name,
                          autofocus: true,
                          onChanged: (value) => bloc.setName(value),
                          decoration: InputDecoration(helperText: 'Nom'),
                          validator: (value) {
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
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TextFormField(
                initialValue: bloc.programme.description,
                maxLength: 2000,
                minLines: 5,
                maxLines: 20,
                onChanged: (value) => bloc.setDescription(value),
                decoration: InputDecoration(helperText: 'Description (optionel)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
