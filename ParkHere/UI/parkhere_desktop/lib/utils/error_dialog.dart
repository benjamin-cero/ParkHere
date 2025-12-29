import 'package:flutter/material.dart';
import 'package:parkhere_desktop/utils/base_dialog.dart';

void ErrorDialog(BuildContext context, String? tekst) {
  BaseDialog.show(
    context: context,
    title: 'Error',
    message: tekst ?? 'An unexpected error occurred.',
    type: BaseDialogType.error,
  );
}