import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool enableToggle;
  final bool isEmail;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.enableToggle = false,
    this.isEmail = false,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        alignment:
            Alignment.centerRight, // Align the suffix icon to the center-right
        children: [
          TextField(
            textAlign: TextAlign.center,
            controller: widget.controller,
            obscureText: widget.enableToggle ? _obscureText : false,
            enableSuggestions: !widget.enableToggle || !_obscureText,
            autocorrect: false,
            keyboardType: widget.isEmail ? TextInputType.emailAddress : null,
            style: TextStyle(color: Colors.black.withOpacity(0.75)),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            ),
          ),
          widget.enableToggle
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
