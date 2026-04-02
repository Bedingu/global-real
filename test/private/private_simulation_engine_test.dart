import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:global_real/models/private/private_simulation_input.dart';
import 'package:global_real/services/private/private_simulation_engine.dart';

void main() {
  test(
    'PrivateSimulationEngine — valida todos os empreendimentos do Excel',
        () async {
      final file =
      File('test/private/fixtures/private_simulations.json');

      expect(
        await file.exists(),
        true,
        reason: 'Arquivo de fixtures não encontrado',
      );

      final jsonString = await file.readAsString();
      final List<dynamic> cases = jsonDecode(jsonString);

      for (final c in cases) {
        final name = c['name'] as String;

        final inputJson = c['input'];
        final expected = c['expected'];

        final input = PrivateSimulationInput(
          initialInvestment:
          (inputJson['initialInvestment'] as num).toDouble(),
          exitValue:
          (inputJson['exitValue'] as num).toDouble(),
          monthlyRevenue:
          (inputJson['monthlyRevenue'] as num).toDouble(),
          monthlyCosts:
          (inputJson['monthlyCosts'] as num).toDouble(),
          revenueGrowthRateMonthly:
          (inputJson['revenueGrowthRateMonthly'] as num)
              .toDouble(),
          costGrowthRateMonthly:
          (inputJson['costGrowthRateMonthly'] as num)
              .toDouble(),
          durationMonths:
          inputJson['durationMonths'] as int,
          discountRateMonthly:
          (inputJson['discountRateMonthly'] as num)
              .toDouble(),
        );

        final result = PrivateSimulationEngine.run(input);

        // =============================
        // IRR ANUAL
        // =============================
        expect(
          result.irrAnnual,
          closeTo(expected['irrAnnual'], 0.05),
          reason: 'IRR anual divergente em $name',
        );

        // =============================
        // ROI
        // =============================
        expect(
          result.roi,
          closeTo(expected['roi'], 0.01),
          reason: 'ROI divergente em $name',
        );

        // =============================
        // PAYBACK
        // =============================
        expect(
          result.paybackMonths,
          expected['paybackMonths'],
          reason: 'Payback divergente em $name',
        );

        // =============================
        // SANITY CHECKS
        // =============================
        expect(result.totalInvested, greaterThan(0),
            reason: 'Total investido inválido em $name');

        expect(result.totalReturn, greaterThan(0),
            reason: 'Total retorno inválido em $name');

        expect(result.monthlyCashFlows.isNotEmpty, true,
            reason: 'Cashflow vazio em $name');
      }
    },
  );
}
