import 'package:fitnc_trainer/main.dart';
import 'package:flutter/material.dart';

class FitnessDecorationTextFormField extends StatelessWidget {
  const FitnessDecorationTextFormField({Key? key, this.initialValue, this.labelText, this.onChanged, this.validator, this.autofocus = false, this.hintText}) : super(key: key);

  final bool autofocus;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final String? labelText;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        autofocus: autofocus,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          constraints: const BoxConstraints(maxHeight: FitnessConstants.textFormFieldHeight),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        validator: validator);
  }
}
