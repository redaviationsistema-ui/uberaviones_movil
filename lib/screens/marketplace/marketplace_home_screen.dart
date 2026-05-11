import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/marketplace_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reservation_provider.dart';
import '../admin/admin_dashboard_screen.dart';
import '../admin/views/admin_aircraft_screen.dart';
import '../admin/views/admin_finance_screen.dart';
import '../admin/views/admin_operators_screen.dart';
import '../admin/views/admin_support_screen.dart';
import '../cliente/client_portal_sections.dart';
import '../shared/static_role_screen.dart';
import '../shared/widgets/role_workspace_shell.dart';
import '../subscription/membership_center_screen.dart';

class MarketplaceHomeScreen extends StatelessWidget {
  const MarketplaceHomeScreen({super.key, required this.role});

  final AppUserRole role;

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case AppUserRole.client:
        return const _ClientWorkspaceScreen();
      case AppUserRole.operator:
        return const _OperatorWorkspaceScreen();
      case AppUserRole.crew:
        return const _CrewWorkspaceScreen();
      case AppUserRole.admin:
        return const _AdminWorkspaceScreen();
      case AppUserRole.unknown:
        return const _ClientWorkspaceScreen();
    }
  }
}

class _ClientWorkspaceScreen extends StatefulWidget {
  const _ClientWorkspaceScreen();

  @override
  State<_ClientWorkspaceScreen> createState() => _ClientWorkspaceScreenState();
}

class _ClientWorkspaceScreenState extends State<_ClientWorkspaceScreen> {
  bool _syncNoticeShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensurePortalDataLoaded();
    });
  }

  Future<void> _ensurePortalDataLoaded() async {
    final reservation = context.read<ReservationProvider>();
    if (reservation.isLoadingData) return;
    if (reservation.lastSyncAt != null && reservation.reservations.isNotEmpty) {
      return;
    }

    await reservation.loadClientPortalData();
    if (!mounted || _syncNoticeShown || reservation.syncMessage == null) return;

    _syncNoticeShown = true;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(reservation.syncMessage!)));
  }

  @override
  Widget build(BuildContext context) {
    return const RoleWorkspaceShell(
      branchLabel: 'Private Client',
      roleLabel: 'Elite Membership',
      title: 'SKY GROUP',
      insightTitle: 'Portal cliente',
      insightDescription:
          'Private Aviation • Instant Booking',
      items: [
        RoleWorkspaceItem(
          label: 'Buscar vuelo',
          shortLabel: 'Buscar',
          groupLabel: 'Booking',
          icon: Icons.search_rounded,
          description:
              'Cotiza, compara y reserva operadores verificados sin brokers.',
          screen: ClientPortalBookingScreen(),
        ),
        RoleWorkspaceItem(
          label: 'Mis vuelos',
          shortLabel: 'Vuelos',
          groupLabel: 'Mis vuelos',
          description: 'Seguimiento, timeline e historial dentro del portal.',
          icon: Icons.route_rounded,
          screen: ClientPortalTripsScreen(),
        ),
        RoleWorkspaceItem(
          label: 'Membresia',
          shortLabel: 'Plan',
          groupLabel: 'Membresia',
          description: 'Estado de cuenta, niveles y beneficios como en la web.',
          icon: Icons.workspace_premium_rounded,
          screen: ClientPortalMembershipScreen(),
        ),
        RoleWorkspaceItem(
          label: 'Perfil',
          shortLabel: 'Perfil',
          groupLabel: 'Perfil',
          description: 'Preferencias, privacidad y datos del cliente.',
          icon: Icons.manage_accounts_rounded,
          screen: ClientPortalProfileScreen(),
        ),
      ],
    );
  }
}

class _OperatorWorkspaceScreen extends StatelessWidget {
  const _OperatorWorkspaceScreen();

  @override
  Widget build(BuildContext context) {
    return const RoleWorkspaceShell(
      branchLabel: 'Operaciones',
      roleLabel: 'Proveedor certificado',
      title: 'Sky Group Operador',
      insightTitle: 'Coordinacion de flota y disponibilidad',
      insightDescription:
          'Visualiza tus operaciones activas, asignaciones y respuesta comercial en tiempo real.',
      items: [
        RoleWorkspaceItem(
          label: 'Dashboard',
          shortLabel: 'Inicio',
          groupLabel: 'Operacion',
          description: 'Centro de control del operador y panorama del dia.',
          icon: Icons.dashboard_customize_rounded,
          screen: _WorkspaceModuleScreen(
            title: 'Dashboard proveedor',
            subtitle:
                'Resumen de flota, solicitudes, operaciones y SLA del operador.',
            roleLabel: 'Proveedor',
            heroTitle: 'Controla disponibilidad, solicitudes y operacion',
            heroSubtitle:
                'Vista ejecutiva alineada al portal web para mantener costos, flota y asignaciones visibles.',
            metrics: [
              MarketplaceMetric(
                label: 'Aeronaves',
                value: '8 activas',
                helper: 'Flota lista para cotizar hoy.',
              ),
              MarketplaceMetric(
                label: 'Solicitudes',
                value: '6 nuevas',
                helper: 'Rutas esperando respuesta del operador.',
              ),
              MarketplaceMetric(
                label: 'SLA',
                value: '12 min',
                helper: 'Tiempo medio de primera respuesta.',
              ),
            ],
            actions: [
              StaticAction(
                icon: Icons.request_quote_rounded,
                label: 'Responder solicitudes',
                message: 'Abre el flujo de respuesta comercial.',
              ),
              StaticAction(
                icon: Icons.calendar_month_rounded,
                label: 'Actualizar agenda',
                message: 'Agenda y bloqueo listos para editar.',
              ),
              StaticAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filtrar',
                message: 'Muestra pendientes operativos.',
              ),
            ],
            records: [
              StaticRecord(
                title: 'TLC -> CUN',
                subtitle: 'Solicitud premium con salida hoy',
                status: 'Pendiente',
                amount: '\$18,900',
              ),
              StaticRecord(
                title: 'Citation CJ3',
                subtitle: 'Disponibilidad validada para agenda corta',
                status: 'Activo',
                amount: 'Libre',
              ),
            ],
            modules: [
              MarketplaceModule(
                title: 'Solicitudes',
                description: 'Entrada y respuesta comercial centralizadas.',
              ),
              MarketplaceModule(
                title: 'Flota',
                description: 'Disponibilidad, costos y estatus de aeronaves.',
              ),
              MarketplaceModule(
                title: 'Operacion',
                description: 'Seguimiento de vuelos y tripulacion.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CrewWorkspaceScreen extends StatelessWidget {
  const _CrewWorkspaceScreen();

  @override
  Widget build(BuildContext context) {
    return const RoleWorkspaceShell(
      branchLabel: 'Cabina',
      roleLabel: 'Sobrecargo',
      title: 'Sky Group Crew',
      insightTitle: 'Agenda, cabina y servicio',
      insightDescription:
          'Todo lo necesario para operar con orden, visibilidad y seguimiento claro.',
      items: [
        RoleWorkspaceItem(
          label: 'Centro Operativo',
          shortLabel: 'Inicio',
          groupLabel: 'Operacion',
          description: 'Resumen de misiones, checklist y briefing del dia.',
          icon: Icons.dashboard_customize_rounded,
          screen: _WorkspaceModuleScreen(
            title: 'Centro Operativo',
            subtitle:
                'Dashboard del sobrecargo con agenda, servicio y estado de readiness.',
            roleLabel: 'Sobrecargo',
            heroTitle: 'Cabina lista para cada servicio asignado',
            heroSubtitle:
                'Replica el portal web de crew con identidad operativa, tareas del dia y alertas documentales.',
            metrics: [
              MarketplaceMetric(
                label: 'Asignaciones',
                value: '2 activas',
                helper: 'Una en briefing y una en preparacion.',
              ),
              MarketplaceMetric(
                label: 'Readiness',
                value: '92%',
                helper: 'Score operativo de cabina y expediente.',
              ),
              MarketplaceMetric(
                label: 'Alertas',
                value: '1 abierta',
                helper: 'Incidencia de servicio bajo seguimiento.',
              ),
            ],
            actions: [
              StaticAction(
                icon: Icons.check_circle_outline_rounded,
                label: 'Confirmar servicio',
                message: 'Confirma disponibilidad y checklist de cabina.',
              ),
              StaticAction(
                icon: Icons.calendar_month_rounded,
                label: 'Ver agenda',
                message: 'Abre la operacion del dia y su timeline.',
              ),
              StaticAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filtrar',
                message: 'Muestra tareas pendientes y alertas.',
              ),
            ],
            records: [
              StaticRecord(
                title: 'TLC -> CUN | XA-SKY',
                subtitle: 'Briefing 08:00 | catering ligero | 6 pasajeros VIP',
                status: 'Pendiente',
                amount: 'Hoy',
              ),
              StaticRecord(
                title: 'Documentacion CRM',
                subtitle:
                    'Revision administrativa antes de vuelo internacional',
                status: 'Revision',
                amount: '15 dias',
              ),
            ],
            modules: [
              MarketplaceModule(
                title: 'Briefing',
                description: 'Ruta, tiempos, catering y servicio esperado.',
              ),
              MarketplaceModule(
                title: 'Checklist',
                description: 'Cabina, amenidades y confirmacion de readiness.',
              ),
              MarketplaceModule(
                title: 'Alertas',
                description: 'Incidencias y documentos por seguir.',
              ),
            ],
          ),
        ),
        RoleWorkspaceItem(
          label: 'Misiones',
          shortLabel: 'Misiones',
          groupLabel: 'Operacion',
          description: 'Asignaciones aceptadas, pendientes y finalizadas.',
          icon: Icons.assignment_turned_in_rounded,
          screen: _WorkspaceModuleScreen(
            title: 'Misiones',
            subtitle:
                'Control de asignaciones por vuelo, respuesta y trazabilidad del servicio.',
            roleLabel: 'Sobrecargo',
            heroTitle: 'Gestiona misiones con contexto completo',
            heroSubtitle:
                'Cada mision concentra ruta, horario, operador, aeronave y decisiones de aceptar o escalar.',
            metrics: [
              MarketplaceMetric(
                label: 'Pendientes',
                value: '1',
                helper: 'Requiere respuesta antes de las 11:00.',
              ),
              MarketplaceMetric(
                label: 'Confirmadas',
                value: '3',
                helper: 'Misiones listas para operar.',
              ),
              MarketplaceMetric(
                label: 'Finalizadas',
                value: '18',
                helper: 'Servicios cerrados durante el mes.',
              ),
            ],
            actions: [
              StaticAction(
                icon: Icons.check_rounded,
                label: 'Aceptar mision',
                message: 'La asignacion queda confirmada en la agenda.',
              ),
              StaticAction(
                icon: Icons.close_rounded,
                label: 'Rechazar',
                message: 'Se solicita revision al operador.',
              ),
              StaticAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filtrar',
                message: 'Muestra nuevas, activas o finalizadas.',
              ),
            ],
            records: [
              StaticRecord(
                title: 'Mision SG-1048',
                subtitle: 'Citation CJ3 | salida 09:30 | Toluca',
                status: 'Pendiente',
                amount: 'TLC-CUN',
              ),
              StaticRecord(
                title: 'Mision SG-1039',
                subtitle: 'Servicio completado con evidencia cargada',
                status: 'Finalizado',
                amount: 'MTY-SJD',
              ),
            ],
            modules: [
              MarketplaceModule(
                title: 'Respuesta',
                description: 'Aceptar, rechazar o pedir revision.',
              ),
              MarketplaceModule(
                title: 'Contexto',
                description: 'Ruta, briefing, amenidades y operador.',
              ),
              MarketplaceModule(
                title: 'Cierre',
                description: 'Evidencia, rating y auditoria de servicio.',
              ),
            ],
          ),
        ),
        RoleWorkspaceItem(
          label: 'Operacion del dia',
          shortLabel: 'Agenda',
          groupLabel: 'Operacion',
          description: 'Timeline diario de briefing, FBO y servicio.',
          icon: Icons.calendar_today_rounded,
          screen: _WorkspaceModuleScreen(
            title: 'Operacion del dia',
            subtitle:
                'Agenda, briefing, check-in y secuencia de momentos de servicio.',
            roleLabel: 'Sobrecargo',
            heroTitle: 'Linea de tiempo para la operacion diaria',
            heroSubtitle:
                'Vista estilo portal web para ejecutar el dia con claridad, horarios y responsables.',
            metrics: [
              MarketplaceMetric(
                label: 'Reporte',
                value: '07:45',
                helper: 'Hora objetivo de llegada al FBO.',
              ),
              MarketplaceMetric(
                label: 'Servicio',
                value: '09:30',
                helper: 'Inicio estimado de embarque y cabina.',
              ),
              MarketplaceMetric(
                label: 'Estado',
                value: 'Preparacion',
                helper: 'Checklist casi completo para salida.',
              ),
            ],
            actions: [
              StaticAction(
                icon: Icons.login_rounded,
                label: 'Iniciar check-in',
                message: 'Activa el timeline de llegada y briefing.',
              ),
              StaticAction(
                icon: Icons.event_note_rounded,
                label: 'Actualizar agenda',
                message: 'Sincroniza hora, base o cabina.',
              ),
              StaticAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filtrar',
                message: 'Muestra solo lo pendiente por operar.',
              ),
            ],
            records: [
              StaticRecord(
                title: 'Check-in FBO Toluca',
                subtitle: 'Llegada requerida 07:45 | briefing operador 08:00',
                status: 'Pendiente',
                amount: '07:45',
              ),
              StaticRecord(
                title: 'Servicio a bordo',
                subtitle: 'Catering ligero, WiFi y amenidades VIP',
                status: 'Activo',
                amount: '09:30',
              ),
            ],
            modules: [
              MarketplaceModule(
                title: 'Timeline',
                description: 'Desde briefing hasta cierre de servicio.',
              ),
              MarketplaceModule(
                title: 'Cabina',
                description: 'Amenidades, catering y pasajeros especiales.',
              ),
              MarketplaceModule(
                title: 'Coordinacion',
                description: 'Interaccion con operador y alertas del vuelo.',
              ),
            ],
          ),
        ),
        RoleWorkspaceItem(
          label: 'Disponibilidad',
          shortLabel: 'Disp.',
          groupLabel: 'Operacion',
          description: 'Bloqueos, horarios y cobertura de base.',
          icon: Icons.event_available_rounded,
          screen: _WorkspaceModuleScreen(
            title: 'Disponibilidad',
            subtitle:
                'Horarios disponibles, bloqueos y cobertura operativa del sobrecargo.',
            roleLabel: 'Sobrecargo',
            heroTitle: 'Publica disponibilidad para nuevas misiones',
            heroSubtitle:
                'El operador asigna con base en agenda, base, idiomas y certificaciones visibles.',
            metrics: [
              MarketplaceMetric(
                label: 'Base',
                value: 'Toluca',
                helper: 'Cobertura principal de operacion.',
              ),
              MarketplaceMetric(
                label: 'Cobertura',
                value: 'Centro / Bajio',
                helper: 'Radio preferente para nuevas asignaciones.',
              ),
              MarketplaceMetric(
                label: 'Estado',
                value: 'Disponible',
                helper: 'Listo para recibir una nueva mision.',
              ),
            ],
            actions: [
              StaticAction(
                icon: Icons.calendar_month_rounded,
                label: 'Actualizar agenda',
                message: 'Cambia ventanas, base y cobertura.',
              ),
              StaticAction(
                icon: Icons.block_rounded,
                label: 'Bloquear horario',
                message: 'Registra descanso, medico o capacitacion.',
              ),
              StaticAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filtrar',
                message: 'Muestra bloqueos y disponibilidad actual.',
              ),
            ],
            records: [
              StaticRecord(
                title: 'Disponible TLC',
                subtitle: 'Lunes a viernes | 06:00 - 18:00',
                status: 'Activo',
                amount: 'TLC',
              ),
              StaticRecord(
                title: 'Capacitacion recurrente',
                subtitle: 'Bloqueo personal para certificacion',
                status: 'Bloqueado',
                amount: '2 dias',
              ),
            ],
            modules: [
              MarketplaceModule(
                title: 'Agenda de cabina',
                description: 'Ventanas operativas y bloqueos personales.',
              ),
              MarketplaceModule(
                title: 'Cobertura',
                description: 'Base, region y restricciones de servicio.',
              ),
              MarketplaceModule(
                title: 'Visibilidad',
                description: 'Estado disponible para matching operativo.',
              ),
            ],
          ),
        ),
        RoleWorkspaceItem(
          label: 'Perfil de vuelo',
          shortLabel: 'Perfil',
          groupLabel: 'Cuenta',
          description: 'Datos, experiencia, rating y certificaciones.',
          icon: Icons.badge_rounded,
          screen: _WorkspaceModuleScreen(
            title: 'Perfil de vuelo',
            subtitle:
                'Perfil profesional del sobrecargo con base, documentos y readiness.',
            roleLabel: 'Sobrecargo',
            heroTitle: 'Mantiene visible tu expediente operativo',
            heroSubtitle:
                'Replica el portal de crew con informacion personal, idiomas, experiencia y estado documental.',
            metrics: [
              MarketplaceMetric(
                label: 'Nivel',
                value: 'Ejecutivo',
                helper: 'Perfil listo para servicio premium.',
              ),
              MarketplaceMetric(
                label: 'Idiomas',
                value: 'ES / EN',
                helper: 'Atencion corporativa e internacional.',
              ),
              MarketplaceMetric(
                label: 'Rating',
                value: '4.9/5',
                helper: 'Calificacion consolidada de servicio.',
              ),
            ],
            actions: [
              StaticAction(
                icon: Icons.edit_rounded,
                label: 'Editar datos',
                message: 'Actualiza telefono, base y experiencia.',
              ),
              StaticAction(
                icon: Icons.verified_rounded,
                label: 'Actualizar certificacion',
                message: 'Carga o ajusta certificaciones del perfil.',
              ),
              StaticAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filtrar',
                message: 'Muestra solo documentos o validaciones.',
              ),
            ],
            records: [
              StaticRecord(
                title: 'Andrea Ruiz',
                subtitle: 'Sobrecargo | base TLC | ingles avanzado',
                status: 'Activo',
                amount: '4.9/5',
              ),
              StaticRecord(
                title: 'Certificacion CRM',
                subtitle: 'Vigencia pendiente de revision administrativa',
                status: 'Revision',
                amount: '2026',
              ),
            ],
            modules: [
              MarketplaceModule(
                title: 'Perfil',
                description: 'Datos, base, idiomas y experiencia.',
              ),
              MarketplaceModule(
                title: 'Readiness',
                description: 'Score operativo y estado del expediente.',
              ),
              MarketplaceModule(
                title: 'Validaciones',
                description: 'Revision administrativa de documentos.',
              ),
            ],
          ),
        ),
        RoleWorkspaceItem(
          label: 'Documentos',
          shortLabel: 'Docs',
          groupLabel: 'Seguimiento',
          description: 'Certificados, identificaciones y vencimientos.',
          icon: Icons.folder_copy_rounded,
          screen: _WorkspaceModuleScreen(
            title: 'Documentos',
            subtitle:
                'Centro documental de cabina con vigencias, categorias y alertas.',
            roleLabel: 'Sobrecargo',
            heroTitle: 'Controla certificados y documentos por vencer',
            heroSubtitle:
                'La experiencia sigue el portal web de cabina con visibilidad clara para vigencia y cumplimiento.',
            metrics: [
              MarketplaceMetric(
                label: 'Aprobados',
                value: '5',
                helper: 'Documentos validados por administracion.',
              ),
              MarketplaceMetric(
                label: 'Pendientes',
                value: '1',
                helper: 'Archivo en revision documental.',
              ),
              MarketplaceMetric(
                label: 'Vencimiento',
                value: '20 dias',
                helper: 'Curso recurrente mas cercano por expirar.',
              ),
            ],
            actions: [
              StaticAction(
                icon: Icons.upload_file_rounded,
                label: 'Cargar documento',
                message: 'Sube un archivo nuevo al expediente.',
              ),
              StaticAction(
                icon: Icons.notifications_active_rounded,
                label: 'Ver alertas',
                message: 'Filtra vencimientos y rechazos.',
              ),
              StaticAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filtrar',
                message: 'Muestra solo documentos criticos.',
              ),
            ],
            records: [
              StaticRecord(
                title: 'Pasaporte',
                subtitle: 'Documento internacional validado',
                status: 'Activo',
                amount: 'Vigente',
              ),
              StaticRecord(
                title: 'Curso recurrente',
                subtitle: 'Requiere actualizacion antes de fin de mes',
                status: 'Pendiente',
                amount: '20 dias',
              ),
            ],
            modules: [
              MarketplaceModule(
                title: 'Vigencias',
                description: 'Semaforo y proximidad de renovacion.',
              ),
              MarketplaceModule(
                title: 'Categorias',
                description: 'Certificados, identificaciones y cursos.',
              ),
              MarketplaceModule(
                title: 'Expediente',
                description: 'Revision y aprobacion administrativa.',
              ),
            ],
          ),
        ),
        RoleWorkspaceItem(
          label: 'Incidencias',
          shortLabel: 'Alertas',
          groupLabel: 'Seguimiento',
          description: 'Reportes de servicio, seguridad y pasajeros.',
          icon: Icons.report_problem_rounded,
          screen: _WorkspaceModuleScreen(
            title: 'Incidencias',
            subtitle:
                'Registro de incidentes, evidencia y resolucion operativa del servicio.',
            roleLabel: 'Sobrecargo',
            heroTitle: 'Reporta incidencias con trazabilidad',
            heroSubtitle:
                'Conserva evidencia, prioridad, responsables y cierre dentro del flujo de cabina.',
            metrics: [
              MarketplaceMetric(
                label: 'Abiertas',
                value: '1',
                helper: 'Caso activo en seguimiento del operador.',
              ),
              MarketplaceMetric(
                label: 'Criticas',
                value: '0',
                helper: 'Sin incidentes de impacto alto hoy.',
              ),
              MarketplaceMetric(
                label: 'Tiempo medio',
                value: '24 min',
                helper: 'Promedio reciente de respuesta inicial.',
              ),
            ],
            actions: [
              StaticAction(
                icon: Icons.add_alert_rounded,
                label: 'Crear incidencia',
                message: 'Registra el evento dentro del portal.',
              ),
              StaticAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filtrar',
                message: 'Muestra abiertas, escaladas o cerradas.',
              ),
              StaticAction(
                icon: Icons.photo_camera_rounded,
                label: 'Subir evidencia',
                message: 'Agrega fotos o notas del incidente.',
              ),
            ],
            records: [
              StaticRecord(
                title: 'Amenidad faltante',
                subtitle: 'Catering especial no entregado en FBO',
                status: 'Pendiente',
                amount: 'Media',
              ),
              StaticRecord(
                title: 'Demora de abordaje',
                subtitle: 'Pasajero llego 18 minutos tarde',
                status: 'Confirmado',
                amount: '18 min',
              ),
            ],
            modules: [
              MarketplaceModule(
                title: 'Registro rapido',
                description: 'Tipo, prioridad y descripcion del evento.',
              ),
              MarketplaceModule(
                title: 'Evidencia',
                description: 'Fotos, notas y datos del servicio.',
              ),
              MarketplaceModule(
                title: 'Resolucion',
                description:
                    'Seguimiento del operador y cierre administrativo.',
              ),
            ],
          ),
        ),
        RoleWorkspaceItem(
          label: 'Historial',
          shortLabel: 'Historial',
          groupLabel: 'Seguimiento',
          description: 'Servicios realizados, horas y calificaciones.',
          icon: Icons.history_rounded,
          screen: _WorkspaceModuleScreen(
            title: 'Historial',
            subtitle:
                'Servicios finalizados, ratings y auditoria de desempeno en cabina.',
            roleLabel: 'Sobrecargo',
            heroTitle: 'Consulta tu historial operativo y nivel de servicio',
            heroSubtitle:
                'Permite revisar rutas, evaluaciones, horas y consistencia del desempeno.',
            metrics: [
              MarketplaceMetric(
                label: 'Servicios',
                value: '18',
                helper: 'Misiones completadas este mes.',
              ),
              MarketplaceMetric(
                label: 'Horas',
                value: '412 h',
                helper: 'Carga operativa consolidada.',
              ),
              MarketplaceMetric(
                label: 'Puntualidad',
                value: '98%',
                helper: 'Indicador de cumplimiento del servicio.',
              ),
            ],
            actions: [
              StaticAction(
                icon: Icons.download_rounded,
                label: 'Exportar reporte',
                message: 'Genera resumen del historial operativo.',
              ),
              StaticAction(
                icon: Icons.visibility_rounded,
                label: 'Ver detalle',
                message: 'Abre evaluaciones y notas por servicio.',
              ),
              StaticAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filtrar',
                message: 'Filtra por fecha, estado o ruta.',
              ),
            ],
            records: [
              StaticRecord(
                title: 'TLC -> CUN',
                subtitle: 'Servicio finalizado sin incidencias',
                status: 'Finalizado',
                amount: '5.0',
              ),
              StaticRecord(
                title: 'MTY -> SJD',
                subtitle: 'Cliente corporativo | notas positivas',
                status: 'Finalizado',
                amount: '4.8',
              ),
            ],
            modules: [
              MarketplaceModule(
                title: 'Servicios',
                description: 'Misiones y resultados por vuelo.',
              ),
              MarketplaceModule(
                title: 'Desempeno',
                description: 'Rating, puntualidad y comentarios.',
              ),
              MarketplaceModule(
                title: 'Auditoria',
                description: 'Historial visible para cabina y admin.',
              ),
            ],
          ),
        ),
        RoleWorkspaceItem(
          label: 'Ajustes',
          shortLabel: 'Ajustes',
          groupLabel: 'Cuenta',
          description: 'Preferencias, notificaciones y seguridad.',
          icon: Icons.settings_rounded,
          screen: _WorkspaceModuleScreen(
            title: 'Ajustes',
            subtitle:
                'Configuracion personal del portal de cabina y notificaciones operativas.',
            roleLabel: 'Sobrecargo',
            heroTitle: 'Configura tu portal de cabina',
            heroSubtitle:
                'Gestiona alertas, base preferente, canal de contacto y privacidad operativa.',
            metrics: [
              MarketplaceMetric(
                label: 'Push',
                value: 'Activo',
                helper: 'Misiones y cambios de horario notificados.',
              ),
              MarketplaceMetric(
                label: 'Cobertura',
                value: 'Centro / Bajio',
                helper: 'Region preferente de operacion.',
              ),
              MarketplaceMetric(
                label: 'Escalamiento',
                value: 'Operador',
                helper: 'Ruta primaria de soporte para incidentes.',
              ),
            ],
            actions: [
              StaticAction(
                icon: Icons.tune_rounded,
                label: 'Cambiar preferencias',
                message: 'Actualiza ajustes del portal crew.',
              ),
              StaticAction(
                icon: Icons.phone_in_talk_rounded,
                label: 'Metodo de contacto',
                message: 'Configura telefono y alertas prioritarias.',
              ),
              StaticAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filtrar',
                message: 'Muestra ajustes activos o pendientes.',
              ),
            ],
            records: [
              StaticRecord(
                title: 'Notificaciones push',
                subtitle: 'Misiones, cambios de horario e incidencias',
                status: 'Activo',
                amount: 'On',
              ),
              StaticRecord(
                title: 'Base preferente',
                subtitle: 'Toluca con disponibilidad nacional',
                status: 'Activo',
                amount: 'TLC',
              ),
            ],
            modules: [
              MarketplaceModule(
                title: 'Alertas',
                description: 'Push, email y prioridad por tipo de evento.',
              ),
              MarketplaceModule(
                title: 'Cobertura',
                description: 'Base preferente, horarios y region.',
              ),
              MarketplaceModule(
                title: 'Privacidad',
                description: 'Control del perfil y datos operativos.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdminWorkspaceScreen extends StatelessWidget {
  const _AdminWorkspaceScreen();

  @override
  Widget build(BuildContext context) {
    return const RoleWorkspaceShell(
      branchLabel: 'Administracion',
      roleLabel: 'Administrador',
      title: 'Sky Group Admin',
      insightTitle: 'Control central de la plataforma',
      insightDescription:
          'Supervisa usuarios, indicadores, alertas y operacion general desde una vista ejecutiva.',
      items: [
        RoleWorkspaceItem(
          label: 'Dashboard',
          shortLabel: 'Inicio',
          groupLabel: 'Ejecutivo',
          description: 'KPIs, gobierno y estado general del marketplace.',
          icon: Icons.dashboard_rounded,
          screen: AdminDashboardScreen(),
        ),
        RoleWorkspaceItem(
          label: 'Importaciones / Exportaciones',
          shortLabel: 'Transfer',
          groupLabel: 'Ejecutivo',
          description: 'Control de cargas, descargas y gobierno de datos.',
          icon: Icons.import_export_rounded,
          screen: _WorkspaceModuleScreen(
            title: 'Importaciones y exportaciones',
            subtitle:
                'Transferencia administrativa de datos, catálogos y reportes.',
            roleLabel: 'Administrador',
            heroTitle: 'Gobierna cargas masivas y exportaciones del sistema',
            heroSubtitle:
                'Seccion inspirada en el portal web para mover informacion con trazabilidad y control.',
            metrics: [
              MarketplaceMetric(
                label: 'Jobs',
                value: '6 hoy',
                helper: 'Procesos de importacion y exportacion recientes.',
              ),
              MarketplaceMetric(
                label: 'Errores',
                value: '1',
                helper: 'Archivo con validacion pendiente.',
              ),
              MarketplaceMetric(
                label: 'Esquemas',
                value: '12',
                helper: 'Colecciones listas para transferencia.',
              ),
            ],
            actions: [
              StaticAction(
                icon: Icons.upload_file_rounded,
                label: 'Crear importacion',
                message: 'Carga masiva lista para validarse.',
              ),
              StaticAction(
                icon: Icons.download_rounded,
                label: 'Exportar reporte',
                message: 'Prepara un archivo administrativo.',
              ),
              StaticAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filtrar',
                message: 'Muestra exitos, errores o pendientes.',
              ),
            ],
            records: [
              StaticRecord(
                title: 'flight_requests.csv',
                subtitle: 'Solicitud de carga de marketplace',
                status: 'Pendiente',
                amount: '1,240 filas',
              ),
              StaticRecord(
                title: 'pagos_abril.xlsx',
                subtitle: 'Exportacion lista para conciliacion',
                status: 'Confirmado',
                amount: 'Exportado',
              ),
            ],
            modules: [
              MarketplaceModule(
                title: 'Esquemas',
                description: 'Colecciones, columnas y formatos esperados.',
              ),
              MarketplaceModule(
                title: 'Validacion',
                description: 'Errores, previsualizacion y auditoria.',
              ),
              MarketplaceModule(
                title: 'Historial',
                description: 'Jobs ejecutados y trazabilidad del admin.',
              ),
            ],
          ),
        ),
        RoleWorkspaceItem(
          label: 'Usuarios y roles',
          shortLabel: 'Usuarios',
          groupLabel: 'Ejecutivo',
          description: 'Accesos, permisos y gobierno transversal de cuentas.',
          icon: Icons.people_alt_rounded,
          screen: _WorkspaceModuleScreen(
            title: 'Usuarios y roles',
            subtitle:
                'Gestion central de accesos para clientes, operadores, sobrecargos y admins.',
            roleLabel: 'Administrador',
            heroTitle: 'Administra roles, permisos y estatus de acceso',
            heroSubtitle:
                'Seccion alineada al portal ejecutivo para altas, bloqueos y control de identidad.',
            metrics: [
              MarketplaceMetric(
                label: 'Usuarios',
                value: '379',
                helper: 'Cuentas registradas en la plataforma.',
              ),
              MarketplaceMetric(
                label: 'Admins',
                value: '6',
                helper: 'Equipo interno con permisos ejecutivos.',
              ),
              MarketplaceMetric(
                label: 'Bloqueados',
                value: '4',
                helper: 'Cuentas suspendidas temporalmente.',
              ),
            ],
            actions: [
              StaticAction(
                icon: Icons.person_add_rounded,
                label: 'Crear usuario',
                message: 'Alta de usuario lista para capturarse.',
              ),
              StaticAction(
                icon: Icons.verified_user_rounded,
                label: 'Activar cuenta',
                message: 'Cuenta habilitada para operar.',
              ),
              StaticAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filtrar',
                message: 'Filtra por rol, estado o branch.',
              ),
            ],
            records: [
              StaticRecord(
                title: 'Mariana Torres',
                subtitle: 'Cliente premium con demo activa',
                status: 'Activo',
                amount: 'Cliente',
              ),
              StaticRecord(
                title: 'Ana Lira',
                subtitle: 'Sobrecargo con expediente en revision',
                status: 'Pendiente',
                amount: 'Crew',
              ),
            ],
            modules: [
              MarketplaceModule(
                title: 'Roles',
                description: 'Cliente, operador, crew y admin.',
              ),
              MarketplaceModule(
                title: 'Permisos',
                description: 'Acceso segun funcion dentro del negocio.',
              ),
              MarketplaceModule(
                title: 'Estado',
                description: 'Activo, revision, bloqueado o suspendido.',
              ),
            ],
          ),
        ),
        RoleWorkspaceItem(
          label: 'Analytics',
          shortLabel: 'Analytics',
          groupLabel: 'Ejecutivo',
          description: 'Conversion, utilizacion de flota y KPIs globales.',
          icon: Icons.query_stats_rounded,
          screen: _WorkspaceModuleScreen(
            title: 'Analytics',
            subtitle:
                'KPIs ejecutivos para ventas, reservas, operacion y rentabilidad.',
            roleLabel: 'Administrador',
            heroTitle: 'Lee el negocio con analitica util y accionable',
            heroSubtitle:
                'Concentra conversion, demanda, tiempos de asignacion, margen y productividad operativa.',
            metrics: [
              MarketplaceMetric(
                label: 'Conversion',
                value: '38%',
                helper: 'De cotizacion a reserva confirmada.',
              ),
              MarketplaceMetric(
                label: 'Utilizacion',
                value: '84%',
                helper: 'Uso consolidado de flota durante el periodo.',
              ),
              MarketplaceMetric(
                label: 'Asignacion',
                value: '11 min',
                helper: 'Tiempo medio de respuesta operativa.',
              ),
            ],
            actions: [
              StaticAction(
                icon: Icons.download_rounded,
                label: 'Exportar reporte',
                message: 'Genera archivo ejecutivo con KPIs.',
              ),
              StaticAction(
                icon: Icons.date_range_rounded,
                label: 'Cambiar periodo',
                message: 'Filtra el rango de tiempo a analizar.',
              ),
              StaticAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filtrar',
                message: 'Muestra vistas por area o rol.',
              ),
            ],
            records: [
              StaticRecord(
                title: 'Conversion comercial',
                subtitle: 'Cotizacion a reserva confirmada del mes',
                status: 'Activo',
                amount: '38%',
              ),
              StaticRecord(
                title: 'Utilizacion flota',
                subtitle: 'Horas activas sobre inventario disponible',
                status: 'Confirmado',
                amount: '84%',
              ),
            ],
            modules: [
              MarketplaceModule(
                title: 'Comercial',
                description: 'Conversion, ticket y precio medio.',
              ),
              MarketplaceModule(
                title: 'Operacion',
                description: 'SLA, ocupacion y salud del sistema.',
              ),
              MarketplaceModule(
                title: 'Finanzas',
                description: 'Margen, fees y payouts agregados.',
              ),
            ],
          ),
        ),
        RoleWorkspaceItem(
          label: 'Configuracion',
          shortLabel: 'Config',
          groupLabel: 'Ejecutivo',
          description: 'Reglas del sistema, demos y parametros generales.',
          icon: Icons.settings_rounded,
          screen: _WorkspaceModuleScreen(
            title: 'Configuracion',
            subtitle:
                'Reglas comerciales, permisos, banners y parametros globales del sistema.',
            roleLabel: 'Administrador',
            heroTitle: 'Configura como opera la plataforma',
            heroSubtitle:
                'Administra mensajes, permisos, roles activos, demo y reglas de conversion.',
            metrics: [
              MarketplaceMetric(
                label: 'Roles',
                value: '4',
                helper: 'Cliente, operador, crew y admin.',
              ),
              MarketplaceMetric(
                label: 'Banners',
                value: '3',
                helper: 'Mensajes visibles en momentos criticos.',
              ),
              MarketplaceMetric(
                label: 'Flags',
                value: '12',
                helper: 'Parametros activos del producto.',
              ),
            ],
            actions: [
              StaticAction(
                icon: Icons.tune_rounded,
                label: 'Editar planes',
                message: 'Abre el centro de configuracion comercial.',
              ),
              StaticAction(
                icon: Icons.campaign_rounded,
                label: 'Mensaje sistema',
                message: 'Configura comunicacion general de la app.',
              ),
              StaticAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filtrar',
                message: 'Muestra roles, permisos o banners.',
              ),
            ],
            records: [
              StaticRecord(
                title: 'Banner upgrade',
                subtitle: 'Visible cuando faltan 3 dias de demo',
                status: 'Activo',
                amount: '3 dias',
              ),
              StaticRecord(
                title: 'Permisos crew',
                subtitle: 'Acceso acotado a operacion asignada',
                status: 'Confirmado',
                amount: 'Activo',
              ),
            ],
            modules: [
              MarketplaceModule(
                title: 'Producto',
                description: 'Mensajes, flags y reglas visibles.',
              ),
              MarketplaceModule(
                title: 'Permisos',
                description: 'Acceso por rol y experiencia de usuario.',
              ),
              MarketplaceModule(
                title: 'Conversion',
                description: 'Banners, CTA y ventanas de demo.',
              ),
            ],
          ),
        ),
        RoleWorkspaceItem(
          label: 'Clientes',
          shortLabel: 'Clientes',
          groupLabel: 'Comercial',
          description: 'Cuentas VIP, historiales y perfil de servicio.',
          icon: Icons.person_rounded,
          screen: _WorkspaceModuleScreen(
            title: 'Clientes',
            subtitle:
                'Gestion integral de cuentas cliente, historial, preferencias y riesgo.',
            roleLabel: 'Administrador',
            heroTitle: 'Controla clientes y contexto comercial completo',
            heroSubtitle:
                'Permite altas, clasificacion VIP, historial de viajes y validacion fiscal.',
            metrics: [
              MarketplaceMetric(
                label: 'VIP',
                value: '28',
                helper: 'Cuentas con prioridad y SLA premium.',
              ),
              MarketplaceMetric(
                label: 'Corporativos',
                value: '14',
                helper: 'Empresas con multiples viajeros y contratos.',
              ),
              MarketplaceMetric(
                label: 'Riesgo',
                value: '2',
                helper: 'Perfiles con seguimiento manual.',
              ),
            ],
            actions: [
              StaticAction(
                icon: Icons.person_add_rounded,
                label: 'Crear cliente',
                message: 'Alta comercial lista para iniciar.',
              ),
              StaticAction(
                icon: Icons.verified_rounded,
                label: 'Validar perfil fiscal',
                message: 'Activa el flujo de validacion fiscal.',
              ),
              StaticAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filtrar',
                message: 'Segmenta por tipo, estatus o riesgo.',
              ),
            ],
            records: [
              StaticRecord(
                title: 'Mariana Torres',
                subtitle: 'Cliente VIP con 12 dias de demo',
                status: 'Activo',
                amount: 'VIP',
              ),
              StaticRecord(
                title: 'NorthBridge Capital',
                subtitle: 'Cuenta corporativa con multiples contactos',
                status: 'Confirmado',
                amount: 'Corp',
              ),
            ],
            modules: [
              MarketplaceModule(
                title: 'Perfil',
                description: 'Datos, empresa y preferencias del cliente.',
              ),
              MarketplaceModule(
                title: 'Historial',
                description: 'Reservas, cotizaciones y pagos.',
              ),
              MarketplaceModule(
                title: 'Riesgo',
                description: 'Flags internos y seguimiento comercial.',
              ),
            ],
          ),
        ),
        RoleWorkspaceItem(
          label: 'Reservas',
          shortLabel: 'Reservas',
          groupLabel: 'Comercial',
          description: 'Solicitudes, cambios y estado integral del booking.',
          icon: Icons.calendar_month_rounded,
          screen: _WorkspaceModuleScreen(
            title: 'Solicitudes / Reservas',
            subtitle:
                'Gestion del ciclo completo desde solicitud hasta operacion finalizada.',
            roleLabel: 'Administrador',
            heroTitle: 'Coordina reservas con visibilidad ejecutiva',
            heroSubtitle:
                'Seccion central del portal para revisar estado, reasignar recursos y controlar penalizaciones.',
            metrics: [
              MarketplaceMetric(
                label: 'Pendientes',
                value: '9',
                helper: 'Solicitudes aun en revision.',
              ),
              MarketplaceMetric(
                label: 'Confirmadas',
                value: '12',
                helper: 'Reservas listas para operar.',
              ),
              MarketplaceMetric(
                label: 'Canceladas',
                value: '2',
                helper: 'Casos con penalizacion o reembolso.',
              ),
            ],
            actions: [
              StaticAction(
                icon: Icons.add_circle_outline_rounded,
                label: 'Crear reserva',
                message: 'Alta manual de booking lista.',
              ),
              StaticAction(
                icon: Icons.swap_horiz_rounded,
                label: 'Reasignar aeronave',
                message: 'Ajusta recursos sin salir del portal.',
              ),
              StaticAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filtrar',
                message: 'Muestra por estado o prioridad.',
              ),
            ],
            records: [
              StaticRecord(
                title: 'Reserva SG-1048',
                subtitle: 'Cliente premium | 6 pasajeros | operador asignado',
                status: 'Pendiente',
                amount: 'TLC-CUN',
              ),
              StaticRecord(
                title: 'Reserva SG-1039',
                subtitle: 'Contrato firmado y pago validado',
                status: 'Confirmado',
                amount: 'MTY-SJD',
              ),
            ],
            modules: [
              MarketplaceModule(
                title: 'Solicitud',
                description: 'Entrada comercial y datos del viaje.',
              ),
              MarketplaceModule(
                title: 'Asignacion',
                description: 'Aeronave, operador y crew del vuelo.',
              ),
              MarketplaceModule(
                title: 'Control',
                description: 'Contrato, pago y estatus operativo.',
              ),
            ],
          ),
        ),
        RoleWorkspaceItem(
          label: 'Pricing',
          shortLabel: 'Pricing',
          groupLabel: 'Comercial',
          description: 'Cotizaciones, margen y fee de plataforma.',
          icon: Icons.price_change_rounded,
          screen: _WorkspaceModuleScreen(
            title: 'Cotizaciones / Pricing',
            subtitle:
                'Costo proveedor, margen y precio final por operacion para control ejecutivo.',
            roleLabel: 'Administrador',
            heroTitle: 'Controla pricing y rentabilidad por servicio',
            heroSubtitle:
                'Replica el flujo web donde admin crea, ajusta y valida cotizaciones con contexto financiero.',
            metrics: [
              MarketplaceMetric(
                label: 'Activas',
                value: '15',
                helper: 'Cotizaciones dentro de vigencia.',
              ),
              MarketplaceMetric(
                label: 'Margen',
                value: '29%',
                helper: 'Promedio actual del portafolio.',
              ),
              MarketplaceMetric(
                label: 'Vencidas',
                value: '3',
                helper: 'Requieren ajuste o nueva propuesta.',
              ),
            ],
            actions: [
              StaticAction(
                icon: Icons.add_chart_rounded,
                label: 'Crear cotizacion',
                message: 'Nueva propuesta lista para elaborarse.',
              ),
              StaticAction(
                icon: Icons.percent_rounded,
                label: 'Actualizar margen',
                message: 'Ajusta fee o rentabilidad del vuelo.',
              ),
              StaticAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filtrar',
                message: 'Muestra activas, vencidas o aprobadas.',
              ),
            ],
            records: [
              StaticRecord(
                title: 'COT-1048',
                subtitle: 'Ruta TLC-CUN con margen revisado',
                status: 'Pendiente',
                amount: '29%',
              ),
              StaticRecord(
                title: 'COT-1054',
                subtitle: 'Oferta internacional fuera de vigencia',
                status: 'Vencida',
                amount: '\$34,700',
              ),
            ],
            modules: [
              MarketplaceModule(
                title: 'Costo base',
                description: 'Costo operador y fee de plataforma.',
              ),
              MarketplaceModule(
                title: 'Oferta',
                description: 'Precio cliente, vigencia y descuentos.',
              ),
              MarketplaceModule(
                title: 'Margen',
                description: 'Control ejecutivo de rentabilidad.',
              ),
            ],
          ),
        ),
        RoleWorkspaceItem(
          label: 'Paquetes',
          shortLabel: 'Paquetes',
          groupLabel: 'Comercial',
          description: 'Membresias, beneficios y oferta comercial activa.',
          icon: Icons.card_membership_rounded,
          screen: _WorkspaceModuleScreen(
            title: 'Paquetes',
            subtitle:
                'Catalogo de planes, beneficios y visibilidad comercial para clientes.',
            roleLabel: 'Administrador',
            heroTitle: 'Administra paquetes y valor comercial de la plataforma',
            heroSubtitle:
                'Permite configurar categorias, beneficios concierge y niveles de servicio visibles.',
            metrics: [
              MarketplaceMetric(
                label: 'Activos',
                value: '6',
                helper: 'Paquetes visibles en la oferta.',
              ),
              MarketplaceMetric(
                label: 'Corporativos',
                value: '2',
                helper: 'Planes para cuentas enterprise.',
              ),
              MarketplaceMetric(
                label: 'Ocultos',
                value: '1',
                helper: 'No visible en la venta actual.',
              ),
            ],
            actions: [
              StaticAction(
                icon: Icons.add_box_rounded,
                label: 'Crear paquete',
                message: 'Alta comercial lista para editar.',
              ),
              StaticAction(
                icon: Icons.edit_rounded,
                label: 'Actualizar beneficios',
                message: 'Edita valor comercial del paquete.',
              ),
              StaticAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filtrar',
                message: 'Muestra activos, ocultos o enterprise.',
              ),
            ],
            records: [
              StaticRecord(
                title: 'Plan Ejecutivo',
                subtitle: 'Horas preferentes, concierge y prioridad',
                status: 'Activo',
                amount: '\$249/mes',
              ),
              StaticRecord(
                title: 'Plan Corporativo',
                subtitle: 'Acceso multiusuario y contratos empresariales',
                status: 'Confirmado',
                amount: 'Enterprise',
              ),
            ],
            modules: [
              MarketplaceModule(
                title: 'Catalogo',
                description: 'Planes visibles para clientes y empresas.',
              ),
              MarketplaceModule(
                title: 'Beneficios',
                description: 'Horas, SLA, concierge y add-ons.',
              ),
              MarketplaceModule(
                title: 'Visibilidad',
                description: 'Reglas para mostrar o pausar paquetes.',
              ),
            ],
          ),
        ),
        RoleWorkspaceItem(
          label: 'Suscripciones',
          shortLabel: 'Subs',
          groupLabel: 'Comercial',
          description: 'Demos, planes activos y conversion comercial.',
          icon: Icons.workspace_premium_rounded,
          screen: MembershipCenterScreen(audience: MembershipAudience.admin),
        ),
        RoleWorkspaceItem(
          label: 'Pagos / Finanzas',
          shortLabel: 'Pagos',
          groupLabel: 'Comercial',
          description: 'Cobros, payouts, comisiones y conciliacion.',
          icon: Icons.account_balance_wallet_rounded,
          screen: AdminFinanceScreen(),
        ),
        RoleWorkspaceItem(
          label: 'Proveedores',
          shortLabel: 'Prov.',
          groupLabel: 'Operacion',
          description: 'Red de partners, SLA y cumplimiento.',
          icon: Icons.groups_rounded,
          screen: _WorkspaceModuleScreen(
            title: 'Proveedores',
            subtitle:
                'Control de partners, disponibilidad, documentos y estado comercial.',
            roleLabel: 'Administrador',
            heroTitle:
                'Gestiona la red de proveedores con visibilidad completa',
            heroSubtitle:
                'La operacion central revisa SLA, documentos, flota y estatus de cada partner.',
            metrics: [
              MarketplaceMetric(
                label: 'Activos',
                value: '18',
                helper: 'Partners con acceso y SLA vigente.',
              ),
              MarketplaceMetric(
                label: 'En pausa',
                value: '3',
                helper: 'Proveedores temporalmente deshabilitados.',
              ),
              MarketplaceMetric(
                label: 'Cumplimiento',
                value: '87%',
                helper: 'Salud documental consolidada.',
              ),
            ],
            actions: [
              StaticAction(
                icon: Icons.add_business_rounded,
                label: 'Crear proveedor',
                message: 'Alta de partner lista para iniciar.',
              ),
              StaticAction(
                icon: Icons.assignment_turned_in_rounded,
                label: 'Revisar SLA',
                message: 'Analiza cumplimiento y calidad del proveedor.',
              ),
              StaticAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filtrar',
                message: 'Muestra activos, pausa o incidencias.',
              ),
            ],
            records: [
              StaticRecord(
                title: 'Sky Operator',
                subtitle: 'Partner con contrato vigente y flota visible',
                status: 'Activo',
                amount: '98%',
              ),
              StaticRecord(
                title: 'Executive Wings',
                subtitle: 'Observaciones documentales por corregir',
                status: 'Pendiente',
                amount: 'SLA 92%',
              ),
            ],
            modules: [
              MarketplaceModule(
                title: 'Perfil',
                description: 'Empresa, contacto y bases operativas.',
              ),
              MarketplaceModule(
                title: 'Cumplimiento',
                description: 'Contrato, SLA y documentos vigentes.',
              ),
              MarketplaceModule(
                title: 'Flota',
                description: 'Aeronaves publicadas y estado comercial.',
              ),
            ],
          ),
        ),
        RoleWorkspaceItem(
          label: 'Aeronaves',
          shortLabel: 'Flota',
          groupLabel: 'Operacion',
          description: 'Revision de matriculas, documentos y liberacion.',
          icon: Icons.flight_class_rounded,
          screen: AdminAircraftScreen(),
        ),
        RoleWorkspaceItem(
          label: 'Operadores',
          shortLabel: 'Ops',
          groupLabel: 'Operacion',
          description: 'Turnos, permisos y performance del equipo.',
          icon: Icons.support_agent_rounded,
          screen: AdminOperatorsScreen(),
        ),
        RoleWorkspaceItem(
          label: 'Sobrecargos',
          shortLabel: 'Crew',
          groupLabel: 'Operacion',
          description: 'Disponibilidad, certificaciones y pagos del crew.',
          icon: Icons.badge_rounded,
          screen: _WorkspaceModuleScreen(
            title: 'Sobrecargos',
            subtitle:
                'Supervision de disponibilidad, certificaciones, agenda y pagos del equipo de cabina.',
            roleLabel: 'Administrador',
            heroTitle: 'Monitorea al equipo de cabina desde un solo tablero',
            heroSubtitle:
                'Replica la vista web para readiness, agenda, rating y estado documental del crew.',
            metrics: [
              MarketplaceMetric(
                label: 'Disponibles',
                value: '14',
                helper: 'Listos para una nueva asignacion.',
              ),
              MarketplaceMetric(
                label: 'En servicio',
                value: '7',
                helper: 'Cabina con mision o briefing activo.',
              ),
              MarketplaceMetric(
                label: 'Rating',
                value: '4.9/5',
                helper: 'Promedio consolidado del servicio.',
              ),
            ],
            actions: [
              StaticAction(
                icon: Icons.person_add_rounded,
                label: 'Crear sobrecargo',
                message: 'Alta de crew lista para iniciar.',
              ),
              StaticAction(
                icon: Icons.upload_file_rounded,
                label: 'Subir certificado',
                message: 'Actualiza expediente del crew.',
              ),
              StaticAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filtrar',
                message: 'Muestra disponibilidad, rating o docs.',
              ),
            ],
            records: [
              StaticRecord(
                title: 'Ana Lira',
                subtitle: 'Base TLC | lista para vuelos premium',
                status: 'Activo',
                amount: '4.9/5',
              ),
              StaticRecord(
                title: 'CRM / recurrente',
                subtitle: 'Documento critico por validar este mes',
                status: 'Pendiente',
                amount: '20 dias',
              ),
            ],
            modules: [
              MarketplaceModule(
                title: 'Agenda',
                description: 'Disponibilidad, asignaciones y bloqueos.',
              ),
              MarketplaceModule(
                title: 'Expediente',
                description: 'Certificaciones, idiomas y rating.',
              ),
              MarketplaceModule(
                title: 'Pagos',
                description: 'Horas, payout y conciliacion del crew.',
              ),
            ],
          ),
        ),
        RoleWorkspaceItem(
          label: 'Contratos',
          shortLabel: 'Contratos',
          groupLabel: 'Operacion',
          description: 'Plantillas, firma digital y clausulas.',
          icon: Icons.description_outlined,
          screen: _WorkspaceModuleScreen(
            title: 'Contratos',
            subtitle:
                'Plantillas, clausulas y estado de firma por reserva y proveedor.',
            roleLabel: 'Administrador',
            heroTitle: 'Administra contratos con versionado y trazabilidad',
            heroSubtitle:
                'Seccion ejecutiva para controlar plantillas, firma digital y reemplazos documentales.',
            metrics: [
              MarketplaceMetric(
                label: 'En firma',
                value: '5',
                helper: 'Pendientes de completar por clientes.',
              ),
              MarketplaceMetric(
                label: 'Firmados',
                value: '18',
                helper: 'Contratos cerrados y vigentes.',
              ),
              MarketplaceMetric(
                label: 'Plantillas',
                value: '4',
                helper: 'Versiones disponibles por tipo de servicio.',
              ),
            ],
            actions: [
              StaticAction(
                icon: Icons.add_box_rounded,
                label: 'Crear contrato',
                message: 'Abre alta de contrato o version.',
              ),
              StaticAction(
                icon: Icons.rule_folder_rounded,
                label: 'Elegir plantilla',
                message: 'Selecciona template segun servicio.',
              ),
              StaticAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filtrar',
                message: 'Muestra firmados, pendientes o anulados.',
              ),
            ],
            records: [
              StaticRecord(
                title: 'Contrato SG-1048',
                subtitle: 'Reserva premium lista para firma de cliente',
                status: 'Pendiente',
                amount: 'Hoy',
              ),
              StaticRecord(
                title: 'Contrato corp-22',
                subtitle: 'Template enterprise vigente y firmado',
                status: 'Confirmado',
                amount: 'Vigente',
              ),
            ],
            modules: [
              MarketplaceModule(
                title: 'Plantillas',
                description: 'Versiones por tipo de servicio o cuenta.',
              ),
              MarketplaceModule(
                title: 'Firma',
                description: 'Estado de firmantes y auditoria.',
              ),
              MarketplaceModule(
                title: 'Adjuntos',
                description: 'Clausulas, anexos y reemplazos.',
              ),
            ],
          ),
        ),
        RoleWorkspaceItem(
          label: 'Documentos',
          shortLabel: 'Docs',
          groupLabel: 'Operacion',
          description:
              'Repositorio central de licencias, seguros y certificados.',
          icon: Icons.folder_copy_rounded,
          screen: _WorkspaceModuleScreen(
            title: 'Documentos',
            subtitle:
                'Repositorio documental centralizado para operadores, flota, crew y contratos.',
            roleLabel: 'Administrador',
            heroTitle: 'Concentra vigencias y cumplimiento documental',
            heroSubtitle:
                'Permite vigilar licencias, seguros, certificados y documentos de soporte del negocio.',
            metrics: [
              MarketplaceMetric(
                label: 'Validos',
                value: '146',
                helper: 'Documentos aprobados y vigentes.',
              ),
              MarketplaceMetric(
                label: 'Por vencer',
                value: '8',
                helper: 'Requieren renovacion inmediata.',
              ),
              MarketplaceMetric(
                label: 'Rechazados',
                value: '3',
                helper: 'Archivos con observaciones abiertas.',
              ),
            ],
            actions: [
              StaticAction(
                icon: Icons.upload_file_rounded,
                label: 'Subir documento',
                message: 'Carga un nuevo archivo al repositorio.',
              ),
              StaticAction(
                icon: Icons.verified_rounded,
                label: 'Validar archivo',
                message: 'Aprueba o rechaza un documento.',
              ),
              StaticAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filtrar',
                message: 'Muestra validos, vencidos o rechazados.',
              ),
            ],
            records: [
              StaticRecord(
                title: 'Seguro XA-SKY',
                subtitle: 'Poliza vigente hasta diciembre',
                status: 'Activo',
                amount: 'Vigente',
              ),
              StaticRecord(
                title: 'Licencia tripulacion',
                subtitle: 'Archivo rechazado por formato incorrecto',
                status: 'Pendiente',
                amount: 'Rechazado',
              ),
            ],
            modules: [
              MarketplaceModule(
                title: 'Repositorio',
                description: 'Todo el expediente documental del negocio.',
              ),
              MarketplaceModule(
                title: 'Vigencias',
                description: 'Semaforo y control preventivo.',
              ),
              MarketplaceModule(
                title: 'Revision',
                description: 'Aprobacion y comentarios de admin.',
              ),
            ],
          ),
        ),
        RoleWorkspaceItem(
          label: 'Incidencias',
          shortLabel: 'Incidencias',
          groupLabel: 'Operacion',
          description: 'Mesa de soporte, escalamiento y cierre de casos.',
          icon: Icons.report_problem_rounded,
          screen: AdminSupportScreen(),
        ),
        RoleWorkspaceItem(
          label: 'Notificaciones',
          shortLabel: 'Avisos',
          groupLabel: 'Operacion',
          description: 'Alertas, recordatorios y comunicacion operacional.',
          icon: Icons.notifications_active_rounded,
          screen: _WorkspaceModuleScreen(
            title: 'Notificaciones',
            subtitle:
                'Centro de mensajes, alertas y recordatorios para cada actor del sistema.',
            roleLabel: 'Administrador',
            heroTitle: 'Controla la comunicacion operacional y comercial',
            heroSubtitle:
                'Permite emitir alertas manuales, mensajes urgentes y recordatorios programados.',
            metrics: [
              MarketplaceMetric(
                label: 'Activas',
                value: '12',
                helper: 'Mensajes vigentes o pendientes de leer.',
              ),
              MarketplaceMetric(
                label: 'Urgentes',
                value: '4',
                helper: 'Alertas de prioridad alta.',
              ),
              MarketplaceMetric(
                label: 'Programadas',
                value: '7',
                helper: 'Recordatorios futuros ya definidos.',
              ),
            ],
            actions: [
              StaticAction(
                icon: Icons.add_alert_rounded,
                label: 'Crear alerta manual',
                message: 'Mensaje urgente listo para emitirse.',
              ),
              StaticAction(
                icon: Icons.schedule_send_rounded,
                label: 'Programar recordatorio',
                message: 'Configura fecha y destinatario.',
              ),
              StaticAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filtrar',
                message: 'Muestra activas, urgentes o caducas.',
              ),
            ],
            records: [
              StaticRecord(
                title: 'Demo por vencer',
                subtitle:
                    'Notificacion automatica a clientes con 3 dias restantes',
                status: 'Activo',
                amount: 'Programada',
              ),
              StaticRecord(
                title: 'Cambio de slot',
                subtitle: 'Alerta operativa enviada a crew y operador',
                status: 'Confirmado',
                amount: 'Urgente',
              ),
            ],
            modules: [
              MarketplaceModule(
                title: 'Mensajes',
                description: 'Campanas manuales y avisos del sistema.',
              ),
              MarketplaceModule(
                title: 'Programacion',
                description: 'Recordatorios por evento o fecha.',
              ),
              MarketplaceModule(
                title: 'Destinatarios',
                description: 'Cliente, operador, crew o admin.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WorkspaceModuleScreen extends StatelessWidget {
  const _WorkspaceModuleScreen({
    required this.title,
    required this.subtitle,
    required this.roleLabel,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.metrics,
    required this.actions,
    required this.records,
    required this.modules,
  });

  final String title;
  final String subtitle;
  final String roleLabel;
  final String heroTitle;
  final String heroSubtitle;
  final List<MarketplaceMetric> metrics;
  final List<StaticAction> actions;
  final List<StaticRecord> records;
  final List<MarketplaceModule> modules;

  @override
  Widget build(BuildContext context) {
    return StaticRoleScreen(
      title: title,
      subtitle: subtitle,
      roleLabel: roleLabel,
      heroTitle: heroTitle,
      heroSubtitle: heroSubtitle,
      metrics: metrics,
      actions: actions,
      records: records,
      modules: modules,
    );
  }
}
