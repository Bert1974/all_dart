import 'package:flutter/material.dart';

Future<T?> showDialogPopup<T>(
    {required BuildContext context,
    Function(BuildContext context)? onBack,
    Function(BuildContext context)? onClose,
    required String title,
    required Widget child}) {
  return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext innerContext) {
        return _DialogPopup(
            context: context,
            title: title,
            onBack: onBack,
            onClose: onClose,
            child: child);
      });
}

class _DialogPopup extends StatelessWidget {
  final Function(BuildContext context)? onBack;
  final Function(BuildContext context)? onClose;
  final String title;
  final Widget child;
  final BuildContext context;

  const _DialogPopup(
      {required this.title,
      this.onBack,
      this.onClose,
      required this.context,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
           contentPadding: const EdgeInsets.all(10),
        //   title: const Text('test'),
        //  child: Column(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
            mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (onBack != null)
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onBack!(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (onClose != null) {
                        onClose!(context);
                      }
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.red,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              child,
            ],
          ),
        ]);
  }
}
