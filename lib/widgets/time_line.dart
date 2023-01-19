import 'package:flutter/material.dart';

enum NodeState {
  complete,
  processing,
  pending,
}

enum LineType {
  vertical,
  horizontal,
}

typedef ControlsWidgetBuilder = Widget Function(
    BuildContext context, ControlsDetails details);
const double _nodeSize = 24.0;
const kThemeAnimationDuration = Duration(milliseconds: 200);

@immutable
class Node {
  Node({
    required this.title,
    this.subtitle,
    required this.content,
  }) {
    _state = _Processing();
  }

  final String title;
  final String? subtitle;
  final Widget content;
  _NodeState _state = _Pending();
}

class _NodeState {
  _NodeState({required this.stateColor, required this.stateIcon});
  Color stateColor;
  IconData stateIcon;
}

class _Complete extends _NodeState {
  _Complete() : super(stateColor: Colors.greenAccent, stateIcon: Icons.check);
}

class _Processing extends _NodeState {
  _Processing()
      : super(stateColor: Colors.orangeAccent, stateIcon: Icons.settings);
}

class _Pending extends _NodeState {
  _Pending() : super(stateColor: Colors.grey, stateIcon: Icons.pending);
}

class TimeLine extends StatefulWidget {
  const TimeLine({
    Key? key,
    required this.nodes,
    required this.state,
    this.physics,
    this.controlsBuilder,
    this.elevation,
    this.margin,
  }) : super(key: key);
  final int state;
  final List<Node> nodes;
  final ScrollPhysics? physics;
  final ControlsWidgetBuilder? controlsBuilder;
  final double? elevation;
  final EdgeInsetsGeometry? margin;
  @override
  State<TimeLine> createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine> with TickerProviderStateMixin {
  late List<GlobalKey> _keys;
  int currentStep = -1;

  @override
  void initState() {
    super.initState();
    _keys = List<GlobalKey>.generate(
      widget.nodes.length,
      (int i) => GlobalKey(),
    );
  }

  bool _isFirst(int index) {
    return index == 0;
  }

  bool _isLast(int index) {
    return widget.nodes.length - 1 == index;
  }

  // Because list builder build from up to down
  bool _isComplete(int index) {
    return (widget.nodes.length - 1 - index) < widget.state;
  }

  bool _isCurrent(int index) {
    return currentStep == index;
  }

  Widget _buildLine(bool visible) {
    return Container(
      width: visible ? 1.0 : 0.0,
      height: 16.0,
      color: Colors.grey.shade400,
    );
  }

  Widget _buildCircle(int index, bool oldState) {
    widget.nodes[index]._state = _isComplete(index) ? _Complete() : _Pending();
    final _NodeState state = widget.nodes[index]._state;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      width: _nodeSize,
      height: _nodeSize,
      child: AnimatedContainer(
        curve: Curves.fastOutSlowIn,
        duration: kThemeAnimationDuration,
        decoration: BoxDecoration(
          color: state.stateColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            state.stateIcon,
            size: 18.0,
          ),
        ),
      ),
    );
  }

  Widget _buildState(int index) {
    return _buildCircle(index, false);
  }

  Widget _buildHeaderText(int index) {
    Node node = widget.nodes[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(node.title),
        if (node.subtitle != null)
          Container(
            margin: const EdgeInsets.only(top: 2.0),
            child: Text(
              node.subtitle!,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              // Line parts are always added in order for the ink splash to
              // flood the tips of the connector lines.
              _buildLine(!_isFirst(index)),
              _buildState(index),
              _buildLine(!_isLast(index)),
            ],
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsetsDirectional.only(start: 12.0),
              child: _buildHeaderText(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(int index) {
    return Stack(
      children: <Widget>[
        PositionedDirectional(
          start: 24.0,
          top: 0.0,
          bottom: 0.0,
          child: SizedBox(
            width: 24.0,
            child: Center(
              child: SizedBox(
                width: _isLast(index) ? 0.0 : 1.0,
                child: Container(
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Container(height: 0.0),
          secondChild: Container(
            margin: widget.margin ??
                const EdgeInsetsDirectional.only(
                  start: 60.0,
                  end: 24.0,
                  bottom: 24.0,
                ),
            child:
                Row(children: [Flexible(child: widget.nodes[index].content)]),
          ),
          firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
          secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
          sizeCurve: Curves.fastOutSlowIn,
          crossFadeState: _isCurrent(index)
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: kThemeAnimationDuration,
        ),
      ],
    );
  }

  ValueChanged<int>? onStepTapped(int index) {
    setState(() {
      if (index != currentStep) {
        currentStep = index;
      } else if (currentStep != -1) {
        currentStep = -1;
      }
    });
    return null;
  }

  Widget _buildTimeLine() {
    return ListView(
      padding: const EdgeInsets.only(top: 10),
      shrinkWrap: true,
      physics: widget.physics,
      children: <Widget>[
        for (int i = 0; i < widget.nodes.length; i += 1)
          Column(
            key: _keys[i],
            children: <Widget>[
              InkWell(
                onTap: () {
                  // Scroll to the taped node
                  // Scrollable.ensureVisible(
                  //   _keys[i].currentContext!,
                  //   curve: Curves.fastOutSlowIn,
                  //   duration: kThemeAnimationDuration,
                  // );
                  onStepTapped.call(i);
                },
                child: _buildHeader(i),
              ),
              _buildBody(i),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    return _buildTimeLine();
  }
}
