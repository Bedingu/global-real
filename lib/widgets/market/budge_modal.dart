import 'package:flutter/material.dart';
import '../../models/budget_filter.dart';

class BudgetModal extends StatefulWidget {
  final BudgetFilter? initial;
  final void Function(BudgetFilter) onApply;

  const BudgetModal({
    super.key,
    required this.initial,
    required this.onApply,
  });

  @override
  State<BudgetModal> createState() => _BudgetModalState();
}

class _BudgetModalState extends State<BudgetModal> {
  final _capexCtrl = TextEditingController();
  final _priceM2Ctrl = TextEditingController();
  final _adrCtrl = TextEditingController();
  final _yieldCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final b = widget.initial;
    _capexCtrl.text = b?.maxCapex?.toString() ?? "";
    _priceM2Ctrl.text = b?.maxPricePerM2?.toString() ?? "";
    _adrCtrl.text = b?.minADR?.toString() ?? "";
    _yieldCtrl.text = b?.minYield?.toString() ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Wrap(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text("Budget & Retorno", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _field("Ticket Máximo (CAPEX)", _capexCtrl, "R\$"),
          _field("Preço /m² Máximo", _priceM2Ctrl, "R\$"),
          _field("ADR Mínimo", _adrCtrl, "R\$"),
          _field("Yield Mínimo", _yieldCtrl, "%"),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(BudgetFilter(
                  maxCapex: double.tryParse(_capexCtrl.text),
                  maxPricePerM2: double.tryParse(_priceM2Ctrl.text),
                  minADR: double.tryParse(_adrCtrl.text),
                  minYield: double.tryParse(_yieldCtrl.text),
                ));
              },
              child: const Text("Aplicar"),
            ),
          )
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctr, String suffix) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: ctr,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
