import 'package:flutter/material.dart';

class AmenitiesModal extends StatefulWidget {
  final Map<String, bool>? initial;
  final void Function(Map<String, bool>) onApply;

  const AmenitiesModal({super.key, this.initial, required this.onApply});

  @override
  State<AmenitiesModal> createState() => _AmenitiesModalState();
}

class _AmenitiesModalState extends State<AmenitiesModal> {
  late Map<String, bool> _state;

  @override
  void initState() {
    super.initState();
    _state = {...(widget.initial ?? {})};
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text("Comodidades", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),

        ..._state.keys.map((k) => SwitchListTile(
          title: Text(k.replaceAll("_", " ").toUpperCase()),
          value: _state[k]!,
          onChanged: (v) => setState(() => _state[k] = v),
        )),

        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => widget.onApply(_state),
            child: const Text("Aplicar"),
          ),
        )
      ],
    );
  }
}
