part of 'client_portal_sections.dart';

enum _BookingStep { reservar, resultados, aeronave, paquete, reserva }

class ClientPortalBookingScreen extends StatefulWidget {
  const ClientPortalBookingScreen({super.key});

  @override
  State<ClientPortalBookingScreen> createState() =>
      _ClientPortalBookingScreenState();
}

class _ClientPortalBookingScreenState extends State<ClientPortalBookingScreen> {
  String _tripType = 'Ida';
  _BookingStep _step = _BookingStep.reservar;
  DateTime? _departureDate;
  TimeOfDay? _departureTime;
  DateTime? _returnDate;
  TimeOfDay? _returnTime;
  int _passengers = 6;
  String _preference = 'Mejor precio';
  String? _selectedPackage;
  Aircraft? _selectedAircraft;
  Airport? _origin;
  Airport? _destination;
  final List<_PortalLeg> _legs = [const _PortalLeg(), const _PortalLeg()];

  List<Aircraft> _matches = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensureDataReady();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReservationProvider>();
    final airports = provider.airports;
    final showOnlyStepOne =
        _step == _BookingStep.reservar &&
        _tripType != 'Multi-destino' &&
        (_origin == null || _destination == null);

    return _PortalPage(
      title: 'Portal cliente',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _PortalHero(
            eyebrow: 'PLANIFICADOR DE AVIACION PRIVADA',
            title: _heroTitle(),
            subtitle: 'Reserva aviacion privada verificada en minutos.',
            primaryLabel: 'Cotizar vuelo privado',
            helper: 'Precios transparentes • Sin intermediarios',
          ),
          if (!showOnlyStepOne) ...[
            const SizedBox(height: 12),
            _SmartSummaryBar(
              routeLabel: _routeLabel(),
              passengersLabel: '$_passengers pax',
              preferenceLabel: _preference,
            ),
            const SizedBox(height: 12),
          ] else
            const SizedBox(height: 12),
          if (_step == _BookingStep.reservar) ...[
            _TripTypeSelector(
              value: _tripType,
              onChanged: (value) {
                setState(() {
                  _tripType = value;
                  if (_tripType != 'Multi-destino') {
                    _legs
                      ..clear()
                      ..addAll([const _PortalLeg(), const _PortalLeg()]);
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            if (_tripType == 'Multi-destino')
              _MultiDestinationBuilder(
                airports: airports,
                legs: _legs,
                passengers: _passengers,
                preference: _preference,
                onLegChanged: (index, leg) {
                  setState(() => _legs[index] = leg);
                },
                onAddLeg: () {
                  setState(() => _legs.add(const _PortalLeg()));
                },
                onRemoveLeg: (index) {
                  if (_legs.length <= 2) return;
                  setState(() => _legs.removeAt(index));
                },
                onPassengersChanged: (value) {
                  setState(() => _passengers = value);
                },
                onPreferenceChanged: (value) {
                  setState(() => _preference = value);
                },
              )
            else
              _BookingSearchCard(
                showOnlyStepOne: showOnlyStepOne,
                tripType: _tripType,
                airports: airports,
                origin: _origin,
                destination: _destination,
                departureDate: _departureDate,
                departureTime: _departureTime,
                returnDate: _returnDate,
                returnTime: _returnTime,
                passengers: _passengers,
                preference: _preference,
                onOriginChanged: (value) => setState(() => _origin = value),
                onDestinationChanged:
                    (value) => setState(() => _destination = value),
                onDepartureDateChanged:
                    (value) => setState(() => _departureDate = value),
                onDepartureTimeChanged:
                    (value) => setState(() => _departureTime = value),
                onReturnDateChanged:
                    (value) => setState(() => _returnDate = value),
                onReturnTimeChanged:
                    (value) => setState(() => _returnTime = value),
                onPassengersChanged: (value) {
                  setState(() => _passengers = value);
                },
                onPreferenceChanged: (value) {
                  setState(() => _preference = value);
                },
              ),
            if (!showOnlyStepOne &&
                !provider.isLoadingData &&
                airports.isEmpty &&
                provider.reservations.isEmpty) ...[
              const SizedBox(height: 16),
              const _EmptyPortalState(
                message:
                    'Todavia no hay datos sincronizados para buscar rutas o mostrar aeronaves.',
              ),
            ],
            if (!showOnlyStepOne) ...[
              const SizedBox(height: 16),
              _SignalWrap(
                items: const [
                  'Operadores verificados',
                  'Sin brokers',
                  'Concierge 24/7',
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      provider.isLoadingData
                          ? null
                          : () async => _submitSearch(provider),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF10161D),
                    foregroundColor: const Color(0xFFF8F3E8),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    _tripType == 'Multi-destino'
                        ? 'Cotizar itinerario'
                        : 'Cotizar vuelo privado',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Respuesta estimada en menos de 3 minutos',
                  style: TextStyle(
                    color: Color(0xFF6B6256),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ] else if (_step == _BookingStep.resultados) ...[
            _StickySummaryCard(
              title: _routeLabel(),
              subtitle: '${_passengersLabel()} Â· ${_dateLabel()}',
              trailing:
                  _matches.isEmpty
                      ? 'Sin opciones'
                      : '${_matches.length} opciones',
            ),
            const SizedBox(height: 16),
            _FilterBar(
              values: const [
                'Mejor precio',
                'Mas rapido',
                'Mas espacio',
                'Recomendado',
              ],
              activeValue: 'Recomendado',
            ),
            const SizedBox(height: 16),
            if (_matches.isEmpty)
              const _EmptyPortalState(
                message: 'No hay aeronaves disponibles para este itinerario.',
              )
            else
              ..._matches.map(
                (aircraft) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _AircraftMatchCard(
                    aircraft: aircraft,
                    onViewDetail: () {
                      setState(() {
                        _selectedAircraft = aircraft;
                        provider.setAircraft(aircraft);
                        _step = _BookingStep.aeronave;
                      });
                    },
                  ),
                ),
              ),
          ] else if (_step == _BookingStep.aeronave) ...[
            if (_selectedAircraft == null)
              const _EmptyPortalState(message: 'No hay aeronave seleccionada.')
            else
              _AircraftDetailPanel(
                aircraft: _selectedAircraft!,
                routeLabel: _routeLabel(),
                passengersLabel: _passengersLabel(),
                onBack: () => setState(() => _step = _BookingStep.resultados),
                onContinue: () => setState(() => _step = _BookingStep.paquete),
              ),
          ] else if (_step == _BookingStep.paquete) ...[
            _SectionHeading(
              title: 'Paquete de vuelo',
              subtitle:
                  'Mismo paso del portal web para elegir acceso y servicio.',
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children:
                  _packageOptions.map((plan) {
                    final isSelected = _selectedPackage == plan.name;
                    return SizedBox(
                      width: 280,
                      child: _PackageCard(
                        plan: plan,
                        selected: isSelected,
                        onTap: () {
                          setState(() => _selectedPackage = plan.name);
                        },
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
            _SummaryBand(
              label: 'Acceso de servicio',
              value: _selectedPackage ?? 'Elige un paquete',
              buttonLabel: 'Continuar',
              onPressed:
                  _selectedPackage == null
                      ? null
                      : () => setState(() => _step = _BookingStep.reserva),
            ),
          ] else ...[
            _ReservationSummaryCard(
              aircraft: _selectedAircraft,
              routeLabel: _routeLabel(),
              dateLabel: _dateLabel(),
              passengersLabel: _passengersLabel(),
              packageLabel: _selectedPackage ?? 'Sin paquete',
              onBack: () => setState(() => _step = _BookingStep.paquete),
              onConfirm: _confirmReservation,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepPill() {
    final labels = {
      _BookingStep.reservar: 'Reservar',
      _BookingStep.resultados: 'Resultados',
      _BookingStep.aeronave: 'Aeronave',
      _BookingStep.paquete: 'Paquete',
      _BookingStep.reserva: 'Reserva',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x26F0D8A8)),
      ),
      child: Text(
        labels[_step]!,
        style: const TextStyle(
          color: Color(0xFFF0D8A8),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _heroTitle() {
    switch (_step) {
      case _BookingStep.reservar:
        return 'Tu tiempo merece otra altitud';
      case _BookingStep.resultados:
        return 'Opciones verificadas para tu itinerario';
      case _BookingStep.aeronave:
        return 'Detalle ejecutivo de la aeronave';
      case _BookingStep.paquete:
        return 'Activa el paquete ideal para este vuelo';
      case _BookingStep.reserva:
        return 'Resumen final antes de confirmar';
    }
  }

  String _routeLabel() {
    if (_tripType == 'Multi-destino') {
      final validLegs =
          _legs
              .where((leg) => leg.origin != null && leg.destination != null)
              .toList();
      if (validLegs.isEmpty) return 'Ruta por definir';
      final first = validLegs.first;
      final last = validLegs.last;
      return '${first.origin!.city} -> ${last.destination!.city}';
    }

    if (_origin == null || _destination == null) return 'Ruta por definir';
    return '${_origin!.city} -> ${_destination!.city}';
  }

  String _dateLabel() {
    final departure = _formatDateTime(_departureDate, _departureTime);
    if (_tripType != 'Redondo') return departure;
    final returning = _formatDateTime(_returnDate, _returnTime);
    return '$departure / $returning';
  }

  String _formatDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null) return 'Fecha por confirmar';
    final month = _monthLabel(date.month);
    final dateLabel = '${date.day.toString().padLeft(2, '0')} $month';
    if (time == null) return dateLabel;
    final timeLabel =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return '$dateLabel Â· $timeLabel';
  }

  String _monthLabel(int month) {
    const labels = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return labels[(month - 1).clamp(0, labels.length - 1)];
  }

  String _passengersLabel() =>
      '$_passengers ${_passengers == 1 ? 'pasajero' : 'pasajeros'}';

  Future<void> _submitSearch(ReservationProvider provider) async {
    if (provider.isLoadingData) {
      _showMessage(
        'Estamos sincronizando el portal. Intenta de nuevo en unos segundos.',
      );
      return;
    }

    Airport? searchOrigin = _origin;
    Airport? searchDestination = _destination;
    var extraLegs = const <Map<String, dynamic>>[];
    DateTime? searchDepartureDate = _departureDate;
    TimeOfDay? searchDepartureTime = _departureTime;

    if (_tripType == 'Multi-destino') {
      final validLegs =
          _legs
              .where((leg) => leg.origin != null && leg.destination != null)
              .toList();
      if (validLegs.length < 2) {
        _showMessage('Agrega al menos dos tramos para cotizar.');
        return;
      }

      searchOrigin = validLegs.first.origin;
      searchDestination = validLegs.first.destination;
      searchDepartureDate = validLegs.first.date;
      searchDepartureTime = validLegs.first.time;
      extraLegs =
          validLegs
              .skip(1)
              .map(
                (leg) => {
                  'origin': leg.origin?.iata ?? leg.origin?.name ?? '',
                  'destination':
                      leg.destination?.iata ?? leg.destination?.name ?? '',
                  'date': leg.date == null
                      ? ''
                      : '${leg.date!.year.toString().padLeft(4, '0')}-${leg.date!.month.toString().padLeft(2, '0')}-${leg.date!.day.toString().padLeft(2, '0')}',
                  'time': leg.time == null
                      ? '09:00'
                      : '${leg.time!.hour.toString().padLeft(2, '0')}:${leg.time!.minute.toString().padLeft(2, '0')}',
                },
              )
              .toList();
    } else {
      if (_origin == null || _destination == null || _departureDate == null) {
        _showMessage('Completa origen, destino y fecha para continuar.');
        return;
      }
    }

    if (searchOrigin == null ||
        searchDestination == null ||
        searchDepartureDate == null) {
      _showMessage('Completa origen, destino y fecha para continuar.');
      return;
    }

    try {
      final matches = await provider.searchClientFlights(
        origin: searchOrigin!,
        destination: searchDestination!,
        departureDate: searchDepartureDate,
        departureTime: searchDepartureTime,
        passengers: _passengers,
        preference: _preference,
        extraLegs: extraLegs,
        tripLabel: _tripType,
      );

      if (!mounted) return;

      setState(() {
        _matches = matches.take(6).toList();
        _selectedAircraft = _matches.isNotEmpty ? _matches.first : null;
        if (_selectedAircraft != null) {
          provider.setAircraft(_selectedAircraft);
        }
        _step = _BookingStep.resultados;
      });
    } catch (error) {
      _showMessage('No fue posible consultar opciones del servidor.');
      debugPrint('ERROR SEARCHING CLIENT FLIGHTS: $error');
    }
  }

  void _confirmReservation() {
    _showMessage(
      'Reserva solicitada. El flujo cliente ya quedo alineado al portal web.',
    );
    setState(() {
      _step = _BookingStep.resultados;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _ensureDataReady() async {
    final provider = context.read<ReservationProvider>();
    if (provider.isLoadingData) return;
    if (provider.lastSyncAt != null) {
      return;
    }

    await provider.loadClientPortalData();
  }
}



