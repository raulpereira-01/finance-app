// Pantalla para crear, editar y eliminar categorías con selector de color y emoji.
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/hive_boxes.dart';
import '../../../data/models/category_model.dart';
import 'color_picker_dialog.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _nameController = TextEditingController();
  final _uuid = const Uuid();

  String _selectedEmoji = '💸';
  Color _selectedColor = Colors.blue;

  late Box<CategoryModel> _categoryBox;

  @override
  void initState() {
    super.initState();
    _categoryBox = Hive.box<CategoryModel>(HiveBoxes.categories);
  }

  void _addCategory() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final category = CategoryModel(
      id: _uuid.v4(),
      name: name,
      emoji: _selectedEmoji,
      colorValue: _selectedColor.value,
    );

    _categoryBox.put(category.id, category);
    _nameController.clear();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categoryBox.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Category name'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                DropdownButton<String>(
                  value: _selectedEmoji,
                  items: const ['💸', '🏠', '🚗', '🍔', '📱', '🎮', '🎓']
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: const TextStyle(fontSize: 20)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedEmoji = value);
                    }
                  },
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () async {
                    final color = await showDialog<Color>(
                      context: context,
                      builder: (_) =>
                          ColorPickerDialog(selected: _selectedColor),
                    );
                    if (color != null) {
                      setState(() => _selectedColor = color);
                    }
                  },
                  child: CircleAvatar(backgroundColor: _selectedColor),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _addCategory,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(category.colorValue),
                      child: Text(category.emoji),
                    ),
                    title: Text(category.name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
