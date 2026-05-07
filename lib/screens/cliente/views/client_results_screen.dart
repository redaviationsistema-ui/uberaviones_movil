import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/aircraft.dart';
import '../../../models/workflow_models.dart';
import '../../../providers/reservation_provider.dart';
import '../../../providers/workflow_provider.dart';
import '../../shared/widgets/workflow_crud_sheet.dart';
import 'client_aircraft_detail_screen.dart';
import '../widgets/client_experience_widgets.dart';

class ClientResultsScreen extends StatelessWidget {
  const ClientResultsScreen({super.key});

  String _categoryLabel(Aircraft aircraft) {
    final type = aircraft.aircraftType.toLowerCase();
    if (type.contains('heavy')) return 'Pesado';
    if (type.contains('super')) return 'Super mediano';
    if (type.contains('mid')) return 'Mediano';
    if (type.contains('turbo')) return 'Turbohelice';
    if (type.contains('helic')) return 'Helicoptero';
    return 'Jet ligero';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReservationProvider>();
    const flowId = 'Cliente::Resultados';
    final workflow = context.watch<WorkflowProvider>();
    workflow.watch(
      flowId: flowId,
      initialRecords: const [
        StaticRecord(
          title: 'Comparacion inicial',
          subtitle: 'Opciones listas para comparar y solicitar propuesta.',
          status: 'Pendiente',
          amount: 'Top picks',
        ),
      ],
    );
    final fleet = provider.aircraftFleet.take(5).toList();

    Future<void> createComparison(String title, String subtitle) async {
      final record = StaticRecord(
        title: title,
        subtitle: subtitle,
        status: 'Pendiente',
        amount: '${fleet.length} opciones',
      );
      context.read<WorkflowProvider>().createRecord(flowId, record);
      if (!context.mounted) return;
      await _openResultRecord(context, flowId, record);
    }

    return ClientExperienceShell(
      title: 'Opciones recomendadas',
      subtitle:
          'Comparador visual inspirado en fleet, pero aterrizado a compra rapida.',
      trailing: StatusBadge(
        label: fleet.isEmpty ? 'Sin flota' : '${fleet.length} matches',
        color:
            fleet.isEmpty ? const Color(0xFFB46A00) : const Color(0xFF1B8F4D),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          ClientHeroCard(
            badge: 'Matching premium',
            title: 'Compara aeronaves como servicio, no como catalogo estatico',
            subtitle:
                'Cada tarjeta resuelve una decision: costo, tiempo, categoria y facilidad de salida.',
            metrics: [
              ClientHeroMetric(
                label: 'Rango',
                value: fleet.isEmpty ? 'Pendiente' : 'Ligero a pesado',
              ),
              const ClientHeroMetric(label: 'Salida', value: 'Hoy / manana'),
              const ClientHeroMetric(label: 'Formato', value: 'Detalle rapido'),
            ],
            primaryLabel: 'Filtrar mejor',
            primaryAction:
                () => context.read<WorkflowProvider>().toggleAttentionFilter(
                  flowId,
                ),
            secondaryLabel: 'Comparar 2 opciones',
            secondaryAction:
                () => createComparison(
                  'Comparador de aeronaves',
                  'Se agregaron dos opciones recomendadas para evaluar costo, velocidad y capacidad.',
                ),
          ),
          const SizedBox(height: 24),
          const ClientSectionTitle(
            title: 'Top picks',
            subtitle:
                'Las mejores combinaciones entre imagen ejecutiva, disponibilidad y tarifa.',
          ),
          const SizedBox(height: 14),
          if (fleet.isEmpty)
            const GlassInfoCard(
              child: Text(
                'Aun no hay aeronaves cargadas. Cuando la flota se sincronice, esta vista mostrara resultados con tarjetas premium.',
                style: TextStyle(color: Color(0xFF607080), height: 1.35),
              ),
            )
          else
            ...fleet.map(
              (aircraft) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _AircraftResultCard(
                  aircraft: aircraft,
                  categoryLabel: _categoryLabel(aircraft),
                  flowId: flowId,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AircraftResultCard extends StatelessWidget {
  const _AircraftResultCard({
    required this.aircraft,
    required this.categoryLabel,
    required this.flowId,
  });

  final Aircraft aircraft;
  final String categoryLabel;
  final String flowId;

  @override
  Widget build(BuildContext context) {
    final premiumScore =
        (aircraft.capacityPassengers * 7) + aircraft.cruiseSpeedKnots / 10;
    final estimatedTrip =
        aircraft.rentalPriceUsd * (aircraft.minimumHours + 0.8);

    return GlassInfoCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aircraft.name.isEmpty
                          ? 'Aeronave ejecutiva'
                          : aircraft.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF10253A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$categoryLabel · ${aircraft.capacityPassengers} pasajeros · ${aircraft.city}',
                      style: const TextStyle(
                        color: Color(0xFF607080),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const StatusBadge(
                label: 'Disponible rapido',
                color: Color(0xFF1B8F4D),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PricePill(
                  label: 'Desde',
                  value: formatMoney(estimatedTrip),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PricePill(
                  label: 'Velocidad',
                  value: '${aircraft.cruiseSpeedKnots.toStringAsFixed(0)} kts',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PricePill(
                  label: 'Score',
                  value: premiumScore.toStringAsFixed(0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Encaja bien para traslado corporativo, agenda cerrada y salida sin friccion desde ${aircraft.homeBase}.',
            style: const TextStyle(color: Color(0xFF607080), height: 1.35),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ClientAircraftDetailScreen(aircraft: aircraft),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF10253A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Ver detalle'),
              ),
              OutlinedButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    builder:
                        (_) => Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Propuesta para ${aircraft.name}',
                                style: const TextStyle(
                                  color: Color(0xFF10253A),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Se enviaria una solicitud al operador con tarifa estimada ${formatMoney(estimatedTrip)}, capacidad ${aircraft.capacityPassengers} pasajeros y salida desde ${aircraft.homeBase}.',
                                style: const TextStyle(
                                  color: Color(0xFF607080),
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    final record = StaticRecord(
                                      title: 'Solicitud ${aircraft.name}',
                                      subtitle:
                                          'Proveedor notificado localmente con tarifa estimada ${formatMoney(estimatedTrip)} y salida desde ${aircraft.homeBase}.',
                                      status: 'Enviada',
                                      amount: formatMoney(estimatedTrip),
                                    );
                                    context
                                        .read<WorkflowProvider>()
                                        .createRecord(flowId, record);
                                    _openResultRecord(context, flowId, record);
                                  },
                                  icon: const Icon(Icons.send_rounded),
                                  label: const Text('Enviar solicitud'),
                                ),
                              ),
                            ],
                          ),
                        ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF10253A),
                  side: const BorderSide(color: Color(0xFFD5DEE7)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Solicitar propuesta'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _openResultRecord(
  BuildContext context,
  String flowId,
  StaticRecord record,
) {
  final provider = context.read<WorkflowProvider>();
  return showWorkflowRecordDetail(
    context,
    record: record,
    onAdvance: () => provider.advanceRecord(flowId, record),
    onActivate:
        () => provider.updateRecord(
          flowId,
          record,
          record.copyWith(status: 'Confirmado'),
        ),
    onBlock:
        () => provider.updateRecord(
          flowId,
          record,
          record.copyWith(status: 'Bloqueado'),
        ),
    onDelete: () => provider.deleteRecord(flowId, record),
    onEdit: () async {
      final updated = await showWorkflowRecordForm(
        context,
        title: 'Editar solicitud',
        initial: record,
      );
      if (updated != null && context.mounted) {
        provider.updateRecord(flowId, record, updated);
      }
    },
  );
}
