import 'package:fitnc_trainer/service/param.service.dart';
import 'package:fitnc_trainer/service/timer.service.dart';
import 'package:flutter/material.dart';

class TimerDropdownButton extends StatelessWidget {
  static const Icon defaultIcon = Icon(Icons.arrow_downward);

  @override
  final Key? key;
  final TimerService timerService = TimerService.getInstance();
  final TextStyle? style;
  final InputDecoration? decoration;
  final String? initialValue;
  final void Function(String? onChangedValue) onChanged;
  final Icon? icon;
  final Widget? hint;
  final bool onlyName;
  final bool insertNull;
  final String? nullElement;

  TimerDropdownButton({
    this.key,
    this.style,
    this.decoration,
    required this.initialValue,
    required this.onChanged,
    this.icon = defaultIcon,
    this.onlyName = false,
    this.hint,
    this.insertNull = false,
    this.nullElement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      style: style,
      icon: icon,
      onChanged: onChanged,
      value: initialValue,
      items: timerService.getDropdownMenuItem(onlyName, insertNull, nullElement),
      hint: hint,
      decoration: decoration,
    );
  }
}

class ParamDropdownButton extends StatelessWidget {
  static const Icon DEFAULT_ICON = Icon(Icons.arrow_downward);

  final Key? key;
  final ParamService paramService = ParamService.getInstance();
  final TextStyle? style;
  final InputDecoration? decoration;
  final String paramName;
  final String? initialValue;
  final void Function(String? onChangedValue) onChanged;
  final Icon? icon;
  final Widget? hint;
  final bool onlyValue;
  final bool insertNull;
  final String? nullElement;

  ParamDropdownButton({
    this.key,
    this.style,
    this.decoration,
    required this.paramName,
    required this.initialValue,
    required this.onChanged,
    this.icon = DEFAULT_ICON,
    this.onlyValue = false,
    this.hint,
    this.insertNull = false,
    this.nullElement,
  });

  @override
  Widget build(BuildContext context) {
    return FutureDropdownButton(
      style: style,
      decoration: decoration,
      initialValue: initialValue,
      future: paramService.getFutureParamAsDropdown(paramName, onlyValue, insertNull, nullElement),
      onChanged: onChanged,
      icon: icon,
      hint: hint,
    );
  }
}

class FutureDropdownButton extends StatelessWidget {
  final Key? key;
  final TextStyle? style;
  final String? initialValue;
  final InputDecoration? decoration;
  final void Function(String? onChangedValue) onChanged;
  final Icon? icon;
  final Widget? hint;
  final Future<List<DropdownMenuItem<String?>>> future;

  FutureDropdownButton(
      {this.key, this.decoration, this.style, required this.future, required this.initialValue, required this.onChanged, this.icon, this.hint});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DropdownMenuItem<String?>>>(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<List<DropdownMenuItem<String?>>> snapshot) {
          if (snapshot.hasData) {
            return DropdownButtonFormField<String?>(
              style: style,
              key: key,
              icon: icon,
              onChanged: onChanged,
              value: initialValue,
              items: snapshot.data,
              hint: hint,
              decoration: decoration,
            );
          }
          return DropdownButtonFormField<String?>(
            style: style,
            key: key,
            icon: icon,
            onChanged: onChanged,
            value: initialValue,
            items: [],
            hint: hint,
            decoration: decoration,
          );
        });
  }
}

class StreamDropdownButton extends StatelessWidget {
  final Key? key;
  final TextStyle? style;
  final String? initialValue;
  final InputDecoration? decoration;
  final void Function(String? onChangedValue) onChanged;
  final Icon? icon;
  final Widget? hint;
  final Stream<List<DropdownMenuItem<String?>>> stream;

  StreamDropdownButton(
      {this.key, this.decoration, this.style, required this.stream, required this.initialValue, required this.onChanged, this.icon, this.hint});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DropdownMenuItem<String?>>>(
        stream: this.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return DropdownButtonFormField<String?>(
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
