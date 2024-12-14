import 'package:flutter/material.dart';


class AddButton extends StatelessWidget {
  final VoidCallback onPressed; // Callback for button action
  final IconData icon; // Icon to display in the button

  const AddButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.add, // Default icon is "+"
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      
      onPressed: onPressed,
      backgroundColor: const Color(0xFF133E87), // Customize your color
      child: Icon(
        icon,
        size: 30, // Icon size
        color: Colors.white, // Icon color
      ),
    );
  }
}
