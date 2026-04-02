import 'package:flutter/material.dart';
import '../../../models/private/FII_IPO.dart';
import '../../../services/private/IPO_FII_Repository.dart';
import '../../../services/private/FII/fii_scoring_service.dart';

class IPOPage extends StatefulWidget {
  const IPOPage({super.key});

  @override
  State<IPOPage> createState() => _IPOPageState();
}

class _IPOPageState extends State<IPOPage> {
  final FiiRepository _repository = FiiRepository();
  final FiiScoringService _scoringService = FiiScoringService();

  List<FiiModel> fiis = [];
  bool isLoading = true;

  FiiType selectedType = FiiType.tijolo;
  String selectedSegment = "Todos";

  final Map<FiiType, List<String>> segmentsByType = {
    FiiType.tijolo: ["Todos", "Logística", "Lajes", "Shoppings", "Residencial"],
    FiiType.papel: ["Todos", "High Yield", "High Grade", "IPCA", "CDI"],
    FiiType.multiclasse: ["Todos"],
    FiiType.fof: ["Todos"],
  };

  @override
  void initState() {
    super.initState();
    _loadFiis();
  }

  Future<void> _loadFiis() async {
    final result = await _repository.fetchFiis();
    setState(() {
      fiis = result;
      isLoading = false;
    });
  }

  List<FiiModel> get filteredFiis {
    final filtered = fiis.where((fii) {
      final matchesType = fii.type == selectedType;
      final matchesSegment =
          selectedSegment == "Todos" ? true : fii.segment == selectedSegment;
      return matchesType && matchesSegment;
    }).toList();
    return _scoringService.rankFiis(filtered);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B1220),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "FIIs - Inteligência Private",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
                DropdownButton<FiiType>(
                  value: selectedType,
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white),
                  items: FiiType.values
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.name.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                      selectedSegment = "Todos";
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: DropdownButton<String>(
                value: selectedSegment,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                items: segmentsByType[selectedType]!
                    .map((segment) => DropdownMenuItem(
                          value: segment,
                          child: Text(segment),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSegment = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredFiis.length,
                      itemBuilder: (context, index) {
                        final fii = filteredFiis[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(fii.ticker,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  Text(fii.name,
                                      style: const TextStyle(color: Colors.white70)),
                                  Text(fii.segment,
                                      style: const TextStyle(
                                          color: Colors.amber, fontSize: 12)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("R\$ ${fii.price}",
                                      style: const TextStyle(
                                          color: Colors.greenAccent,
                                          fontWeight: FontWeight.bold)),
                                  Text("DY ${fii.dividendYield}%",
                                      style: const TextStyle(color: Colors.white70)),
                                  const SizedBox(height: 4),
                                  Text(
                                      "Score ${(fii.privateScore ?? 0).toStringAsFixed(2)}",
                                      style: const TextStyle(
                                          color: Colors.cyanAccent,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
  }
}
