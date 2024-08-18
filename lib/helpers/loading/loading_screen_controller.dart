import 'package:flutter/foundation.dart' show immutable;

typedef CloseLoadingScreen = bool Function();
typedef UpdaeLoadingScreen = bool Function(String text);

@immutable
class LoadingScreenController{
  final CloseLoadingScreen close;
  final UpdaeLoadingScreen update;

  const LoadingScreenController({required this.close, required this.update});
}