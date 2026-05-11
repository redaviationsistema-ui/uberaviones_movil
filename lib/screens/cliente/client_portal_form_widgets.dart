part of 'client_portal_sections.dart';

class _PortalPage extends StatelessWidget {
  const _PortalPage({required this.title, required this.body});

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF3EFE6), Color(0xFFEEE7DA), Color(0xFFF7F3EC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: body,
        ),
      ),
    );
  }
}

class _PortalHero extends StatelessWidget {
  const _PortalHero({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.primaryLabel,
    this.helper,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final String? primaryLabel;
  final String? helper;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: const Color(0xFFE8E0D3)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: -2,
            child: Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF7EFDF),
                border: Border.all(color: const Color(0xFFEADBC1)),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 18,
            child: Icon(
              Icons.flight_takeoff_rounded,
              size: 26,
              color: const Color(0xFFC8A770).withValues(alpha: 0.9),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (trailing != null)
                Align(alignment: Alignment.topRight, child: trailing!),
              Text(
                eyebrow,
                style: const TextStyle(
                  color: Color(0xFFB07A1B),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111111),
                  height: 0.98,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 250),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF5F5B53),
                    height: 1.35,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (primaryLabel != null) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF111111),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      primaryLabel!,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
              if (helper != null) ...[
                const SizedBox(height: 8),
                Text(
                  helper!,
                  style: const TextStyle(
                    color: Color(0xFF6B6256),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
class _TagLabel extends StatelessWidget {
  const _TagLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EBD7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF7A5D1F),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MembershipStatusStrip extends StatelessWidget {
  const _MembershipStatusStrip({required this.items});

  final List<_StatusItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F0E6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2D5C1)),
      ),
      child: Row(
        children:
            items
                .asMap()
                .entries
                .map(
                  (entry) => Expanded(
                    child: Text(
                      entry.value.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign:
                          entry.key == 0 ? TextAlign.left : TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}

class _SmartSummaryBar extends StatelessWidget {
  const _SmartSummaryBar({
    required this.routeLabel,
    required this.passengersLabel,
    required this.preferenceLabel,
  });

  final String routeLabel;
  final String passengersLabel;
  final String preferenceLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F0E6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2D5C1)),
      ),
      child: Text(
        '$routeLabel · $passengersLabel · $preferenceLabel',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF111111),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PortalSyncBanner extends StatelessWidget {
  const _PortalSyncBanner({
    required this.provider,
    required this.onRefresh,
  });

  final ReservationProvider provider;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final showBanner =
        provider.isLoadingData ||
        !provider.isOnline ||
        provider.airports.isEmpty ||
        provider.aircraftFleet.isEmpty;

    if (!showBanner) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1E7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              provider.isLoadingData
                  ? const Color(0xFFD9CCB8)
                  : const Color(0xFFE1D2BA),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            provider.isLoadingData
                ? Icons.sync_rounded
                : Icons.cloud_off_rounded,
            size: 18,
            color: const Color(0xFF7A5D1F),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.isLoadingData
                      ? 'Sincronizando datos del portal'
                      : 'Actualizacion pendiente',
                  style: const TextStyle(
                    color: Color(0xFF2F2A20),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  provider.syncMessage ??
                      'Actualiza para consultar la informacion mas reciente del servidor.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6C6355),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: provider.isLoadingData ? null : onRefresh,
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}

class _StatusItem {
  const _StatusItem({required this.label, required this.value});

  final String label;
  final String value;
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.item});

  final _StatusItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCF8F1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7DCCA)),
      ),
      child: Row(
        children: [
          Text(
            item.label,
            style: const TextStyle(
              color: Color(0xFF7C6E5B),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF111111),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormSectionLabel extends StatelessWidget {
  const _FormSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF7A5D1F),
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _TripTypeSelector extends StatelessWidget {
  const _TripTypeSelector({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const values = ['Ida', 'Redondo', 'Multi-destino'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          for (final item in values)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FilledButton(
                  onPressed: () => onChanged(item),
                  style: FilledButton.styleFrom(
                    elevation: 0,
                    backgroundColor:
                        item == value
                            ? const Color(0xFF10161D)
                            : Colors.transparent,
                    foregroundColor:
                        item == value
                            ? const Color(0xFFF8F3E8)
                            : const Color(0xFF111111),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(
                    item == 'Multi-destino' ? 'Multi-\ndestino' : item,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BookingSearchCard extends StatelessWidget {
  const _BookingSearchCard({
    required this.showOnlyStepOne,
    required this.tripType,
    required this.airports,
    required this.origin,
    required this.destination,
    required this.departureDate,
    required this.departureTime,
    required this.returnDate,
    required this.returnTime,
    required this.passengers,
    required this.preference,
    required this.onOriginChanged,
    required this.onDestinationChanged,
    required this.onDepartureDateChanged,
    required this.onDepartureTimeChanged,
    required this.onReturnDateChanged,
    required this.onReturnTimeChanged,
    required this.onPassengersChanged,
    required this.onPreferenceChanged,
  });

  final bool showOnlyStepOne;
  final String tripType;
  final List<Airport> airports;
  final Airport? origin;
  final Airport? destination;
  final DateTime? departureDate;
  final TimeOfDay? departureTime;
  final DateTime? returnDate;
  final TimeOfDay? returnTime;
  final int passengers;
  final String preference;
  final ValueChanged<Airport?> onOriginChanged;
  final ValueChanged<Airport?> onDestinationChanged;
  final ValueChanged<DateTime?> onDepartureDateChanged;
  final ValueChanged<TimeOfDay?> onDepartureTimeChanged;
  final ValueChanged<DateTime?> onReturnDateChanged;
  final ValueChanged<TimeOfDay?> onReturnTimeChanged;
  final ValueChanged<int> onPassengersChanged;
  final ValueChanged<String> onPreferenceChanged;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final routeFields = [
                _AirportDropdownField(
                  label: 'De',
                  icon: Icons.radio_button_checked_rounded,
                  airports: airports,
                  value: origin,
                  onChanged: onOriginChanged,
                ),
                _AirportDropdownField(
                  label: 'A',
                  icon: Icons.flight_land_rounded,
                  airports: airports,
                  value: destination,
                  onChanged: onDestinationChanged,
                ),
              ];

              if (constraints.maxWidth < 760) {
                return Column(
                  children:
                      routeFields
                          .map(
                            (child) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: child,
                            ),
                          )
                          .toList(),
                );
              }

              return Row(
                children:
                    routeFields
                        .asMap()
                        .entries
                        .map(
                          (entry) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right:
                                    entry.key == routeFields.length - 1 ? 0 : 12,
                              ),
                              child: entry.value,
                            ),
                          ),
                        )
                        .toList(),
              );
            },
          ),
          if (!showOnlyStepOne) ...[
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final departureFields = [
                  _DateField(
                    label: 'Fecha',
                    icon: Icons.calendar_month_rounded,
                    value: departureDate,
                    onChanged: onDepartureDateChanged,
                  ),
                  _TimeField(
                    label: 'Hora',
                    icon: Icons.schedule_rounded,
                    value: departureTime,
                    onChanged: onDepartureTimeChanged,
                  ),
                  if (tripType == 'Redondo')
                    _DateField(
                    label: 'Fecha regreso',
                    icon: Icons.event_repeat_rounded,
                    value: returnDate,
                      onChanged: onReturnDateChanged,
                    ),
                  if (tripType == 'Redondo')
                    _TimeField(
                    label: 'Hora regreso',
                    icon: Icons.history_toggle_off_rounded,
                    value: returnTime,
                      onChanged: onReturnTimeChanged,
                    ),
                ];

                if (constraints.maxWidth < 760) {
                  return Column(
                    children:
                        departureFields
                            .map(
                              (child) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: child,
                              ),
                            )
                            .toList(),
                  );
                }

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      departureFields
                          .map((child) => SizedBox(width: 220, child: child))
                          .toList(),
                );
              },
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final cabinFields = [
                  _PassengerField(
                    label: 'Pasajeros',
                    icon: Icons.person_outline_rounded,
                    value: passengers,
                    onChanged: onPassengersChanged,
                  ),
                  _PreferenceField(
                    value: preference,
                    onChanged: onPreferenceChanged,
                  ),
                ];

                if (constraints.maxWidth < 760) {
                  return Column(
                    children:
                        cabinFields
                            .map(
                              (child) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: child,
                              ),
                            )
                            .toList(),
                  );
                }

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      cabinFields
                          .map((child) => SizedBox(width: 220, child: child))
                          .toList(),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _AirportDropdownField extends StatefulWidget {
  const _AirportDropdownField({
    required this.label,
    required this.icon,
    required this.airports,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final List<Airport> airports;
  final Airport? value;
  final ValueChanged<Airport?> onChanged;

  @override
  State<_AirportDropdownField> createState() => _AirportDropdownFieldState();
}

class _AirportDropdownFieldState extends State<_AirportDropdownField> {
  final ReservationService _reservationService = ReservationService();
  List<Airport> _remoteAirports = const [];
  int _requestId = 0;
  bool _isSearching = false;

  List<Airport> get _airports {
    final merged = <Airport>[];
    final seen = <String>{};

    for (final airport in [...widget.airports, ..._remoteAirports]) {
      final key =
          '${airport.iata ?? ''}-${airport.city}-${airport.name}'.toLowerCase();
      if (seen.add(key)) {
        merged.add(airport);
      }
    }

    return merged;
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    final initialText = value == null ? '' : _airportDisplayLabel(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: _fieldLabelStyle),
        const SizedBox(height: 8),
        Autocomplete<Airport>(
          initialValue: TextEditingValue(text: initialText),
          displayStringForOption: _airportDisplayLabel,
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text.trim().toLowerCase();
            if (query.isEmpty) {
              return _airports.take(8);
            }

            return _airports.where((airport) {
              final haystack = [
                airport.city,
                airport.name,
                airport.state ?? '',
                airport.country ?? '',
                airport.iata ?? '',
              ].join(' ').toLowerCase();
              return haystack.contains(query);
            }).take(10);
          },
          onSelected: widget.onChanged,
          fieldViewBuilder: (
            context,
            textEditingController,
            focusNode,
            onFieldSubmitted,
          ) {
            if (!focusNode.hasFocus &&
                initialText.isNotEmpty &&
                textEditingController.text != initialText) {
              textEditingController.value = TextEditingValue(
                text: initialText,
                selection: TextSelection.collapsed(offset: initialText.length),
              );
            }

            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: _fieldDecoration(
                hintText: '',
              ).copyWith(
                suffixIcon:
                    _isSearching
                        ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                        : null,
              ),
              onChanged: (raw) {
                if (raw.trim().isEmpty) {
                  widget.onChanged(null);
                  setState(() => _remoteAirports = const []);
                } else {
                  _searchAirports(raw);
                }
              },
              onFieldSubmitted: (_) => onFieldSubmitted(),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  constraints: const BoxConstraints(maxHeight: 280),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCFAF5),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2D4BE)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder:
                        (_, __) => const Divider(
                          height: 1,
                          color: Color(0xFFF0E6D8),
                        ),
                    itemBuilder: (context, index) {
                      final airport = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(airport),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3EBDD),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Icon(
                                  Icons.flight_takeoff_rounded,
                                  size: 16,
                                  color: Color(0xFF7A5D1F),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      airport.city.isEmpty
                                          ? airport.name
                                          : airport.city,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF111111),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      airport.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF6C6355),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                (airport.iata ?? '').isEmpty
                                    ? '---'
                                    : airport.iata!.toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF7A5D1F),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _searchAirports(String raw) async {
    final query = raw.trim();
    if (query.isEmpty) return;

    final requestId = ++_requestId;
    setState(() => _isSearching = true);

    try {
      final results = await _reservationService.searchAirports(query);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _remoteAirports = results;
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      setState(() => _isSearching = false);
    }
  }

  static String _airportDisplayLabel(Airport airport) {
    final iata = (airport.iata ?? '').trim().toUpperCase();
    final city = airport.city.trim();
    final name = airport.name.trim();

    if (iata.isNotEmpty) {
      return '$city ($iata)';
    }

    if (city.isNotEmpty && name.isNotEmpty) {
      return '$city - $name';
    }

    return city.isNotEmpty ? city : name;
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _fieldLabelStyle),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            onChanged(picked);
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: const BorderSide(color: Color(0xFFD7D0C2)),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value == null
                  ? 'dd/mm/aaaa'
                  : '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}',
              style: const TextStyle(color: Color(0xFF111111)),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _fieldLabelStyle),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: value ?? const TimeOfDay(hour: 9, minute: 0),
            );
            onChanged(picked);
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: const BorderSide(color: Color(0xFFD7D0C2)),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value == null
                  ? 'Agregar hora especifica'
                  : '${value!.hour.toString().padLeft(2, '0')}:${value!.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Color(0xFF111111)),
            ),
          ),
        ),
      ],
    );
  }
}

class _PassengerField extends StatelessWidget {
  const _PassengerField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _fieldLabelStyle),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value.toString(),
          keyboardType: TextInputType.number,
          decoration: _fieldDecoration(),
          onChanged: (raw) => onChanged(int.tryParse(raw) ?? value),
        ),
      ],
    );
  }
}

class _PreferenceField extends StatelessWidget {
  const _PreferenceField({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preferencia', style: _fieldLabelStyle),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: _fieldDecoration(),
          items:
              const ['Mejor precio', 'Menor tiempo', 'Mayor confort']
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
          onChanged: (selected) {
            if (selected != null) onChanged(selected);
          },
        ),
      ],
    );
  }
}

class _PortalLeg {
  const _PortalLeg({this.origin, this.destination, this.date, this.time});

  final Airport? origin;
  final Airport? destination;
  final DateTime? date;
  final TimeOfDay? time;

  _PortalLeg copyWith({
    Airport? origin,
    Airport? destination,
    DateTime? date,
    TimeOfDay? time,
  }) {
    return _PortalLeg(
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      date: date ?? this.date,
      time: time ?? this.time,
    );
  }
}

class _MultiDestinationBuilder extends StatelessWidget {
  const _MultiDestinationBuilder({
    required this.airports,
    required this.legs,
    required this.passengers,
    required this.preference,
    required this.onLegChanged,
    required this.onAddLeg,
    required this.onRemoveLeg,
    required this.onPassengersChanged,
    required this.onPreferenceChanged,
  });

  final List<Airport> airports;
  final List<_PortalLeg> legs;
  final int passengers;
  final String preference;
  final void Function(int index, _PortalLeg leg) onLegChanged;
  final VoidCallback onAddLeg;
  final ValueChanged<int> onRemoveLeg;
  final ValueChanged<int> onPassengersChanged;
  final ValueChanged<String> onPreferenceChanged;

  @override
  Widget build(BuildContext context) {
    final completeLegs =
        legs
            .where((leg) => leg.origin != null && leg.destination != null)
            .length;
    final datedLegs = legs.where((leg) => leg.date != null).length;

    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF171717),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AGREGA RUTA',
                  style: TextStyle(
                    color: Color(0xFFCE9A35),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$completeLegs destinos · $datedLegs dias · $passengers pasajeros',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...legs.asMap().entries.map((entry) {
            final index = entry.key;
            final leg = entry.value;
            final routeLabel =
                '${leg.origin?.city ?? 'Origen'} -> ${leg.destination?.city ?? 'Destino'}';
            final dateLabel =
                leg.date == null
                    ? 'Fecha pendiente'
                    : '${leg.date!.day.toString().padLeft(2, '0')}/${leg.date!.month.toString().padLeft(2, '0')}/${leg.date!.year}';
            final timeLabel =
                leg.time == null
                    ? 'Hora pendiente'
                    : '${leg.time!.hour.toString().padLeft(2, '0')}:${leg.time!.minute.toString().padLeft(2, '0')}';

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFEFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE4D8C6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          margin: const EdgeInsets.only(top: 5),
                          decoration: const BoxDecoration(
                            color: Color(0xFF111111),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DESTINO ${index + 1}',
                                style: const TextStyle(
                                  color: Color(0xFFB07A1B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                routeLabel,
                                style: const TextStyle(
                                  color: Color(0xFF111111),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$dateLabel · $timeLabel',
                                style: const TextStyle(
                                  color: Color(0xFF6B6256),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed:
                          legs.length > 2 ? () => onRemoveLeg(index) : null,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        index == 0 ? 'Cerrar' : 'Editar',
                        style: const TextStyle(
                          color: Color(0xFF111111),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final fields = [
                          _AirportDropdownField(
                            label: 'Desde',
                            icon: Icons.radio_button_checked_rounded,
                            airports: airports,
                            value: leg.origin,
                            onChanged:
                                (value) => onLegChanged(
                                  index,
                                  leg.copyWith(origin: value),
                                ),
                          ),
                          _AirportDropdownField(
                            label: 'Hacia',
                            icon: Icons.flight_land_rounded,
                            airports: airports,
                            value: leg.destination,
                            onChanged:
                                (value) => onLegChanged(
                                  index,
                                  leg.copyWith(destination: value),
                                ),
                          ),
                          _DateField(
                            label: 'Fecha',
                            icon: Icons.calendar_month_rounded,
                            value: leg.date,
                            onChanged:
                                (value) => onLegChanged(
                                  index,
                                  leg.copyWith(date: value),
                                ),
                          ),
                          _TimeField(
                            label: 'Hora',
                            icon: Icons.schedule_rounded,
                            value: leg.time,
                            onChanged:
                                (value) => onLegChanged(
                                  index,
                                  leg.copyWith(time: value),
                                ),
                          ),
                        ];

                        if (constraints.maxWidth < 760) {
                          return Column(
                            children:
                                fields
                                    .map(
                                      (field) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: field,
                                      ),
                                    )
                                    .toList(),
                          );
                        }

                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children:
                              fields
                                  .map(
                                    (field) =>
                                        SizedBox(width: 220, child: field),
                                  )
                                  .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
            onPressed: onAddLeg,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF0E9DE),
                foregroundColor: const Color(0xFF111111),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '+ Agregar destino',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final passengerField = _PassengerField(
                label: 'Pasajeros',
                icon: Icons.person_outline_rounded,
                value: passengers,
                onChanged: onPassengersChanged,
              );
              final preferenceField = _PreferenceField(
                value: preference,
                onChanged: onPreferenceChanged,
              );

              if (constraints.maxWidth < 760) {
                return Column(
                  children: [
                    passengerField,
                    const SizedBox(height: 12),
                    preferenceField,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: passengerField),
                  const SizedBox(width: 12),
                  Expanded(child: preferenceField),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF111111),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cotizar itinerario',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _SignalWrap(
            items: [
              'Operadores verificados',
              'Sin brokers',
              'Concierge 24/7',
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}



