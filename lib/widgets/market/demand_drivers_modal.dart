import 'package:flutter/material.dart';

class DemandDriversModal extends StatefulWidget {
  final List<String> initial;
  final void Function(List<String>) onApply;

  const DemandDriversModal({
    super.key,
    required this.initial,
    required this.onApply,
  });

  @override
  State<DemandDriversModal> createState() => _DemandDriversModalState();
}

class _DemandDriversModalState extends State<DemandDriversModal> {
  late List<String> _selected;

  final List<String> drivers = [
    "coastal", "mountains", "ski", "airport", "university"
  ];

  @override
  void initState() {
    super.initState();
    _selected = [...widget.initial];
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text("Demand Drivers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...drivers.map((d) => CheckboxListTile(
          title: Text(d),
          value: _selected.contains(d),
          onChanged: (v) {
            setState(() {
              v! ? _selected.add(d) : _selected.remove(d);
            });
          },
        )),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => widget.onApply(_selected),
            child: const Text("Aplicar"),
          ),
        )
      ],
    );
  }
}
