import 'package:autosense_ai/features/scanner/data/elm_protocol.dart';

abstract interface class NetworkElmLink implements ElmLink {
  Future<void> close();
}
