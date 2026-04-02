import 'package:flutter/material.dart';
import '../../models/market_filter.dart';
import '../../generated/app_localizations.dart';

class MarketCapacityFilterModal extends StatefulWidget {
  final MarketFilter initialFilter;

  const MarketCapacityFilterModal({
    super.key,
    required this.initialFilter,
  });

  @override
  State<MarketCapacityFilterModal> createState() =>
      _MarketCapacityFilterModalState();
}

class _MarketCapacityFilterModalState
    extends State<MarketCapacityFilterModal> {
  late RangeValues bedrooms;
  late RangeValues bathrooms;
  late RangeValues guests;

  @override
  void initState() {
    super.initState();
    bedrooms = RangeValues(
      widget.initialFilter.minBedrooms.toDouble(),
      widget.initialFilter.maxBedrooms.toDouble().clamp(0, 10),
    );
    bathrooms = RangeValues(
      widget.initialFilter.minBathrooms.toDouble().clamp(1, 6),
      widget.initialFilter.maxBathrooms.toDouble().clamp(1, 6),
    );
    guests = RangeValues(
      widget.initialFilter.minGuests.toDouble(),
      widget.initialFilter.maxGuests.toDouble().clamp(1, 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section(
              title: t.capacity_bedrooms,
              values: bedrooms,
              min: 0,
              max: 10,
              onChanged: (v) => setState(() => bedrooms = v),
              label: (v) => v >= 10
                  ? t.capacity_bedrooms_plus
                  : '${v.toInt()} ${t.capacity_bedrooms.toLowerCase()}',
            ),
            const SizedBox(height: 28),
            _section(
              title: t.capacity_baths,
              values: bathrooms,
              min: 1,
              max: 6,
              onChanged: (v) => setState(() => bathrooms = v),
              label: (v) => v >= 6
                  ? t.capacity_baths_plus
                  : '${v.toInt()} ${t.capacity_baths.toLowerCase()}',
            ),
            const SizedBox(height: 28),
            _section(
              title: t.capacity_guests,
              values: guests,
              min: 1,
              max: 20,
              onChanged: (v) => setState(() => guests = v),
              label: (v) => v >= 20
                  ? t.capacity_guests_plus
                  : '${v.toInt()}',
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                TextButton(
                  onPressed: _reset,
                  child: Text(t.filter_reset),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _apply,
                  child: Text(t.filter_apply),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _reset() {
    setState(() {
      bedrooms = const RangeValues(0, 10);
      bathrooms = const RangeValues(1, 6);
      guests = const RangeValues(1, 20);
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      widget.initialFilter.copyWith(
        minBedrooms: bedrooms.start.toInt(),
        maxBedrooms: bedrooms.end.toInt(),
        minBathrooms: bathrooms.start.toInt(),
        maxBathrooms: bathrooms.end.toInt(),
        minGuests: guests.start.toInt(),
        maxGuests: guests.end.toInt(),
      ),
    );
  }

  Widget _section({
    required String title,
    required RangeValues values,
    required double min,
    required double max,
    required ValueChanged<RangeValues> onChanged,
    required String Function(double) label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        RangeSlider(
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          values: values,
          labels: RangeLabels(label(values.start), label(values.end)),
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _ValueBox(label(values.start))),
            const SizedBox(width: 12),
            const Text('-'),
            const SizedBox(width: 12),
            Expanded(child: _ValueBox(label(values.end))),
          ],
        ),
      ],
    );
  }
}

class _ValueBox extends StatelessWidget {
  final String value;

  const _ValueBox(this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(value, style: const TextStyle(fontSize: 14)),
    );
  }
}
