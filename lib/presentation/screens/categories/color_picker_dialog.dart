import 'package:flutter/material.dart';

class ColorPickerDialog extends StatelessWidget {
  final Color selected;

  const ColorPickerDialog({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.brown,
      Colors.grey,
    ];

    return AlertDialog(
      title: const Text('Select color'),
      content: Wrap(
        spacing: 12,
        children: colors
            .map(
              (color) => GestureDetector(
            onTap: () => Navigator.pop(context, color),
            child: CircleAvatar(backgroundColor: color),
          ),
        )
            .toList(),
      ),
    );
  }
}
