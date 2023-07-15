// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class InfoBar extends StatelessWidget {
  const InfoBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Top info bar",
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}
