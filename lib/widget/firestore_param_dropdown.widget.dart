import 'package:fitnc_trainer/service/param.service.dart';
import 'package:flutter/material.dart';

class ParamDropdownButton extends StatelessWidget {
  static const Icon DEFAULT_ICON = Icon(Icons.track_changes);

  final ParamService paramService = ParamService.getInstance();

  final String paramName;
  final dynamic initialValue;
  final void Function(String? onChangedValue) onChanged;
  final Icon icon;

  ParamDropdownButton({required this.paramName, required this.initialValue, required this.onChanged, this.icon = DEFAULT_ICON});

  @override
  Widget build(BuildContext context) {
    return FutureDropdownButton(
      initialValue: initialValue,
      future: paramService.getParamAsDropdown(this.paramName),
      onChanged: onChanged,
      icon: icon,
    );
  }
}

class FutureDropdownButton extends StatelessWidget {
  final dynamic initialValue;
  final void Function(String? onChangedValue) onChanged;
  final Icon icon;
  final Future<List<DropdownMenuItem<dynamic>>> future;

  FutureDropdownButton({required this.future, required this.initialValue, required this.onChanged, required this.icon});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: this.future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return DropdownButtonFormField<String>(icon: this.icon, onChanged: this.onChanged, value: initialValue, items: snapshot.data);
          }
          return Container();
        });
  }
}

class StreamDropdownButton<T> extends StatelessWidget {
  final dynamic initialValue;
  final void Function(T? onChangedValue) onChanged;
  final Icon icon;
  final Stream<List<DropdownMenuItem<T>>> stream;
  final List<DropdownMenuItem<T>> list = [];

  StreamDropdownButton({required this.stream, required this.initialValue, required this.onChanged, required this.icon});

  @override
  Widget build(BuildContext context) {
    this.list.clear();
    return StreamBuilder<List<DropdownMenuItem<T>>>(
        stream: this.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            list.addAll(snapshot.data!);
            return DropdownButtonFormField<T>(icon: this.icon, onChanged: this.onChanged, value: initialValue, items: list);
          }
          return Container();
        });
  }
}
