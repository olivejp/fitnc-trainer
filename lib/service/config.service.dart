
import 'package:fitness_domain/constants.dart';
import 'package:get/get.dart';

class ConfigService extends GetxService {
  final Map<String, dynamic> mapConfig = {};

  dynamic get(String key) {
    return mapConfig[key];
  }

  @override
  void onInit() {
    super.onInit();
    mapConfig.putIfAbsent(
      FitnessConstants.profileCommandLineArgument,
      () => const String.fromEnvironment(
          FitnessConstants.profileCommandLineArgument),
    );
  }
}
