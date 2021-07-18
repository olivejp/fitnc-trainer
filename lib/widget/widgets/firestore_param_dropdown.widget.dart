import 'package:fitnc_trainer/service/param.service.dart';
import 'package:flutter/material.dart';

class ParamDropdownButton extends StatelessWidget {
  static const Icon DEFAULT_ICON = Icon(Icons.track_changes);

  final ParamService paramService = ParamService.getInstance();
  final TextStyle? style;
  final InputDecoration? decoration;
  final String paramName;
  final dynamic initialValue;
  final void Function(String? onChangedValue) onChanged;
  final Icon? icon;
  final Widget? hint;

  ParamDropdownButton(
      {this.style,
      this.decoration,
      required this.paramName,
      required this.initialValue,
      required this.onChanged,
      this.icon = DEFAULT_ICON,
      this.hint});

  @override
  Widget build(BuildContext context) {
    return FutureDropdownButton(
      style: this.style,
      decoration: this.decoration,
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
  final TextStyle? style;
  final dynamic initialValue;
  final InputDecoration? decoration;
  final void Function(String? onChangedValue) onChanged;
  final Icon? icon;
  final Widget? hint;
  final Future<List<DropdownMenuItem<dynamic>>> future;

  FutureDropdownButton(
      {this.key, this.decoration, this.style, required this.future, required this.initialValue, required this.onChanged, this.icon, this.hint});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: this.future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return DropdownButtonFormField<String>(
              style: style,
              key: this.key,
              icon: this.icon,
              onChanged: this.onChanged,
              value: initialValue,
              items: snapshot.data,
              hint: this.hint,
              decoration: decoration,
            );
          }
          return Container();
        });
  }
}

class StreamDropdownButton<T> extends StatelessWidget {
  final Key? dropdownKey;
  final TextStyle? style;
  final dynamic initialValue;
  final InputDecoration? decoration;
  final void Function(T? onChangedValue) onChanged;
  final Icon? icon;
  final Stream<List<DropdownMenuItem<T>>> stream;
  final List<DropdownMenuItem<T>> list = [];

  StreamDropdownButton(
      {this.dropdownKey, this.decoration, this.style, required this.stream, required this.initialValue, required this.onChanged, this.icon});

  @override
  Widget build(BuildContext context) {
    this.list.clear();
    return StreamBuilder<List<DropdownMenuItem<T>>>(
        stream: this.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            list.addAll(snapshot.data!);
            return DropdownButtonFormField<T>(
              style: style,
              key: this.dropdownKey,
              icon: this.icon,
              onChanged: this.onChanged,
              value: initialValue,
              items: list,
              decoration: decoration,
            );
          }
          return Container();
        });
  }
}
