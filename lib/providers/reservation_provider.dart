import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/aircraft.dart';
import '../models/airport.dart';
import '../models/route_model.dart';
import '../services/local_cache_service.dart';

class ReservationProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  final LocalCacheService _cacheService = LocalCacheService();

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

  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchReservationsRemote() async {
    final response = await supabase
        .from('reservations')
        .select('aircraft_id, start_datetime, end_datetime, status')
        .inFilter('status', ['pending', 'confirmed']);

    return (response as List)
        .map<Map<String, dynamic>>(
          (r) => {
            'aircraft_id': r['aircraft_id'],
            'start_datetime': r['start_datetime'],
            'end_datetime': r['end_datetime'],
            'status': r['status'],
          },
        )
        .toList();
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

  Map<String, dynamic> _normalizeAirport(dynamic raw) {
    final json = Map<String, dynamic>.from(raw as Map);

    return {
      'name':
          json['AEROPUERTO'] ??
          json['name'] ??
          json['airport'] ??
          json['nombre'] ??
          '',
      'city': json['CIUDAD'] ?? json['city'] ?? json['municipality'] ?? '',
      'state': json['ESTADO'] ?? json['state'] ?? json['region'],
      'lat': _toDouble(json['LATITUDE'] ?? json['lat']),
      'lng': _toDouble(json['LONGITUDE'] ?? json['lng']),
      'iata': json['IATA'] ?? json['iata'] ?? json['gps_code'],
      'country':
          json['PAIS'] ??
          json['country'] ??
          json['COUNTRY'] ??
          json['iso_country'] ??
          'MEXICO',
    };
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> loadCachedData({String? fallbackReason}) async {
    final cachedAirports = await _cacheService.getCachedAirports();
    final cachedAircraft = await _cacheService.getCachedAircraft();
    final cachedReservations = await _cacheService.getCachedReservations();
    final cachedSyncAt = await _cacheService.getMetadata('last_sync_at');

    airports =
        cachedAirports
            .map((row) => Airport.fromJson(Map<String, dynamic>.from(row)))
            .toList();
    aircraftFleet =
        cachedAircraft
            .map((row) => Aircraft.fromJson(Map<String, dynamic>.from(row)))
            .toList();
    reservations = _mapReservationRows(
      cachedReservations.map((row) => Map<String, dynamic>.from(row)).toList(),
    );

    lastSyncAt = cachedSyncAt == null ? null : DateTime.tryParse(cachedSyncAt);
    isOnline = false;

    if (airports.isEmpty && aircraftFleet.isEmpty) {
      syncMessage =
          fallbackReason == null
              ? "No hay datos locales guardados en el telefono."
              : "Sin conexion y sin datos locales guardados.";
    } else {
      final syncText =
          lastSyncAt == null
              ? "sin fecha previa"
              : "ultima sincronizacion ${lastSyncAt!.day.toString().padLeft(2, '0')}/${lastSyncAt!.month.toString().padLeft(2, '0')}/${lastSyncAt!.year} ${lastSyncAt!.hour.toString().padLeft(2, '0')}:${lastSyncAt!.minute.toString().padLeft(2, '0')}";

      syncMessage =
          "Modo offline: se cargaron ${airports.length} aeropuertos, ${aircraftFleet.length} aeronaves y ${reservations.length} reservas desde la base local ($syncText).";
    }
  }

  Future<void> loadInitialData() async {
    isLoadingData = true;
    syncMessage = "Sincronizando informacion con el servidor...";
    notifyListeners();

    try {
      final hasInternet = await checkInternetConnection();
      if (!hasInternet) {
        await loadCachedData(fallbackReason: 'no_internet');
        return;
      }

      final national = await supabase.from('aeropuertos_mexico').select();
      final international = await supabase.from('airports_geo').select();

      final normalizedAirports = [
        ...(national as List).map(_normalizeAirport),
        ...(international as List).map(_normalizeAirport),
      ];

      airports = normalizedAirports.map(Airport.fromJson).toList();

      final aircraftResponse = await supabase
          .from('aircraft_fleet')
          .select()
          .eq('is_active', true);

      aircraftFleet =
          (aircraftResponse as List)
              .map((json) => Aircraft.fromJson(Map<String, dynamic>.from(json)))
              .toList();

      final remoteReservations = await _fetchReservationsRemote();
      reservations = _mapReservationRows(remoteReservations);

      await _cacheService.cacheAirports(
        airports.map((airport) => airport.toCacheMap()).toList(),
      );
      await _cacheService.cacheAircraft(
        aircraftFleet.map((aircraft) => aircraft.toCacheMap()).toList(),
      );
      await _cacheService.cacheReservations(remoteReservations);

      final now = DateTime.now();
      await _cacheService.setMetadata('last_sync_at', now.toIso8601String());

      lastSyncAt = now;
      isOnline = true;
      syncMessage =
          "Sincronizacion completada: ${airports.length} aeropuertos, ${aircraftFleet.length} aeronaves y ${reservations.length} reservas guardadas en el telefono.";
    } catch (e) {
      debugPrint("ERROR LOADING DATA: $e");
      await loadCachedData(fallbackReason: e.toString());
    } finally {
      isLoadingData = false;
      notifyListeners();
    }
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
