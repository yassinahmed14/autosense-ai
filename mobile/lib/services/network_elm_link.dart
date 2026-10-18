import 'elm_protocol.dart';

abstract interface class NetworkElmLink implements ElmLink {
  Future<void> close();
}
