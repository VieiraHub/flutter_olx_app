import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class CustomInput extends StatelessWidget {

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final bool autofocus;
  final TextInputType keyboardType;
  final int maxLines;
  final List<TextInputFormatter> inputFormatters;
  final Function(String) validator;
  final Function(String) onSaved;

  CustomInput({
    @required this.controller,
    @required this.hint,
    this.obscure = false,
    this.autofocus = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.inputFormatters,
    this.validator,
    this.onSaved
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: this.controller,
        obscureText: this.obscure,
        autofocus: this.autofocus,
        keyboardType: this.keyboardType,
        maxLines: this.maxLines,
        onSaved: this.onSaved,
        inputFormatters: this.inputFormatters,
        validator: this.validator,
        style: TextStyle(fontSize: 20),
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
            hintText: this.hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6)
            )
        )
    );
  }
}
