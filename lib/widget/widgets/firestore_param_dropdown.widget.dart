import 'package:fitnc_trainer/service/param.service.dart';
import 'package:flutter/material.dart';

class ParamDropdownButton extends StatelessWidget {
  static const Icon DEFAULT_ICON = Icon(Icons.track_changes);

  final ParamService paramService = ParamService.getInstance();

  final String paramName;
  final dynamic initialValue;
  final void Function(String? onChangedValue) onChanged;
  final Icon icon;
  final Widget? hint;

  ParamDropdownButton({required this.paramName, required this.initialValue, required this.onChanged, this.icon = DEFAULT_ICON, this.hint});

  @override
  Widget build(BuildContext context) {
    return FutureDropdownButton(
      initialValue: this.initialValue,
      future: this.paramService.getParamAsDropdown(this.paramName),
      onChanged: this.onChanged,
      icon: this.icon,
      hint: this.hint,
    );
  }
}

class FutureDropdownButton extends StatelessWidget {
  final Key? key;
  final dynamic initialValue;
  final void Function(String? onChangedValue) onChanged;
  final Icon icon;
  final Widget? hint;
  final Future<List<DropdownMenuItem<dynamic>>> future;

  FutureDropdownButton({this.key, required this.future, required this.initialValue, required this.onChanged, required this.icon, this.hint});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: this.future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return DropdownButtonFormField<String>(
                key: this.key, icon: this.icon, onChanged: this.onChanged, value: initialValue, items: snapshot.data, hint: this.hint,);
          }
          return Container();
        });
  }
}

class StreamDropdownButton<T> extends StatelessWidget {
  final Key? dropdownKey;
  final dynamic initialValue;
  final void Function(T? onChangedValue) onChanged;
  final Icon icon;
  final Stream<List<DropdownMenuItem<T>>> stream;
  final List<DropdownMenuItem<T>> list = [];

  StreamDropdownButton({this.dropdownKey, required this.stream, required this.initialValue, required this.onChanged, required this.icon});

  @override
  Widget build(BuildContext context) {
    this.list.clear();
    return StreamBuilder<List<DropdownMenuItem<T>>>(
        stream: this.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            list.addAll(snapshot.data!);
            return DropdownButtonFormField<T>(key: this.dropdownKey, icon: this.icon, onChanged: this.onChanged, value: initialValue, items: list);
          }
          return Container();
        });
  }
}
