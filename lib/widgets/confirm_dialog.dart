import 'package:flutter/material.dart';

Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onConfirm,
  String confirmLabel = '확인',
  String cancelLabel = '취소',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm();
          },
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}
