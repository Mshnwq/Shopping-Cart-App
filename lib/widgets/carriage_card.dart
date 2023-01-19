// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:go_router/go_router.dart';
// import 'package:main_project/app/pages/main_page.dart';
// import 'package:main_project/app/widgets/snack_bars.dart';
// import 'package:main_project/services/api.dart';

// import 'package:main_project/theme/themes.dart';
// import 'package:main_project/app/widgets/time_line.dart';
// import 'package:main_project/module/carriage.dart';
// import 'package:provider/provider.dart';
// import 'custom_buttons.dart';
// import 'package:main_project/app/util/custom_rect_tween.dart';

// import 'package:main_project/states/stream_state.dart';

// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// class CarriageCard extends StatelessWidget {
//   const CarriageCard({Key? key, required this.carriage}) : super(key: key);
//   final Carriage? carriage;
//   @override
//   Widget build(BuildContext context) {
//     AppTheme appTheme = context.read<ThemeProvider>().getAppTheme();
//     return GestureDetector(
//       onTap: () {
//         Navigator.of(context).push(HeroDialogRoute(builder: (context) {
//           return _PopupTimeLine(
//             id: carriage!.id,
//             carriage: carriage!,
//           );
//         }));
//       },
//       child: Hero(
//         tag: "${carriage!.id}",
//         createRectTween: (begin, end) =>
//             CustomRectTween(begin: begin, end: end),
//         child: Material(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
//           color: appTheme.cardColor,
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(11),
//               // border: Border.all(width: 10, color: Colors.white),
//               //color: Themes.boxColor),
//             ),
//             child: Stack(children: [
//               Positioned(
//                 right: 20,
//                 top: 20,
//                 child: Container(
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(110),
//                       color: (!carriage!.isMissing)
//                           ? Colors.red[400]
//                           : (carriage!.isArrived())
//                               ? appTheme.green
//                               : appTheme.orange),
//                   width: 8,
//                   height: 8,
//                 ),
//               ),
//               Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       carriage!.icon,
//                       size: 55,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(carriage!.label),
//                     ),
//                     Text(
//                       "${(carriage!.weight ?? 0).toString()} kg",
//                       style: const TextStyle(color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               )
//             ]),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class FlightCard extends StatelessWidget {
//   const FlightCard({Key? key, required this.flight}) : super(key: key);
//   final Flight flight;
//   @override
//   Widget build(BuildContext context) {
//     final AppLocalizations local = AppLocalizations.of(context)!;
//     AppTheme appTheme = context.read<ThemeProvider>().getAppTheme();
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(11),
//         // border: Border.all(width: 10, color: Colors.white),
//         color: appTheme.cardColor,
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(11),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: (() {
//               context.goNamed("carriages");
//             }),
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.flight,
//                     size: 40,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(flight.airlineName),
//                   ),
//                   SubText(
//                     "${local.flightNumber}: ${(flight.flightNumber)}",
//                   ),
//                   SubText(
//                     "${local.flightDistention}:  ${(flight.destination)}",
//                   ),
//                   SubText(
//                     "${local.bagsCounter}: ${(flight.carriageNumber).toString()}",
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class SubText extends StatelessWidget {
//   final String text;
//   const SubText(this.text, {Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       style: const TextStyle(color: Colors.grey, fontSize: 12),
//     );
//   }
// }

// class CardDialog extends StatelessWidget {
//   const CardDialog({Key? key, required this.child}) : super(key: key);
//   final Widget child;

//   @override
//   Widget build(BuildContext context) {
//     AppTheme appTheme = context.read<ThemeProvider>().getAppTheme();
//     return Material(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
//       color: appTheme.cardColor,
//       child: SizedBox(
//         height: 450,
//         width: 300,
//         child: child,
//       ),
//     );
//   }
// }

// class PopupCard extends StatelessWidget {
//   const PopupCard({Key? key, required this.child, required this.id})
//       : super(key: key);
//   final Widget child;
//   final Object id;
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//         child: Hero(
//             tag: id,
//             createRectTween: (begin, end) {
//               return CustomRectTween(begin: begin, end: end);
//             },
//             child: CardDialog(
//               child: child,
//             )));
//   }
// }

// class _PopupTimeLine extends StatefulWidget {
//   const _PopupTimeLine({Key? key, required this.id, required this.carriage})
//       : super(key: key);
//   final Carriage carriage;
//   final int id;

//   @override
//   State<_PopupTimeLine> createState() => _PopupTimeLineState();
// }

// class _PopupTimeLineState extends State<_PopupTimeLine> {
//   final int index = 0;
//   late Widget childWidget;
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   didChangeDependencies() {
//     var local = AppLocalizations.of(context)!;
//     childWidget = buildTimeline(context, local);
//     super.didChangeDependencies();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedSwitcher(
//       transitionBuilder: ((child, animation) => ScaleTransition(
//             scale: animation,
//             child: child,
//           )),
//       duration: const Duration(milliseconds: 250),
//       child: childWidget,
//     );
//   }

//   Widget buildTimeline(BuildContext context, AppLocalizations local) {
//     return PopupCard(
//       id: "${widget.id}",
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(32),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               CustomSlidButton(
//                 width: 145,
//                 hight: 46,
//                 leftLabel: local.takeOff,
//                 rightLabel: local.arrive,
//                 //TODO: implement timeline switch actions
//                 onTapLeft: () => print("left"),
//                 onTapRight: () => print("right"),
//               ),
//               StreamBuilder<List<Carriage>>(
//                   stream: CarriageList().streamController.stream,
//                   builder: (context, snapshot) {
//                     int timeline;
//                     if (snapshot.connectionState == ConnectionState.active) {
//                       Carriage currentCarriage = snapshot.data!.firstWhere(
//                         (element) => element.id == widget.carriage.id,
//                       );
//                       timeline = currentCarriage.timeline;
//                     } else {
//                       timeline = widget.carriage.timeline;
//                     }
//                     return buildTimeLine(timeline);
//                   }),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: (!widget.carriage.isMissing)
//                     ? Container(
//                         margin: const EdgeInsets.only(bottom: 20),
//                         width: 200,
//                         height: 45,
//                         decoration: BoxDecoration(
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(8.0)),
//                             color: Colors.red[400]),
//                         child: TextButton(
//                             onPressed: () async {
//                               setState(() {
//                                 childWidget = ReportCard(
//                                   id: "${widget.id}",
//                                 );
//                               });
//                             },
//                             child: Text(
//                               local.reportMissingCarriageButton,
//                               style: const TextStyle(color: Colors.white),
//                             )),
//                       )
//                     : Container(),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     // context
//     super.dispose();
//   }

//   TimeLine buildTimeLine(int timeline) {
//     AppLocalizations local = AppLocalizations.of(context)!;
//     return TimeLine(
//         physics: const BouncingScrollPhysics(),
//         state: timeline,
//         nodes: <Node>[
//           Node(
//             title: local.timelineForthStageTitle,
//             content: Text(
//               local.timelineForthStageMessage,
//               maxLines: 4,
//             ),
//           ),
//           Node(
//             title: local.timelineThirdStageTitle,
//             content: Text(
//               local.timelineThirdStageMessage,
//               maxLines: 4,
//             ),
//           ),
//           Node(
//             title: local.timelineSecondStageTitle,
//             content: Text(
//               local.timelineSecondStageMessage,
//               maxLines: 4,
//             ),
//           ),
//           Node(
//             title: local.timelineFirstStageTitle,
//             content: Text(
//               local.timelineFirstStageMessage,
//             ),
//           )
//         ]);
//   }

//   NodeState getNodeState(int index, int state) {
//     if (index < state) return NodeState.complete;
//     if (index == state) return NodeState.processing;
//     return NodeState.pending;
//   }
// }

// class ConstrainedView extends StatelessWidget {
//   const ConstrainedView({Key? key, required this.child, this.width = 300})
//       : super(key: key);
//   final int width;
//   final Widget child;
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       if (constraints.maxWidth < width) {
//         return Container();
//       }
//       return child;
//     });
//   }
// }

// class ReportCard extends StatelessWidget {
//   const ReportCard({Key? key, required this.id}) : super(key: key);
//   final Object id;

//   @override
//   Widget build(BuildContext context) {
//     TextEditingController controller = TextEditingController();
//     var local = AppLocalizations.of(context)!;
//     return PopupCard(
//         id: id,
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top: 20),
//               child: Text(local.reportFromTitle),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 30.0),
//               child: SizedBox(
//                 width: 230,
//                 height: 260,
//                 child: TextField(
//                   controller: controller,
//                   decoration: InputDecoration(
//                     floatingLabelBehavior: FloatingLabelBehavior.always,
//                     labelText: local.reportInputFieldPlaceholder,
//                     border: const OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.white)),
//                   ),
//                   keyboardType: TextInputType.multiline,
//                   maxLines: 12,
//                   maxLength: 1000,
//                   // textInputAction: TextInputAction.send,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 20.0),
//               child: FutureBuilder(
//                 builder: (context, snapshot) => Container(
//                   width: 200,
//                   height: 45,
//                   decoration: const BoxDecoration(
//                       borderRadius: BorderRadius.all(Radius.circular(8.0)),
//                       color: Colors.white),
//                   child: TextButton(
//                     onPressed: () {
//                       reportMissingBag(id as String, controller.text);
//                       Navigator.of(context).pop();
//                       showSuccussSnackBar(context);
//                     },
//                     child: Text(
//                       local.submitReport,
//                       style: const TextStyle(color: Colors.black),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ));
//   }
// }

// class HeroDialogRoute extends PageRoute {
//   HeroDialogRoute(
//       {required WidgetBuilder builder,
//       RouteSettings? settings,
//       bool fullScreenDialog = false})
//       : _builder = builder,
//         super(settings: settings, fullscreenDialog: fullScreenDialog);

//   final WidgetBuilder _builder;

//   @override
//   bool get opaque => false;

//   @override
//   bool get barrierDismissible => true;
//   @override
//   Color? get barrierColor => Colors.black54;

//   @override
//   String? get barrierLabel => "Time Line Page";

//   @override
//   Widget buildPage(BuildContext context, Animation<double> animation,
//       Animation<double> secondaryAnimation) {
//     return _builder(context);
//   }

//   @override
//   bool get maintainState => false;

//   @override
//   Duration get transitionDuration => const Duration(milliseconds: 400);
// }
