import 'package:flutter/widgets.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to delete this note',
    optionsBuilder: () =>{
      'Cancel' : false,
      'Delete' : true
    },
  ).then((value)=> value ?? false);
}
