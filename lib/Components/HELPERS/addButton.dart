import 'package:flutter/material.dart';

class CustomFloatingButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;

  const CustomFloatingButton({
    Key? key,
    required this.onTap, 
    this.color = Colors.orange, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        height: 80.0,
        width: 80.0,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle, 
        ),
        child: Center(
          child: Icon(
            Icons.add,
            size: 40,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
