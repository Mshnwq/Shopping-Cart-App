import 'package:flutter/material.dart';

class ConnectButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ConnectButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context)
            .colorScheme
            .background, // Set your desired button color
        foregroundColor: Colors.white, // Set your desired text color
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(20.0), // Set your desired border radius
        ),
        elevation: 4.0, // Set the elevation of the button
      ),
      child: Text(text),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double buttonHeight;
  final TextStyle? textStyle; // Optional TextStyle argument

  const CustomButton({
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

// class CustomButton extends StatelessWidget {
//   final String text;
//   final VoidCallback onPressed;
//   final double buttonHeight;

//   const CustomButton({
//     Key? key,
//     required this.text,
//     required this.onPressed,
//     this.buttonHeight = 48.0,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: buttonHeight,
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Theme.of(context)
//               .colorScheme
//               .background, // Set your desired button color
//           foregroundColor: Theme.of(context)
//               .colorScheme
//               .secondary, // Set your desired text color
//           shape: RoundedRectangleBorder(
//             borderRadius:
//                 BorderRadius.circular(20.0), // Set your desired border radius
//           ),
//           elevation: 4.0, // Set the elevations of the button
//         ),
//         child: Text(
//           text,
//           style: Theme.of(context).textTheme.titleMedium,
//         ),
//       ),
//     );
//   }
// }
