import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/market_filter.dart';
import '../../generated/app_localizations.dart';
import 'market_capacity_filter_modal.dart';

class MarketFilterPanel extends StatefulWidget {
  final MarketFilter initialFilter;
  final ValueChanged<MarketFilter> onApply;

  const MarketFilterPanel({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  @override
  State<MarketFilterPanel> createState() => _MarketFilterPanelState();
}

class _MarketFilterPanelState extends State<MarketFilterPanel> {
  static const double _minAllowed = 10;
  static const double _maxAllowed = 100000;

  late MarketFilter _filter;

  late double minListings;
  late double maxListings;
  late Set<DemandDriver> selectedDrivers;

  late RangeValues marketScore;
  late RangeValues revenueGrowth;
  late RangeValues rentalDemand;
  late RangeValues seasonality;
  late RangeValues regulation;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    minListings = _filter.minListings.clamp(_minAllowed, _maxAllowed);
    maxListings = _filter.maxListings.clamp(minListings, _maxAllowed);
    selectedDrivers = {..._filter.demandDrivers};
    marketScore = RangeValues(_filter.marketScoreMin, _filter.marketScoreMax);
    revenueGrowth = RangeValues(_filter.revenueGrowthMin, _filter.revenueGrowthMax);
    rentalDemand = RangeValues(_filter.rentalDemandMin, _filter.rentalDemandMax);
    seasonality = RangeValues(_filter.seasonalityMin, _filter.seasonalityMax);
    regulation = RangeValues(_filter.regulationMin, _filter.regulationMax);
  }

  Future<void> _openCapacityFilter() async {
    final result = await showModalBottomSheet<MarketFilter>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => MarketCapacityFilterModal(initialFilter: _filter),
    );
    if (result != null && mounted) {
      setState(() => _filter = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.filter_title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),

              ListTile(
                title: Text(t.filter_capacity),
                subtitle: Text(_capacitySummary(_filter, t)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _openCapacityFilter,
              ),

              const Divider(height: 40),

              Text(
                t.filter_bathrooms,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _bathroomSelectors(t),

              const Divider(height: 40),

              Text(
                t.filter_listing_count,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              _listingRangeLabel(),
              _listingRange(),

              const Divider(height: 40),

              Text(
                t.filter_demand_drivers,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _demandDriversGrid(t),

              const SizedBox(height: 32),

              Row(
                children: [
                  TextButton(
                    onPressed: _reset,
                    child: Text(t.filter_reset),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _applyFilters,
                    child: Text(t.filter_apply),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================
  // WIDGETS AUXILIARES
  // ===============================

  Widget _bathroomSelectors(AppLocalizations t) {
    return Row(
      children: [
        Expanded(child: _bathroomDropdown(t.filter_min, true)),
        const SizedBox(width: 12),
        Expanded(child: _bathroomDropdown(t.filter_max, false)),
      ],
    );
  }

  Widget _bathroomDropdown(String label, bool isMin) {
    return DropdownButtonFormField<int>(
      initialValue: _getSafeBathroomValue(
        isMin ? _filter.minBathrooms : _filter.maxBathrooms,
      ),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: List.generate(
        7,
        (i) => DropdownMenuItem(value: i, child: Text('$i')),
      ),
      onChanged: (v) {
        final value = v ?? 0;
        setState(() {
          _filter = _filter.copyWith(
            minBathrooms: isMin ? value : _filter.minBathrooms,
            maxBathrooms: isMin ? _filter.maxBathrooms : value,
          );
        });
      },
    );
  }

  Widget _listingRangeLabel() {
    final minLabel = minListings.toInt().toString();
    final maxLabel = maxListings >= _maxAllowed ? '100k+' : maxListings.toInt().toString();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(minLabel, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          Text(maxLabel, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _listingRange() {
    return RangeSlider(
      min: _minAllowed,
      max: _maxAllowed,
      values: RangeValues(minListings, maxListings),
      labels: RangeLabels(
        minListings.toInt().toString(),
        maxListings >= _maxAllowed ? '100k+' : maxListings.toInt().toString(),
      ),
      onChanged: (v) {
        setState(() {
          minListings = v.start;
          maxListings = v.end;
        });
      },
    );
  }

  String _driverLabel(DemandDriver driver, AppLocalizations t) {
    switch (driver) {
      case DemandDriver.airport: return t.driver_airport;
      case DemandDriver.arts: return t.driver_arts;
      case DemandDriver.coastal: return t.driver_coastal;
      case DemandDriver.golf: return t.driver_golf;
      case DemandDriver.lake: return t.driver_lake;
      case DemandDriver.military: return t.driver_military;
      case DemandDriver.mountains: return t.driver_mountains;
      case DemandDriver.nationalPark: return t.driver_national_park;
      case DemandDriver.ski: return t.driver_ski;
      case DemandDriver.university: return t.driver_university;
      case DemandDriver.winery: return t.driver_winery;
    }
  }

  Widget _demandDriversGrid(AppLocalizations t) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: demandDriversList.length,
      itemBuilder: (context, index) {
        final item = demandDriversList[index];
        final isSelected = selectedDrivers.contains(item.driver);
        final label = _driverLabel(item.driver, t);

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              isSelected
                  ? selectedDrivers.remove(item.driver)
                  : selectedDrivers.add(item.driver);
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (_) {
                    setState(() {
                      isSelected
                          ? selectedDrivers.remove(item.driver)
                          : selectedDrivers.add(item.driver);
                    });
                  },
                ),
                SvgPicture.asset(item.iconPath, width: 18, height: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(label)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===============================
  // UTILS
  // ===============================

  int _getSafeBathroomValue(int v) {
    final valid = List.generate(7, (i) => i);
    return valid.contains(v) ? v : valid.first;
  }

  void _applyFilters() {
    widget.onApply(
      _filter.copyWith(
        minListings: minListings,
        maxListings: maxListings,
        demandDrivers: selectedDrivers,
        marketScoreMin: marketScore.start,
        marketScoreMax: marketScore.end,
        revenueGrowthMin: revenueGrowth.start,
        revenueGrowthMax: revenueGrowth.end,
        rentalDemandMin: rentalDemand.start,
        rentalDemandMax: rentalDemand.end,
        seasonalityMin: seasonality.start,
        seasonalityMax: seasonality.end,
        regulationMin: regulation.start,
        regulationMax: regulation.end,
      ),
    );
    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _filter = const MarketFilter();
      minListings = _minAllowed;
      maxListings = _maxAllowed;
      selectedDrivers.clear();
      marketScore = const RangeValues(0, 100);
      revenueGrowth = const RangeValues(0, 100);
      rentalDemand = const RangeValues(0, 100);
      seasonality = const RangeValues(0, 100);
      regulation = const RangeValues(0, 100);
    });
  }

  String _capacitySummary(MarketFilter f, AppLocalizations t) {
    final parts = <String>[];
    if (f.maxBedrooms < 10) parts.add('${f.maxBedrooms} quartos');
    if (f.maxBathrooms < 6) parts.add('${f.maxBathrooms} banheiros');
    if (f.maxGuests < 20) parts.add('${f.maxGuests} hóspedes');
    return parts.isEmpty ? t.filter_capacity_any : parts.join(' • ');
  }
}

// ===============================
// DEMAND DRIVER CONFIG
// ===============================

class DemandDriverItem {
  final DemandDriver driver;
  final String iconPath;

  const DemandDriverItem(this.driver, this.iconPath);
}

const demandDriversList = [
  DemandDriverItem(DemandDriver.airport, 'assets/icons/demand_drivers/airport.svg'),
  DemandDriverItem(DemandDriver.arts, 'assets/icons/demand_drivers/arts.svg'),
  DemandDriverItem(DemandDriver.coastal, 'assets/icons/demand_drivers/coastal.svg'),
  DemandDriverItem(DemandDriver.golf, 'assets/icons/demand_drivers/golf.svg'),
  DemandDriverItem(DemandDriver.lake, 'assets/icons/demand_drivers/lake.svg'),
  DemandDriverItem(DemandDriver.military, 'assets/icons/demand_drivers/military.svg'),
  DemandDriverItem(DemandDriver.mountains, 'assets/icons/demand_drivers/mountains.svg'),
  DemandDriverItem(DemandDriver.nationalPark, 'assets/icons/demand_drivers/national_park.svg'),
  DemandDriverItem(DemandDriver.ski, 'assets/icons/demand_drivers/ski.svg'),
  DemandDriverItem(DemandDriver.university, 'assets/icons/demand_drivers/university.svg'),
  DemandDriverItem(DemandDriver.winery, 'assets/icons/demand_drivers/winery.svg'),
];
