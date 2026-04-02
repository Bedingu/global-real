import '../../services/private/private_simulation_engine.dart';
import '../../models/private/private_simulation_input.dart';
import '../../models/private/private_simulation_result.dart';

class PrivateController {
  PrivateSimulationResult simulate(
      PrivateSimulationInput input,
      ) {
    return PrivateSimulationEngine.run(input);
  }
}
