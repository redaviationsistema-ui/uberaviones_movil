part of 'client_portal_sections.dart';

class ClientPortalTripsScreen extends StatelessWidget {
  const ClientPortalTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReservationProvider>();

    return _PortalPage(
      title: 'Mis vuelos',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          _PortalHero(
            eyebrow: 'Mis vuelos',
            title: 'Manten tus solicitudes bajo el mismo flujo premium.',
            subtitle:
                'Seguimiento, timeline e historial con la misma lectura editorial del portal web.',
            trailing: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ClientConciergeScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.support_agent_rounded),
              label: const Text('Hablar con concierge'),
            ),
          ),
          const SizedBox(height: 18),
          _PortalSyncBanner(
            provider: provider,
            onRefresh: provider.loadClientPortalData,
          ),
          const SizedBox(height: 18),
          _MembershipStatusStrip(
            items: [
              _StatusItem(
                label: 'Solicitudes',
                value:
                    provider.reservations.isEmpty
                        ? 'Sin solicitudes'
                        : '#${provider.reservations.length}',
              ),
              _StatusItem(label: 'Ruta activa', value: _activeRoute(provider)),
              _StatusItem(
                label: 'Estado',
                value: provider.isOnline ? 'Sincronizado' : 'Offline',
              ),
              _StatusItem(label: 'Salida', value: _activeDate(provider)),
            ],
          ),
          const SizedBox(height: 18),
          const _SectionHeading(
            title: 'Como avanza una solicitud privada',
            subtitle: 'Lectura por etapas, no tabla fria de backoffice.',
          ),
          const SizedBox(height: 14),
          const _TimelineGrid(
            steps: [
              _TimelineStage(
                meta: 'Paso 01',
                title: 'Solicitud enviada',
                description: 'La ruta entra al flujo protegido del cliente.',
                done: true,
              ),
              _TimelineStage(
                meta: 'Paso 02',
                title: 'Matching validado',
                description: 'Se cruzan operadores, disponibilidad y servicio.',
                done: true,
              ),
              _TimelineStage(
                meta: 'Paso 03',
                title: 'Contrato y pago',
                description: 'Cierre comercial antes de liberar confirmacion.',
                done: false,
              ),
              _TimelineStage(
                meta: 'Paso 04',
                title: 'Dia de vuelo',
                description: 'Briefing, FBO, concierge y seguimiento final.',
                done: false,
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _SectionHeading(
            title: 'Momentos clave',
            subtitle: 'Cards rapidas para leer lo ultimo sin perder contexto.',
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children:
                provider.reservations.take(3).map((reservation) {
                  return SizedBox(
                    width: 320,
                    child: _SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _TagLabel('Seguimiento'),
                          const SizedBox(height: 10),
                          Text(
                            'Reserva ${reservation['aircraftId'] ?? 'activa'}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111111),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${reservation['startDatetime']}',
                            style: const TextStyle(
                              color: Color(0xFF5F5F5F),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const _SignalWrap(
                            items: ['Ruta protegida', 'Concierge listo'],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 18),
          const _SectionHeading(
            title: 'Historial de vuelos y seguimiento',
            subtitle:
                'Registro limpio de movimientos dentro del portal cliente.',
          ),
          const SizedBox(height: 14),
          _RequestsTable(reservations: provider.reservations),
        ],
      ),
    );
  }

  String _activeRoute(ReservationProvider provider) {
    if (provider.routes.isEmpty) return 'Pendiente';
    final first = provider.routes.first;
    final origin =
        first.fromAirport?.iata ?? first.fromAirport?.city ?? 'Pendiente';
    final destination =
        first.toAirport?.iata ?? first.toAirport?.city ?? 'Pendiente';
    return '$origin -> $destination';
  }

  String _activeDate(ReservationProvider provider) {
    if (provider.startDate == null) return 'Sin fecha';
    final date = provider.startDate!;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class ClientPortalMembershipScreen extends StatelessWidget {
  const ClientPortalMembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final status = auth.isAuthenticated ? 'Activo' : 'Inactivo';

    return _PortalPage(
      title: 'Membresia',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          _PortalHero(
            eyebrow: 'Membresia',
            title: 'Administra tu cuenta con el mismo flujo cliente.',
            subtitle:
                'Consulta estado, beneficios y escalamiento sin salir del ecosistema.',
            trailing: FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ClientConciergeScreen(),
                  ),
                );
              },
              child: const Text('Hablar con concierge'),
            ),
          ),
          const SizedBox(height: 18),
          _MembershipStatusStrip(
            items: [
              _StatusItem(label: 'Acceso', value: status),
              const _StatusItem(label: 'Periodo', value: 'Premium'),
              const _StatusItem(label: 'Suscripcion', value: 'Sincronizada'),
              const _StatusItem(
                label: 'Operacion',
                value: 'Lista para reservar',
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _SectionHeading(
            title: 'Como evoluciona tu cuenta',
            subtitle:
                'La membresia ya no queda informativa: empuja al siguiente paso real.',
          ),
          const SizedBox(height: 14),
          const _TimelineGrid(
            steps: [
              _TimelineStage(
                meta: 'Paso 01',
                title: 'Activa tu acceso',
                description: 'Habilita reservas, seguimiento y concierge.',
                done: true,
              ),
              _TimelineStage(
                meta: 'Paso 02',
                title: 'Opera desde un mismo flujo',
                description: 'Mueve solicitudes, historial y cuenta premium.',
                done: true,
              ),
              _TimelineStage(
                meta: 'Paso 03',
                title: 'Escala cuando lo necesites',
                description: 'Prioridad, cobertura y control corporativo.',
                done: false,
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _SectionHeading(
            title: 'Niveles de membresia',
            subtitle: 'Mismas tarjetas de accion del portal web.',
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children:
                _packageOptions.map((plan) {
                  return SizedBox(
                    width: 280,
                    child: _PackageCard(
                      plan: plan,
                      selected: plan.name == 'Pro',
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

class ClientPortalProfileScreen extends StatelessWidget {
  const ClientPortalProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.user?.name ?? auth.demoUser?.label ?? 'Miembro Sky Group';
    final email =
        auth.user?.email ?? auth.demoUser?.email ?? 'cliente@skygroup.test';

    return _PortalPage(
      title: 'Perfil',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          _PortalHero(
            eyebrow: 'Perfil',
            title: 'Preferencias de vuelo dentro del portal cliente.',
            subtitle:
                'Datos, privacidad, empresa y preferencias con lectura clara.',
            trailing: const _TagLabel('Perfil protegido'),
          ),
          const SizedBox(height: 18),
          _MembershipStatusStrip(
            items: [
              _StatusItem(label: 'Cliente', value: name),
              _StatusItem(label: 'Correo', value: email),
              const _StatusItem(label: 'Metodo', value: 'Pendiente'),
              const _StatusItem(label: 'Privacidad', value: 'NDA listo'),
            ],
          ),
          const SizedBox(height: 18),
          const _SectionHeading(
            title: 'Preferencias de vuelo',
            subtitle: 'Mismo cierre de perfil que usa el portal web.',
          ),
          const SizedBox(height: 14),
          _SoftCard(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final fields = [
                  _ProfileField(label: 'Nombre', value: name),
                  _ProfileField(label: 'Telefono', value: '+52 55 0000 0000'),
                  _ProfileField(
                    label: 'Empresa',
                    value: auth.user?.name ?? 'Cuenta privada',
                  ),
                  _ProfileField(label: 'Correo', value: email),
                  const _ProfileField(
                    label: 'Preferencias',
                    value: 'Catering, FBO, asiento, privacidad y traslado',
                    wide: true,
                  ),
                ];

                if (constraints.maxWidth < 780) {
                  return Column(
                    children:
                        fields
                            .map(
                              (field) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: field,
                              ),
                            )
                            .toList(),
                  );
                }

                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children:
                      fields.map((field) {
                        final width =
                            field.wide
                                ? constraints.maxWidth
                                : (constraints.maxWidth - 14) / 2;
                        return SizedBox(width: width, child: field);
                      }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



