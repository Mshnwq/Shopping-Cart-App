// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../theme/themes.dart';

// typedef Action = void Function();

// class CustomSlidButton extends StatefulWidget {
//   final Action? onTapLeft;
//   final Action? onTapRight;
//   final String leftLabel;
//   final String rightLabel;
//   final double width;
//   final double hight;
//   const CustomSlidButton({
//     required this.width,
//     required this.hight,
//     this.onTapLeft,
//     this.onTapRight,
//     required this.leftLabel,
//     required this.rightLabel,
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<CustomSlidButton> createState() => _CustomSlidButtonState();
// }

// class _CustomSlidButtonState extends State<CustomSlidButton> {
//   bool isLeftSelected = true;

//   @override
//   Widget build(BuildContext context) {
//     String label = (isLeftSelected) ? widget.leftLabel : widget.rightLabel;
//     return Container(
//       margin: const EdgeInsets.only(top: 20),
//       width: widget.width,
//       height: widget.hight,
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(30), color: Colors.white),
//       child: Stack(children: [
//         buildTextHolder(widget.leftLabel, isLeftSelected),
//         buildTextHolder(widget.rightLabel, !isLeftSelected),
//         buildSlidButton(label)
//       ]),
//     );
//   }

//   AnimatedAlign buildSlidButton(String label) {
//     AppTheme appTheme = context.read<ThemeProvider>().getAppTheme();
//     return AnimatedAlign(
//       alignment:
//           (isLeftSelected) ? Alignment.centerLeft : Alignment.centerRight,
//       duration: const Duration(milliseconds: 200),
//       child: buildButton(label, appTheme.cardColor, Colors.white),
//     );
//   }

//   AnimatedOpacity buildTextHolder(String label, bool isActive) {
//     return AnimatedOpacity(
//       opacity: (isActive) ? 0 : 1,
//       duration: const Duration(milliseconds: 200),
//       child: Align(
//         alignment:
//             (isLeftSelected) ? Alignment.centerRight : Alignment.centerLeft,
//         child: GestureDetector(
//           onTap: () => setState(() {
//             isLeftSelected = !isLeftSelected;
//             Action onTap = (isLeftSelected)
//                 ? widget.onTapLeft as Action
//                 : widget.onTapRight as Action;
//             onTap();
//           }),
//           child: buildButton(label, Colors.white, Colors.grey),
//         ),
//       ),
//     );
//   }

//   Container buildButton(String label, Color backgroundColor, Color textColor) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//       width: widget.width / 2,
//       height: widget.hight - 6,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(25),
//         color: backgroundColor,
//       ),
//       child: Center(
//         child: Text(
//           label,
//           style: TextStyle(fontSize: 11, color: textColor),
//         ),
//       ),
//     );
//   }
// }
