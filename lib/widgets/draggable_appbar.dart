import 'package:flutter/material.dart';

class DraggableAppBar extends StatefulWidget {
  const DraggableAppBar({super.key});

  @override
  _DraggableAppBarState createState() => _DraggableAppBarState();
}

class _DraggableAppBarState extends State<DraggableAppBar> {
  double _top = 0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _top,
      left: 0,
      right: 0,
      child: GestureDetector(
        onVerticalDragUpdate: (DragUpdateDetails details) {
          setState(() {
            _top += details.delta.dy;
          });
        },
        child: Container(
          color: Colors.blue,
          height: 56, // Standard AppBar height
          child: const Center(
            child: Text('Draggable AppBar',
                style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
        ),
      ),
    );
  }
}
