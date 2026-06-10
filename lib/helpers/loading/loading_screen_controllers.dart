import 'package:flutter/cupertino.dart';

typedef CloseLoadingScreen = bool Function();
typedef UpdateLoadingScreen = bool Function(String text);

@immutable
class LoadingScreenControllers {
  final CloseLoadingScreen close;
  final UpdateLoadingScreen update;

  const LoadingScreenControllers({
    required this.close,
    required this.update,
  });
}