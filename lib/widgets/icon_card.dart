import 'package:flutter/material.dart';

class IconCard extends StatelessWidget {
  const IconCard({
    Key? key,
    required this.icon,
    required this.label,
    this.onTapHandler,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final void Function()? onTapHandler;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTapHandler,
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xffB8AAA3),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColorDark,
                blurRadius: 6,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Color(0xff6D5D54),
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.headline2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
