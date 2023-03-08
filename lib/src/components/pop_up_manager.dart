import 'package:flutter/cupertino.dart';

class ZegoPopUpManager {
  final List<int> _popupSheetKeys = [];

  void addAPopUpSheet(int key) {
    _popupSheetKeys.add(key);
  }

  void removeAPopUpSheet(int key) {
    _popupSheetKeys.remove(key);
  }

  void autoPop(BuildContext context) {
    for (final _ in _popupSheetKeys) {
      Navigator.of(context).pop();
    }

    _popupSheetKeys.clear();
  }
}
