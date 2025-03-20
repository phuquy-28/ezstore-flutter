import 'package:flutter/material.dart';

abstract class ActionSheet<T> extends StatelessWidget {
  final T item;

  const ActionSheet({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          buildEditTile(context),
          buildDeleteTile(context),
        ],
      ),
    );
  }

  ListTile buildEditTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.edit),
      title: const Text('Sửa'),
      onTap: () {
        Navigator.pop(context);
        onEdit(context);
      },
    );
  }

  ListTile buildDeleteTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.delete, color: Colors.red),
      title: const Text('Xóa', style: TextStyle(color: Colors.red)),
      onTap: () {
        Navigator.pop(context);
        _showDeleteConfirmation(context);
      },
    );
  }

  void onEdit(BuildContext context);

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: buildDeleteConfirmationContent(),
        actions: buildDeleteConfirmationActions(context),
      ),
    );
  }

  Widget buildDeleteConfirmationContent();

  List<Widget> buildDeleteConfirmationActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Không'),
      ),
      TextButton(
        onPressed: () async {
          Navigator.pop(context);
          await onDelete(context);
        },
        child: Text(
          'Có',
          style: TextStyle(color: Colors.red[700]),
        ),
      ),
    ];
  }

  Future<void> onDelete(BuildContext context);
}
