import 'package:flutter/material.dart';

class DecoratedWrapper extends StatelessWidget {
  const DecoratedWrapper({
    Key? key,
    this.child,
  }) : super(key: key);

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // BoxShadow(
          //   color: Colors.black.withOpacity(0.8),
          //   blurRadius: 12,
          //   spreadRadius: 0.5,
          //   offset: Offset(0.7, 0.7),
          // ),
          BoxShadow(
            color: Theme.of(context).primaryColorDark,
            blurRadius: 6,
            spreadRadius: 0.5,
            offset: Offset(0.7, 0.7),
          ),
        ],
      ),
      child: child,
    );
  }
}
