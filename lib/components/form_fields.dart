import 'package:flutter/material.dart';

class TextInputField extends StatefulWidget {
  const TextInputField(
      {super.key, required this.label, required this.value, this.onChanged});

  final String label;
  final String value;
  final ValueChanged? onChanged;

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      // spacing: 10.0,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            "${widget.label}:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
            flex: 7,
            child: TextField(
              controller: _controller,
              // controller: TextEditingController(text: widget.value),
              onChanged: widget.onChanged,
            ))
      ],
    );
  }
}

class FixedStringField extends StatelessWidget {
  const FixedStringField({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      // spacing: 10.0,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            "$label:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
            flex: 7,
            child: Text(
              value,
              softWrap: true,
              overflow: TextOverflow.clip,
            ))
      ],
    );
  }
}

class OptionInputField extends StatelessWidget {
  const OptionInputField(
      {super.key,
      required this.label,
      required this.value,
      required this.options,
      required this.onChanged});

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      // spacing: 10.0,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            "$label:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 7,
          child: DropdownButton(
            value: value,
            items: options.map<DropdownMenuItem<String>>((String _val) {
              return DropdownMenuItem<String>(
                value: _val,
                child: Text(_val),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        )
      ],
    );
  }
}
