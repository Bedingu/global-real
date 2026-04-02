import 'package:flutter/material.dart';

// MODELS
import '../../models/market_filter.dart';

// MODALS / WIDGETS
import '../market/market_filter_panel.dart';
import '../market/market_capacity_filter_modal.dart';
import '../market/market_proximity_filter.dart';
import '../market/amenities_modal.dart';
import '../market/demand_drivers_modal.dart';

// L10N
import '../../generated/app_localizations.dart';

class AllFiltersPanel extends StatefulWidget {
  final MarketFilter filter;
  final void Function(MarketFilter) onApply;
  final VoidCallback onClose;

  const AllFiltersPanel({
    super.key,
    required this.filter,
    required this.onApply,
    required this.onClose,
  });

  @override
  State<AllFiltersPanel> createState() => _AllFiltersPanelState();
}

class _AllFiltersPanelState extends State<AllFiltersPanel> {
  late MarketFilter _localFilter;

  @override
  void initState() {
    super.initState();
    _localFilter = widget.filter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          _buildBody(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(t.all_filters,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onClose,
          )
        ],
      ),
    );
  }

  Widget _buildBody() {
    final t = AppLocalizations.of(context)!;
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(t.all_filters_developments, Icons.business, _openMarketFilter),
          _section(t.all_filters_capacity, Icons.bed_outlined, _openCapacityFilter),
          _section(t.all_filters_proximity, Icons.subway_outlined, _openProximityFilter),
          _section(t.all_filters_amenities, Icons.pool_outlined, _openAmenitiesFilter),
          _section(t.all_filters_demand_drivers, Icons.trending_up, _openDemandDriversFilter),
          _section(t.filter_property_type, Icons.apartment_outlined, _openPropertyTypeFilter),
          _section(t.filter_delivery_date, Icons.calendar_month_outlined, _openDeliveryDateFilter),
          _section(t.filter_price_range, Icons.price_change_outlined, _openPriceRangeFilter),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          TextButton(
            onPressed: () => setState(() => _localFilter = const MarketFilter()),
            child: Text(t.all_filters_reset),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              widget.onApply(_localFilter);
              widget.onClose();
            },
            child: Text(t.all_filters_apply),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.grey.shade100,
        leading: Icon(icon, size: 22),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  // ===============================
  // EMPREENDIMENTOS
  // ===============================
  void _openMarketFilter() async {
    final result = await showModalBottomSheet<MarketFilter>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MarketFilterPanel(
        initialFilter: _localFilter,
        onApply: (f) => Navigator.pop(context, f),
      ),
    );
    if (result != null && mounted) {
      setState(() => _localFilter = result);
    }
  }

  // ===============================
  // CAPACIDADE
  // ===============================
  void _openCapacityFilter() async {
    final result = await showModalBottomSheet<MarketFilter>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MarketCapacityFilterModal(initialFilter: _localFilter),
    );
    if (result != null && mounted) {
      setState(() => _localFilter = result);
    }
  }

  // ===============================
  // PROXIMIDADE
  // ===============================
  void _openProximityFilter() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        final t = AppLocalizations.of(context)!;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.all_filters_proximity,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              MarketProximityFilter(
                value: _localFilter.proximity,
                onChanged: (prox) {
                  setState(() {
                    _localFilter = _localFilter.copyWithProximity(prox);
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ===============================
  // AMENITIES
  // ===============================
  void _openAmenitiesFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AmenitiesModal(
        initial: _localFilter.amenities,
        onApply: (amenities) {
          setState(() {
            _localFilter = _localFilter.copyWith(amenities: amenities);
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  // ===============================
  // DEMAND DRIVERS
  // ===============================
  void _openDemandDriversFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DemandDriversModal(
        initial: _localFilter.demandDriversAsString,
        onApply: (drivers) {
          setState(() {
            _localFilter = _localFilter.copyWith(
              demandDrivers: drivers
                  .map((e) => DemandDriver.values.byName(e))
                  .toSet(),
            );
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  // ===============================
  // PROPERTY TYPE
  // ===============================
  void _openPropertyTypeFilter() {
    final t = AppLocalizations.of(context)!;

    final allTypes = {
      'Apartamento': t.property_type_apartment,
      'Studio': t.property_type_studio,
      'Casa': t.property_type_house,
      'Comercial': t.property_type_commercial,
      'Terreno': t.property_type_land,
      'Flat': t.property_type_flat,
    };

    final selected = Set<String>.from(_localFilter.propertyTypes);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Wrap(
            children: [
              Text(t.filter_property_type,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12, width: double.infinity),
              ...allTypes.entries.map((e) {
                return CheckboxListTile(
                  title: Text(e.value),
                  value: selected.contains(e.key),
                  onChanged: (v) {
                    setModal(() {
                      v == true ? selected.add(e.key) : selected.remove(e.key);
                    });
                  },
                );
              }),
              Row(
                children: [
                  TextButton(
                    onPressed: () => setModal(() => selected.clear()),
                    child: Text(t.filter_reset),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _localFilter = _localFilter.copyWith(
                          propertyTypes: Set<String>.from(selected),
                        );
                      });
                      Navigator.pop(context);
                    },
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
  // DELIVERY DATE
  // ===============================
  void _openDeliveryDateFilter() {
    final t = AppLocalizations.of(context)!;

    String? fromDate = _localFilter.deliveryDateStart;
    String? toDate = _localFilter.deliveryDateEnd;

    final now = DateTime.now();
    final options = <String>[];
    for (int y = now.year; y <= now.year + 5; y++) {
      for (final q in ['Q1', 'Q2', 'Q3', 'Q4']) {
        options.add('$q $y');
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Wrap(
            children: [
              Text(t.filter_delivery_date,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16, width: double.infinity),
              DropdownButtonFormField<String>(
                initialValue: fromDate,
                decoration: InputDecoration(labelText: t.delivery_from),
                items: [
                  const DropdownMenuItem(value: null, child: Text('—')),
                  ...options.map((o) => DropdownMenuItem(value: o, child: Text(o))),
                ],
                onChanged: (v) => setModal(() => fromDate = v),
              ),
              const SizedBox(height: 12, width: double.infinity),
              DropdownButtonFormField<String>(
                initialValue: toDate,
                decoration: InputDecoration(labelText: t.delivery_to),
                items: [
                  const DropdownMenuItem(value: null, child: Text('—')),
                  ...options.map((o) => DropdownMenuItem(value: o, child: Text(o))),
                ],
                onChanged: (v) => setModal(() => toDate = v),
              ),
              const SizedBox(height: 16, width: double.infinity),
              Row(
                children: [
                  TextButton(
                    onPressed: () => setModal(() {
                      fromDate = null;
                      toDate = null;
                    }),
                    child: Text(t.filter_reset),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _localFilter = _localFilter.copyWith(
                          deliveryDateStart: fromDate,
                          deliveryDateEnd: toDate,
                        );
                      });
                      Navigator.pop(context);
                    },
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
  // PRICE RANGE
  // ===============================
  void _openPriceRangeFilter() {
    final t = AppLocalizations.of(context)!;

    final minCtrl = TextEditingController(
      text: _localFilter.minPrice?.toString() ?? '',
    );
    final maxCtrl = TextEditingController(
      text: _localFilter.maxPrice?.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Wrap(
          children: [
            Text(t.filter_price_range,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12, width: double.infinity),
            TextField(
              controller: minCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: t.price_min),
            ),
            const SizedBox(height: 8, width: double.infinity),
            TextField(
              controller: maxCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: t.price_max),
            ),
            const SizedBox(height: 16, width: double.infinity),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    minCtrl.clear();
                    maxCtrl.clear();
                  },
                  child: Text(t.filter_reset),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _localFilter = _localFilter.copyWith(
                        minPrice: double.tryParse(minCtrl.text),
                        maxPrice: double.tryParse(maxCtrl.text),
                      );
                    });
                    Navigator.pop(context);
                  },
                  child: Text(t.filter_apply),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
