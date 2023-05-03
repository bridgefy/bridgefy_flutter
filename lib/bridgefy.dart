
import 'bridgefy_platform_interface.dart';

class Bridgefy {
  Future<String?> getPlatformVersion() {
    return BridgefyPlatform.instance.getPlatformVersion();
  }
}
