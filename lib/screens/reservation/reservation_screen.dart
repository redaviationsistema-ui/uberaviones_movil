import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../../providers/reservation_provider.dart';
import '../../widgets/route_form.dart';
import '../../models/aircraft.dart';
import 'quote_preview_screen.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _datesFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      if (!mounted) return;

      final provider = context.read<ReservationProvider>();
      await provider.loadInitialData();

      if (!mounted || provider.syncMessage == null) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.syncMessage!)));
    });
  }

  Future<void> handlePreview(ReservationProvider reservation) async {
    if (!_datesFormKey.currentState!.validate()) return;
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuotePreviewScreen()),
    );
  }

  bool isAircraftBlocked(
    DateTime? startDate,
    DateTime? endDate,
    String? aircraftId,
    List reservations,
  ) {
    debugPrint("RESERVATIONS: ${reservations.length}");

    if (startDate == null || aircraftId == null) return false;

    final newStart = startDate;
    final newEnd = endDate ?? startDate;

    for (final r in reservations) {
      if (r["aircraftId"] != aircraftId) continue;

      final DateTime existingStart = r["startDatetime"];
      final DateTime existingEnd = r["endDatetime"];

      if (newStart.isBefore(existingEnd) && newEnd.isAfter(existingStart)) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final reservation = context.watch<ReservationProvider>();
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reservacion de vuelo"),
        centerTitle: true,
        leading:
            MediaQuery.of(context).size.width >= 960
                ? null
                : IconButton(
                  tooltip: 'Abrir menu',
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () {
                    context
                        .findRootAncestorStateOfType<ScaffoldState>()
                        ?.openDrawer();
                  },
                ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (reservation.isLoadingData)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(),
                ),

              if (reservation.syncMessage != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        reservation.isOnline
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          reservation.isOnline
                              ? Colors.green.shade300
                              : Colors.orange.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        reservation.isOnline ? Icons.cloud_done : Icons.storage,
                        color:
                            reservation.isOnline
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          reservation.syncMessage!,
                          style: TextStyle(
                            color:
                                reservation.isOnline
                                    ? Colors.green.shade900
                                    : Colors.orange.shade900,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: "Refresh data",
                        onPressed:
                            reservation.isLoadingData
                                ? null
                                : () {
                                  reservation.loadInitialData();
                                },
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),

              Text(
                "Completa el formulario para recibir una cotizacion estimada de tu vuelo privado.",
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 20),

              /// FLIGHT INFO
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Informacion del vuelo",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// FLIGHT TYPE
                      DropdownSearch<String>(
                        selectedItem: reservation.flightType,

                        items: const [
                          "Jet privado",
                          "Helicoptero",
                          "Ambulancia aerea",
                          "Carga",
                        ],

                        popupProps: const PopupProps.menu(showSearchBox: true),

                        /// 🔎 BUSQUEDA EN MAYUSCULAS
                        filterFn: (item, filter) {
                          return item.toUpperCase().contains(
                            filter.toUpperCase(),
                          );
                        },

                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "Tipo de vuelo",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        onChanged: (value) {
                          if (value != null) {
                            reservation.setFlightType(value);
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      /// ROUTE TYPE
                      DropdownSearch<String>(
                        selectedItem: reservation.routeType,

                        // items: const ["NATIONAL"],
                        items: const ["NACIONAL", "INTERNACIONAL"],

                        popupProps: const PopupProps.menu(showSearchBox: true),

                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "Tipo de ruta",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        onChanged: (value) {
                          if (value != null) {
                            reservation.setRouteType(value);

                            // 🔥 LIMPIAR TODAS LAS RUTAS
                            reservation.resetRoutes();
                            reservation.setAircraft(null);
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      /// AIRCRAFT SELECTOR
                      DropdownSearch<Aircraft>(
                        selectedItem: reservation.selectedAircraft,
                        items: reservation.filteredFleet,

                        compareFn: (a, b) => a.id == b.id,

                        itemAsString:
                            (Aircraft a) =>
                                "${a.name} • ${a.capacityPassengers} pasajeros",

                        popupProps: PopupProps.menu(
                          showSearchBox: true,

                          itemBuilder: (
                            context,
                            Aircraft aircraft,
                            bool isSelected,
                          ) {
                            return ListTile(
                              dense: true,

                              title: Text(
                                "${aircraft.name} - ${aircraft.capacityPassengers} pasajeros",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              subtitle: Text(
                                "Base: ${aircraft.homeBase}",
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          },
                        ),

                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "Aeronave",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        onChanged: (Aircraft? aircraft) {
                          if (aircraft != null) {
                            reservation.setAircraft(aircraft);
                            final homeBaseCode =
                                aircraft.homeBase.toUpperCase();

                            /// buscar aeropuerto de la base
                            final baseAirport = reservation.airports.firstWhere(
                              (a) =>
                                  a.name.toUpperCase() == homeBaseCode ||
                                  (a.iata ?? "").toUpperCase() == homeBaseCode,
                              orElse: () => reservation.airports.first,
                            );

                            /// asignarlo a la primera ruta
                            reservation.setFromAirport(0, baseAirport);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// ROUTES
              Text(
                "Rutas",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              ...reservation.routes.asMap().entries.map((entry) {
                final index = entry.key;
                final route = entry.value;

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: RouteForm(
                      route: route,
                      airports: reservation.airports,
                      routeType: reservation.routeType,
                      onFromAirport: (airport) {
                        reservation.setFromAirport(index, airport);
                      },

                      onToAirport: (airport) {
                        reservation.setToAirport(index, airport);
                      },
                    ),
                  ),
                );
              }),

              OutlinedButton.icon(
                onPressed: () {
                  final lastRoute = reservation.routes.last;

                  if (lastRoute.toAirport == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Selecciona primero un aeropuerto de destino",
                        ),
                      ),
                    );
                    return;
                  }

                  reservation.addRoute();
                },

                icon: const Icon(Icons.add),
                label: const Text("Agregar ruta"),
              ),
              //   icon: const Icon(Icons.add),
              //   label: const Text("Add Route"),
              // ),
              const SizedBox(height: 10),

              /// PASSENGERS GLOBAL
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Pasajeros",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),

                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (reservation.passengers > 1) {
                            reservation.setGlobalPassengers(
                              reservation.passengers - 1,
                            );
                          }
                        },
                      ),

                      Text(
                        reservation.passengers.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),

                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          reservation.setGlobalPassengers(
                            reservation.passengers + 1,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// DATES
              /// =====================
              Form(
                key: _datesFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// DEPARTURE DATE
                    FormField<DateTime>(
                      initialValue: reservation.startDate,
                      validator: (value) {
                        if (value == null) {
                          return "Selecciona una fecha de salida";
                        }

                        if (reservation.selectedAircraft == null) {
                          return "Selecciona primero una aeronave";
                        }

                        if (isAircraftBlocked(
                          value,
                          reservation.endDate,
                          reservation.selectedAircraft?.id,
                          reservation.reservations,
                        )) {
                          return "La aeronave no esta disponible en esta fecha";
                        }

                        return null;
                      },
                      builder: (state) {
                        final bool blocked = isAircraftBlocked(
                          state.value,
                          reservation.endDate,
                          reservation.selectedAircraft?.id,
                          reservation.reservations,
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: state.value ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2035),
                                );

                                if (date != null) {
                                  state.didChange(date);
                                  reservation.setGlobalStartDate(date);
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: "Fecha de salida",
                                  border: const OutlineInputBorder(),
                                  errorText: state.errorText,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          reservation.selectedAircraft == null
                                              ? Colors.grey
                                              : blocked
                                              ? Colors.red
                                              : Colors.green,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  state.value == null
                                      ? "Seleccionar fecha"
                                      : dateFormat.format(state.value!),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      },
                    ),

                    /// RETURN DATE
                    FormField<DateTime>(
                      initialValue: reservation.endDate,
                      validator: (value) {
                        if (value == null) {
                          return "Selecciona una fecha de regreso";
                        }

                        if (reservation.startDate != null &&
                            value.isBefore(reservation.startDate!)) {
                          return "La fecha de regreso debe ser posterior a la salida";
                        }

                        if (isAircraftBlocked(
                          reservation.startDate,
                          value,
                          reservation.selectedAircraft?.id,
                          reservation.reservations,
                        )) {
                          return "La aeronave no esta disponible en las fechas seleccionadas";
                        }

                        return null;
                      },
                      builder: (state) {
                        final bool blocked = isAircraftBlocked(
                          reservation.startDate,
                          state.value,
                          reservation.selectedAircraft?.id,
                          reservation.reservations,
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      state.value ??
                                      reservation.startDate ??
                                      DateTime.now(),
                                  firstDate:
                                      reservation.startDate ?? DateTime.now(),
                                  lastDate: DateTime(2035),
                                );

                                if (date != null) {
                                  state.didChange(date);
                                  reservation.setGlobalEndDate(date);
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: "Fecha de regreso",
                                  border: const OutlineInputBorder(),
                                  errorText: state.errorText,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          reservation.selectedAircraft == null
                                              ? Colors.grey
                                              : blocked
                                              ? Colors.red
                                              : Colors.green,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  state.value == null
                                      ? "Seleccionar fecha"
                                      : dateFormat.format(state.value!),
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            if (blocked)
                              const Text(
                                "Esta aeronave no esta disponible en las fechas seleccionadas.",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              /// PASSENGER INFORMATION
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Informacion del pasajero",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// FULL NAME
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Nombre completo",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: reservation.setFullName,
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? "El nombre completo es obligatorio"
                                    : null,
                      ),

                      const SizedBox(height: 16),

                      /// EMAIL
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Correo electronico",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: reservation.setEmail,
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? "El correo es obligatorio"
                                    : null,
                      ),

                      const SizedBox(height: 16),

                      /// PHONE
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Telefono",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: reservation.setPhone,
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? "El telefono es obligatorio"
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Metodo de pago",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "WIRE",
                            child: Text("Transferencia bancaria"),
                          ),
                          // DropdownMenuItem(
                          //   value: "CREDIT",
                          //   child: Text("Credit Card"),
                          // ),
                          // DropdownMenuItem(
                          //   value: "DEBIT",
                          //   child: Text("Debit Card"),
                          // ),
                        ],
                        onChanged: (value) {
                          reservation.setPaymentMethod(value);
                        },
                        validator:
                            (v) =>
                                v == null
                                    ? "Selecciona un metodo de pago"
                                    : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              /// LANGUAGE SELECTOR
              DropdownButtonFormField<String>(
                value: reservation.language,
                decoration: const InputDecoration(
                  labelText: "Idioma",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "ES", child: Text("Espanol")),
                  DropdownMenuItem(value: "EN", child: Text("Ingles")),
                ],
                onChanged: (value) {
                  if (value != null) {
                    reservation.setLanguage(value);
                  }
                },
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 50,
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cleaning_services),
                  label: const Text("Limpiar formulario"),
                  onPressed: () {
                    reservation.resetForm();

                    // 🔥 también limpia validaciones visuales
                    _formKey.currentState?.reset();
                    _datesFormKey.currentState?.reset();
                  },
                ),
              ),
              const SizedBox(height: 30),

              /// BUTTON
              SizedBox(
                height: 55,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (isAircraftBlocked(
                      reservation.startDate,
                      reservation.endDate,
                      reservation.selectedAircraft?.id,
                      reservation.reservations,
                    )) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Aeronave no disponible en las fechas seleccionadas",
                          ),
                        ),
                      );
                      return;
                    }

                    handlePreview(reservation);
                  },
                  child: const Text(
                    "Solicitar reservacion",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
