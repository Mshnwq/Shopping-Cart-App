import 'package:flutter/material.dart';

class CustomDialogButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const CustomDialogButton({
    Key? key,
    required this.text,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context)
            .colorScheme
            .primary, // Set your desired button color
        foregroundColor: Theme.of(context)
            .colorScheme
            .background, // Set your desired text color
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(20.0), // Set your desired border radius
        ),
        elevation: 4.0, // Set the elevations of the button
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.background,
            ),
      ),
    );
  }
}

class CustomPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double buttonHeight;
  final TextStyle? textStyle; // Optional TextStyle argument

  const CustomPrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.buttonHeight = 48.0,
    this.textStyle, // Provide a default value of null
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context)
              .colorScheme
              .background, // Set your desired button color
          foregroundColor: Theme.of(context)
              .colorScheme
              .secondary, // Set your desired text color
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20.0), // Set your desired border radius
          ),
          elevation: 4.0, // Set the elevation of the button
        ),
        child: Text(
          text,
          style: textStyle ?? Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class CustomSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double buttonHeight;
  final TextStyle? textStyle; // Optional TextStyle argument

  const CustomSecondaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.buttonHeight = 48.0,
    this.textStyle, // Provide a default value of null
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context)
              .colorScheme
              .primary, // Set your desired button color
          foregroundColor: Theme.of(context)
              .colorScheme
              .background, // Set your desired text color
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20.0), // Set your desired border radius
          ),
          elevation: 4.0, // Set the elevation of the button
        ),
        child: Text(
          text,
          style: textStyle ??
              Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.background,
                  ),
        ),
      ),
    );
  }
}
