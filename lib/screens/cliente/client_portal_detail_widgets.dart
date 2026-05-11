part of 'client_portal_sections.dart';

class _StickySummaryCard extends StatelessWidget {
  const _StickySummaryCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF5F5F5F)),
                ),
              ],
            ),
          ),
          _TagLabel(trailing),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.values, required this.activeValue});

  final List<String> values;
  final String activeValue;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          values.map((value) {
            final active = value == activeValue;
            return Chip(
              backgroundColor:
                  active ? const Color(0xFF111111) : const Color(0xFFF0ECE3),
              label: Text(
                value,
                style: TextStyle(
                  color: active ? Colors.white : const Color(0xFF111111),
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }).toList(),
    );
  }
}

class _AircraftMatchCard extends StatelessWidget {
  const _AircraftMatchCard({
    required this.aircraft,
    required this.onViewDetail,
  });

  final Aircraft aircraft;
  final VoidCallback onViewDetail;

  @override
  Widget build(BuildContext context) {
    final estimate = aircraft.rentalPriceUsd * (aircraft.minimumHours + 0.8);
    return _SoftCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 860;
          final content = [
            _AircraftThumb(
              label:
                  aircraft.aircraftType.isEmpty
                      ? 'Recomendado'
                      : aircraft.aircraftType,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aircraft.name.isEmpty
                          ? 'Aeronave ejecutiva'
                          : aircraft.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${aircraft.capacityPassengers} pax Â· ${aircraft.homeBase} Â· ${aircraft.city}',
                      style: const TextStyle(
                        color: Color(0xFF5F5F5F),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SignalWrap(
                      items: [
                        'Vuelo privado',
                        '${aircraft.cruiseSpeedKnots.toStringAsFixed(0)} kts',
                        'Min ${aircraft.minimumHours.toStringAsFixed(1)} hrs',
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment:
                  isNarrow ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${estimate.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Precio estimado',
                  style: TextStyle(color: Color(0xFF6A6A6A)),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: onViewDetail,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Ver detalle'),
                ),
              ],
            ),
          ];

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AircraftThumb(
                  label:
                      aircraft.aircraftType.isEmpty
                          ? 'Recomendado'
                          : aircraft.aircraftType,
                ),
                const SizedBox(height: 14),
                Text(
                  aircraft.name.isEmpty ? 'Aeronave ejecutiva' : aircraft.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${aircraft.capacityPassengers} pax Â· ${aircraft.homeBase} Â· ${aircraft.city}',
                  style: const TextStyle(
                    color: Color(0xFF5F5F5F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _SignalWrap(
                  items: [
                    'Vuelo privado',
                    '${aircraft.cruiseSpeedKnots.toStringAsFixed(0)} kts',
                    'Min ${aircraft.minimumHours.toStringAsFixed(1)} hrs',
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  '\$${estimate.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Precio estimado',
                  style: TextStyle(color: Color(0xFF6A6A6A)),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: onViewDetail,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Ver detalle'),
                ),
              ],
            );
          }

          return Row(children: content);
        },
      ),
    );
  }
}

class _AircraftThumb extends StatelessWidget {
  const _AircraftThumb({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF4A4A4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF111111),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _AircraftDetailPanel extends StatelessWidget {
  const _AircraftDetailPanel({
    required this.aircraft,
    required this.routeLabel,
    required this.passengersLabel,
    required this.onBack,
    required this.onContinue,
  });

  final Aircraft aircraft;
  final String routeLabel;
  final String passengersLabel;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                aircraft.name.isEmpty ? 'Aeronave ejecutiva' : aircraft.name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$routeLabel Â· $passengersLabel',
                style: const TextStyle(color: Color(0xFF5F5F5F), height: 1.4),
              ),
              const SizedBox(height: 14),
              _SignalWrap(
                items: [
                  '${aircraft.capacityPassengers} pasajeros',
                  '${aircraft.cruiseSpeedKnots.toStringAsFixed(0)} kts',
                  'Base ${aircraft.homeBase}',
                  '\$${aircraft.rentalPriceUsd.toStringAsFixed(0)}/hr',
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton(
                    onPressed: onBack,
                    child: const Text('Volver'),
                  ),
                  FilledButton(
                    onPressed: onContinue,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF111111),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Elegir paquete'),
                  ),
                ],
              ),
            ],
          );

          if (constraints.maxWidth < 860) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AircraftThumb(
                  label:
                      aircraft.aircraftType.isEmpty
                          ? 'Cabina privada'
                          : aircraft.aircraftType,
                ),
                const SizedBox(height: 18),
                details,
              ],
            );
          }

          return Row(
            children: [
              _AircraftThumb(
                label:
                    aircraft.aircraftType.isEmpty
                        ? 'Cabina privada'
                        : aircraft.aircraftType,
              ),
              const SizedBox(width: 20),
              Expanded(child: details),
            ],
          );
        },
      ),
    );
  }
}

class _PackagePlan {
  const _PackagePlan({
    required this.name,
    required this.badge,
    required this.price,
    required this.description,
    required this.items,
  });

  final String name;
  final String badge;
  final String price;
  final String description;
  final List<String> items;
}

const List<_PackagePlan> _packageOptions = [
  _PackagePlan(
    name: 'Demo',
    badge: 'Explorar',
    price: 'Acceso inicial',
    description:
        'Entrada inicial para validar experiencia y primer contacto concierge.',
    items: ['Visibilidad basica', 'Seguimiento inicial', 'Ruta protegida'],
  ),
  _PackagePlan(
    name: 'Basic',
    badge: 'Acceso privado',
    price: 'Uso recurrente',
    description:
        'Ideal para viajeros que necesitan movilidad premium ordenada.',
    items: ['Reservas protegidas', 'Concierge operativo', 'Soporte de salida'],
  ),
  _PackagePlan(
    name: 'Pro',
    badge: 'Mas solicitado',
    price: 'Prioridad premium',
    description:
        'Pensado para clientes frecuentes y cuentas con prioridad real.',
    items: [
      'Catering ejecutivo',
      'Prioridad de atencion',
      'Seguimiento reforzado',
    ],
  ),
  _PackagePlan(
    name: 'Elite',
    badge: 'Enterprise',
    price: 'A medida',
    description: 'Infraestructura premium para cuentas con multiples actores.',
    items: [
      'Control administrativo',
      'Prioridad total',
      'Cobertura corporativa',
    ],
  ),
];

class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.plan, this.selected = false, this.onTap});

  final _PackagePlan plan;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFFAF0) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? const Color(0xFFDFC48B) : const Color(0xFFE8E1D5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _TagLabel(plan.badge),
                const Spacer(),
                Text(
                  plan.price,
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              plan.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              plan.description,
              style: const TextStyle(color: Color(0xFF5F5F5F), height: 1.45),
            ),
            const SizedBox(height: 12),
            ...plan.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'â€¢ $item',
                  style: const TextStyle(
                    color: Color(0xFF5F5F5F),
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBand extends StatelessWidget {
  const _SummaryBand({
    required this.label,
    required this.value,
    required this.buttonLabel,
    this.onPressed,
  });

  final String label;
  final String value;
  final String buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF6A6A6A),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF111111),
              foregroundColor: Colors.white,
            ),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}

class _ReservationSummaryCard extends StatelessWidget {
  const _ReservationSummaryCard({
    required this.aircraft,
    required this.routeLabel,
    required this.dateLabel,
    required this.passengersLabel,
    required this.packageLabel,
    required this.onBack,
    required this.onConfirm,
  });

  final Aircraft? aircraft;
  final String routeLabel;
  final String dateLabel;
  final String passengersLabel;
  final String packageLabel;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _TagLabel('Confirmacion'),
          const SizedBox(height: 14),
          const Text(
            'Resumen del vuelo',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 14),
          _SummaryLine(
            label: 'Aeronave',
            value: aircraft?.name ?? 'Por confirmar',
          ),
          _SummaryLine(label: 'Ruta', value: routeLabel),
          _SummaryLine(label: 'Fecha', value: dateLabel),
          _SummaryLine(label: 'Pasajeros', value: passengersLabel),
          _SummaryLine(label: 'Paquete', value: packageLabel),
          if (aircraft != null)
            _SummaryLine(
              label: 'Precio final',
              value:
                  '\$${(aircraft!.rentalPriceUsd * (aircraft!.minimumHours + 0.8)).toStringAsFixed(0)}',
            ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton(onPressed: onBack, child: const Text('Volver')),
              FilledButton(
                onPressed: onConfirm,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF111111),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirmar reserva'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6A6A6A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF111111),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF5F5F5F), height: 1.45),
        ),
      ],
    );
  }
}

class _TimelineStage {
  const _TimelineStage({
    required this.meta,
    required this.title,
    required this.description,
    required this.done,
  });

  final String meta;
  final String title;
  final String description;
  final bool done;
}

class _TimelineGrid extends StatelessWidget {
  const _TimelineGrid({required this.steps});

  final List<_TimelineStage> steps;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children:
          steps.map((step) {
            return SizedBox(
              width: 280,
              child: _SoftCard(
                backgroundColor:
                    step.done ? const Color(0xFFFAF6EA) : Colors.white,
                borderColor:
                    step.done
                        ? const Color(0xFFE7D7AC)
                        : const Color(0xFFE8E1D5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.meta,
                      style: const TextStyle(
                        color: Color(0xFF7A5D1F),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step.description,
                      style: const TextStyle(
                        color: Color(0xFF5F5F5F),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}

class _RequestsTable extends StatelessWidget {
  const _RequestsTable({required this.reservations});

  final List<Map<String, dynamic>> reservations;

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) {
      return const _EmptyPortalState(
        message: 'Aun no hay solicitudes registradas.',
      );
    }

    return _SoftCard(
      child: Column(
        children:
            reservations.map((reservation) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '#${reservation['aircraftId'] ?? 'N/D'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111111),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${reservation['startDatetime']}',
                          style: const TextStyle(color: Color(0xFF5F5F5F)),
                        ),
                      ),
                      const _TagLabel('Seguimiento'),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.value,
    this.wide = false,
  });

  final String label;
  final String value;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAF7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E1D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _fieldLabelStyle),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111111),
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalWrap extends StatelessWidget {
  const _SignalWrap({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 8,
      children:
          items
              .map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EDE1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item,
                        style: const TextStyle(
                          color: Color(0xFF3B3428),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }
}

class _SoftCard extends StatelessWidget {
  const _SoftCard({
    required this.child,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFE8E1D5),
  });

  final Widget child;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class _EmptyPortalState extends StatelessWidget {
  const _EmptyPortalState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFF5F5F5F), height: 1.45),
      ),
    );
  }
}

const TextStyle _fieldLabelStyle = TextStyle(
  color: Color(0xFF655A4D),
  fontWeight: FontWeight.w700,
  fontSize: 12,
);

InputDecoration _fieldDecoration({String? hintText}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: Color(0xFF9A907F),
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    filled: true,
    fillColor: const Color(0xFFFFFEFB),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE0D5C4)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE0D5C4)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFF0A51A), width: 1.4),
    ),
  );
}




