import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/reservation_provider.dart';
import '../widgets/client_experience_widgets.dart';

class ClientHistoryScreen extends StatelessWidget {
  const ClientHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReservationProvider>();
    final reservations = provider.reservations;

    return ClientExperienceShell(
      title: 'Mis vuelos',
      subtitle: 'Historial, creditos y cancelaciones en tono ejecutivo.',
      trailing: StatusBadge(
        label: '${reservations.length} registros',
        color: const Color(0xFF143955),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          ClientHeroCard(
            badge: 'Post booking',
            title: 'Una vista de historial que ayuda a recomprar y reprogramar',
            subtitle:
                'En lugar de parrafos largos, esta pantalla organiza el valor para clientes frecuentes: repetir ruta, revisar cargo y conservar contexto.',
            metrics: [
              ClientHeroMetric(label: 'Vuelos activos', value: reservations.length.toString()),
              const ClientHeroMetric(label: 'Reagenda', value: '1 tap'),
              const ClientHeroMetric(label: 'Politicas', value: 'Visibles'),
            ],
            primaryLabel: 'Repetir una ruta',
            primaryAction: () {},
            secondaryLabel: 'Ver creditos',
            secondaryAction: () {},
          ),
          const SizedBox(height: 24),
          const ClientSectionTitle(
            title: 'Actividad reciente',
            subtitle: 'Una bitacora limpia para cerrar la experiencia de charter digital.',
          ),
          const SizedBox(height: 14),
          if (reservations.isEmpty)
            const GlassInfoCard(
              child: Text(
                'Todavia no hay reservas activas o historicas almacenadas localmente. Esta vista quedo lista para renderizarlas con mejor presencia visual.',
                style: TextStyle(color: Color(0xFF607080), height: 1.35),
              ),
            )
          else
            ...reservations.take(4).toList().asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _HistoryCard(
                  index: entry.key,
                  reservation: entry.value,
                ),
              ),
            ),
          const SizedBox(height: 24),
          const ClientSectionTitle(
            title: 'Politica transparente',
            subtitle: 'Reglas visibles antes y despues de reservar para bajar friccion.',
          ),
          const SizedBox(height: 14),
          const GlassInfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PolicyRow(
                  label: 'Antes de confirmar',
                  detail: 'Edicion libre de ruta, horario o pasajeros sin penalizacion.',
                ),
                SizedBox(height: 12),
                _PolicyRow(
                  label: '72 a 24 horas',
                  detail: 'La app debe mostrar retencion estimada y opcion de reagendar.',
                ),
                SizedBox(height: 12),
                _PolicyRow(
                  label: 'Menos de 24 horas',
                  detail: 'Se conserva contexto comercial y evidencia operativa para soporte.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.index,
    required this.reservation,
  });

  final int index;
  final Map<String, dynamic> reservation;

  @override
  Widget build(BuildContext context) {
    final start = reservation['startDatetime'] as DateTime?;
    final end = reservation['endDatetime'] as DateTime?;
    final aircraftId = reservation['aircraftId']?.toString() ?? 'Sin ID';

    return GlassInfoCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF143955).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '#${index + 1}',
                style: const TextStyle(
                  color: Color(0xFF143955),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reserva $aircraftId',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF10253A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${start?.toString() ?? 'Sin inicio'}  ->  ${end?.toString() ?? 'Sin cierre'}',
                  style: const TextStyle(
                    color: Color(0xFF607080),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const StatusBadge(label: 'Historial', color: Color(0xFF143955)),
        ],
      ),
    );
  }
}

class _PolicyRow extends StatelessWidget {
  const _PolicyRow({
    required this.label,
    required this.detail,
  });

  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE0B86E),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF10253A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: const TextStyle(
                  color: Color(0xFF607080),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
