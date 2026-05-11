import 'package:flutter/material.dart';

import '../models/aircraft.dart';
import '../models/airport.dart';
import '../models/route_model.dart';
import '../services/reservation_service.dart';

class ReservationProvider extends ChangeNotifier {
  final ReservationService _reservationService = ReservationService();

  String? flightType;
  String? aircraftType;

  String? paymentMethod;
  String? paymentNumber;
  String? bankName;
  String? clabe;
  String? cuenta;

  String language = "ES";
  String routeType = "NACIONAL";

  bool isLoadingData = false;
  bool isOnline = true;
  String? syncMessage;
  DateTime? lastSyncAt;

  Aircraft? selectedAircraft;

  List<Aircraft> aircraftFleet = [];

  String? name;
  String? email;
  String? phone;
  String fullName = "";

  int passengers = 1;
  DateTime? startDate;
  DateTime? endDate;

  List<Map<String, dynamic>> reservations = [];

  List<Airport> airports = [];

  List<RouteModel> routes = [RouteModel()];

  void setLanguage(String value) {
    language = value;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> _fetchReservationsRemote() async {
    return _reservationService.getActiveReservationsRaw();
  }

  List<Map<String, dynamic>> _mapReservationRows(
    List<Map<String, dynamic>> rows,
  ) {
    return rows
        .map(
          (r) => {
            "aircraftId": r['aircraft_id'],
            "startDatetime": DateTime.parse(r['start_datetime'] as String),
            "endDatetime": DateTime.parse(r['end_datetime'] as String),
          },
        )
        .toList();
  }

  Future<void> loadInitialData() async {
    isLoadingData = true;
    syncMessage = "Sincronizando informacion con el servidor...";
    notifyListeners();

    try {
      final loadedAirports = await _safeLoadAirports();
      final loadedFleet = await _safeLoadFleet();
      final loadedReservations = await _safeLoadReservations();

      airports = loadedAirports;
      aircraftFleet = loadedFleet;
      reservations = loadedReservations;

      final now = DateTime.now();
      lastSyncAt = now;
      isOnline = airports.isNotEmpty || aircraftFleet.isNotEmpty;

      if (airports.isEmpty && aircraftFleet.isEmpty && reservations.isEmpty) {
        syncMessage =
            "No se pudo obtener informacion del servidor para el portal.";
      } else if (aircraftFleet.isEmpty && reservations.isEmpty) {
        syncMessage =
            "Se cargaron ${airports.length} aeropuertos desde el servidor. La flota y las reservas no estuvieron disponibles en esta sesion.";
      } else {
        syncMessage =
            "Sincronizacion completada: ${airports.length} aeropuertos, ${aircraftFleet.length} aeronaves y ${reservations.length} reservas actualizadas desde el servidor.";
      }
    } catch (e) {
      debugPrint("ERROR LOADING DATA: $e");
      isOnline = false;
      syncMessage =
          "No se pudo actualizar la informacion del portal. Verifica la conexion e intenta de nuevo.";
    } finally {
      isLoadingData = false;
      notifyListeners();
    }
  }

  Future<void> loadClientPortalData() async {
    isLoadingData = true;
    syncMessage = "Cargando datos del portal cliente...";
    notifyListeners();

    try {
      final loadedTrips = await _safeLoadClientTrips();
      reservations = loadedTrips;
      lastSyncAt = DateTime.now();
      isOnline = true;
      syncMessage =
          "Portal cliente actualizado: ${reservations.length} solicitudes sincronizadas.";
    } catch (e) {
      debugPrint("ERROR LOADING CLIENT PORTAL DATA: $e");
      isOnline = false;
      syncMessage =
          "No se pudo actualizar el portal cliente desde el servidor.";
    } finally {
      isLoadingData = false;
      notifyListeners();
    }
  }

  Future<List<Airport>> _safeLoadAirports() async {
    try {
      return await _reservationService.getAllAirports();
    } catch (error) {
      debugPrint("ERROR LOADING AIRPORTS: $error");
      return airports;
    }
  }

  Future<List<Aircraft>> _safeLoadFleet() async {
    try {
      return await _reservationService.getFleet();
    } catch (error) {
      debugPrint("ERROR LOADING FLEET: $error");
      return aircraftFleet;
    }
  }

  Future<List<Map<String, dynamic>>> _safeLoadReservations() async {
    try {
      final remoteReservations = await _fetchReservationsRemote();
      return _mapReservationRows(remoteReservations);
    } catch (error) {
      debugPrint("ERROR LOADING RESERVATIONS: $error");
      return reservations;
    }
  }

  Future<List<Map<String, dynamic>>> _safeLoadClientTrips() async {
    try {
      final remoteTrips = await _reservationService.getClientTripsRaw();
      return _mapReservationRows(remoteTrips);
    } catch (error) {
      debugPrint("ERROR LOADING CLIENT TRIPS: $error");
      return reservations;
    }
  }

  Future<List<Aircraft>> searchClientFlights({
    required Airport origin,
    required Airport destination,
    required DateTime departureDate,
    required TimeOfDay? departureTime,
    required int passengers,
    required String preference,
    List<Map<String, dynamic>> extraLegs = const [],
    String? tripLabel,
  }) async {
    final departureTimeLabel =
        departureTime == null
            ? '09:00'
            : '${departureTime.hour.toString().padLeft(2, '0')}:${departureTime.minute.toString().padLeft(2, '0')}';
    final departureDateLabel =
        '${departureDate.year.toString().padLeft(4, '0')}-${departureDate.month.toString().padLeft(2, '0')}-${departureDate.day.toString().padLeft(2, '0')}';

    return _reservationService.searchClientFlights({
      'origin': origin.iata ?? origin.name,
      'destination': destination.iata ?? destination.name,
      'departure_datetime': '$departureDateLabel $departureTimeLabel',
      'passengers': passengers,
      'aircraft_type': preference,
      'requirements': extraLegs,
      'notes': tripLabel ?? '',
    });
  }

  List<Aircraft> get filteredFleet {
    if (flightType == null) return aircraftFleet;

    final type = flightType!.toUpperCase();

    return aircraftFleet.where((aircraft) {
      final aircraftType = aircraft.aircraftType.toUpperCase();

      if (type == "JET PRIVADO" || type == "PRIVATE JET") {
        return aircraftType.contains("JET");
      }

      if (type == "HELICOPTERO" || type == "HELICOPTER") {
        return aircraftType.contains("HELICOPTERO") ||
            aircraftType.contains("HELICOPTER");
      }

      if (type == "AMBULANCIA AEREA" || type == "AIR AMBULANCE") {
        return aircraftType.contains("JET");
      }

      if (type == "CARGA" || type == "CARGO") {
        return aircraftType.contains("TURBO");
      }

      return true;
    }).toList();
  }

  void setGlobalPassengers(int value) {
    passengers = value;
    notifyListeners();
  }

  void setGlobalStartDate(DateTime date) {
    startDate = date;
    notifyListeners();
  }

  void setGlobalEndDate(DateTime date) {
    endDate = date;
    notifyListeners();
  }

  void setFlightType(String type) {
    flightType = type;
    selectedAircraft = null;
    notifyListeners();
  }

  void setRouteType(String type) {
    routeType = type;
    routes = [RouteModel()];
    selectedAircraft = null;
    notifyListeners();
  }

  void setName(String value) {
    name = value;
    notifyListeners();
  }

  void setEmail(String value) {
    email = value;
    notifyListeners();
  }

  void setPhone(String value) {
    phone = value;
    notifyListeners();
  }

  void setFullName(String value) {
    fullName = value;
    notifyListeners();
  }

  void addRoute() {
    if (routes.isEmpty) {
      routes.add(RouteModel());
      notifyListeners();
      return;
    }

    final lastRoute = routes.last;

    if (lastRoute.toAirport == null) {
      return;
    }

    routes.add(
      RouteModel(
        fromAirport: lastRoute.toAirport,
        passengers: lastRoute.passengers,
      ),
    );

    notifyListeners();
  }

  void removeRoute(int index) {
    if (routes.length <= 1) return;

    routes.removeAt(index);
    notifyListeners();
  }

  void setFromAirport(int index, Airport? airport) {
    if (index >= routes.length) return;

    routes[index].fromAirport = airport;
    notifyListeners();
  }

  void setToAirport(int index, Airport? airport) {
    if (index >= routes.length) return;

    routes[index].toAirport = airport;
    notifyListeners();
  }

  void setPassengers(int index, int passengers) {
    if (index >= routes.length) return;

    routes[index].passengers = passengers;
    notifyListeners();
  }

  void setStartDate(int index, DateTime date) {
    if (index >= routes.length) return;

    routes[index].startDate = date;
    notifyListeners();
  }

  void setEndDate(int index, DateTime date) {
    if (index >= routes.length) return;

    routes[index].endDate = date;
    notifyListeners();
  }

  void setAircraft(Aircraft? aircraft) {
    selectedAircraft = aircraft;
    notifyListeners();
  }

  void resetRoutes() {
    routes = [RouteModel()];
    notifyListeners();
  }

  void resetForm() {
    flightType = null;
    routeType = 'NACIONAL';
    selectedAircraft = null;
    passengers = 1;
    startDate = null;
    endDate = null;
    fullName = '';
    email = '';
    phone = '';
    paymentMethod = null;
    paymentNumber = null;
    bankName = null;
    clabe = null;
    cuenta = null;
    routes = [RouteModel()];
    notifyListeners();
  }

  void setPaymentMethod(String? method) {
    paymentMethod = method;

    if (method == "WIRE") {
      if (language == "ES") {
        bankName = "BBVA Mexico";
        clabe = "012441001238761521";
        cuenta = "00744677210123876152";
      } else {
        bankName = "Column N.A.";
        clabe = "121145433";
        cuenta = "749701713990491";
      }

      paymentNumber = null;
    }

    notifyListeners();
  }
}
