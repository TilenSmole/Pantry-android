import 'package:flutter/material.dart';
import '../HELPERS/colors.dart';

// Custom TextFormField widget
class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;

  const CustomTextFormField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical:2, horizontal: 20), 
      child: Row(
        children: [      
          SizedBox(
            width: 180,
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: C.orange),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
          SizedBox(
              width: 10), 
              
          labelText == "item fname" ? SizedBox()  :
          Text(
            labelText,
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),


        ],
      ),
    );
  }
}
