import '../models/aircraft.dart';
import '../models/airport.dart';
import 'api_client.dart';

class ReservationService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Airport>> getAllAirports() async {
    try {
      final rows = await _apiClient.getList(const [
        '/airports',
        '/catalog/airports',
        '/locations/airports',
      ]);

      if (rows.isNotEmpty) {
        return rows
            .map((row) => Airport.fromJson(_normalizeAirport(row)))
            .toList();
      }
    } on ApiException catch (error) {
      if (error.statusCode != 404) rethrow;
    }

    final national = await getNationalAirports();
    final international = await getInternationalAirports();
    return [...national, ...international];
  }

  Future<List<Airport>> searchAirports(String query, {int limit = 6}) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return const [];

    final rows = await _apiClient.getList(
      const [
        '/airports/search',
        '/airports',
        '/public/airports/search',
        '/public/airports',
      ],
      queryParameters: {
        'search': trimmedQuery,
        'q': trimmedQuery,
        'term': trimmedQuery,
        'limit': '$limit',
      },
    );

    final seen = <String>{};
    final airports = <Airport>[];

    for (final row in rows) {
      final airport = Airport.fromJson(_normalizeAirport(row));
      final key =
          '${airport.iata ?? ''}-${airport.city}-${airport.name}'.toLowerCase();
      if (airport.name.isEmpty || seen.contains(key)) continue;
      seen.add(key);
      airports.add(airport);
      if (airports.length >= limit) break;
    }

    return airports;
  }

  Future<List<Airport>> getNationalAirports() async {
    final response = await _apiClient.getList(const [
      '/airports/national',
      '/catalog/airports/national',
      '/aeropuertos',
      '/aeropuertos_mexico',
    ]);

    return response
        .map((json) => Airport.fromJson(_normalizeAirport(json)))
        .toList();
  }

  Future<List<Airport>> getInternationalAirports() async {
    try {
      final response = await _apiClient.getList(const [
        '/airports/international',
        '/catalog/airports/international',
        '/airports_geo',
      ]);

      return response
          .map((json) => Airport.fromJson(_normalizeAirport(json)))
          .toList();
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        return const [];
      }
      rethrow;
    }
  }

  Future<List<Aircraft>> getFleet() async {
    final response = await _apiClient.getList(const [
      '/aircraft',
      '/aircraft/fleet',
      '/fleet',
      '/provider/aircraft',
      '/aircraft_fleet',
    ], auth: true);

    return response
        .map((json) => Aircraft.fromJson(Map<String, dynamic>.from(json)))
        .where((aircraft) => aircraft.name.isNotEmpty)
        .toList();
  }

  Future<bool> checkAvailability(
    String aircraftId,
    String startISO,
    String endISO,
  ) async {
    final reservations = await getActiveReservationsRaw();
    final startDate = DateTime.parse(startISO);
    final endDate = DateTime.parse(endISO);

    for (final reservation in reservations) {
      if (reservation['aircraft_id']?.toString() != aircraftId) continue;

      final existingStart = DateTime.tryParse(
        reservation['start_datetime']?.toString() ?? '',
      );
      final existingEnd = DateTime.tryParse(
        reservation['end_datetime']?.toString() ?? '',
      );

      if (existingStart == null || existingEnd == null) continue;

      if (existingStart.isBefore(endDate) && existingEnd.isAfter(startDate)) {
        return false;
      }
    }

    return true;
  }

  Future<List<Map<String, dynamic>>> getActiveReservationsRaw() async {
    final response = await _apiClient.getList(const [
      '/reservations',
      '/booking/reservations',
      '/charter/reservations',
    ], auth: true);

    return response
        .map(_normalizeReservation)
        .where(
          (item) =>
              item['aircraft_id'] != null &&
              item['start_datetime'] != null &&
              item['end_datetime'] != null &&
              const ['pending', 'confirmed'].contains(item['status']),
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> getClientTripsRaw() async {
    final response = await _apiClient.getList(
      const ['/client/flight-requests'],
      auth: true,
    );

    return response.map(_normalizeClientTrip).toList();
  }

  Future<List<Aircraft>> searchClientFlights(
    Map<String, dynamic> itinerary,
  ) async {
    final response = await _apiClient.postList(
      const ['/client/flight-requests'],
      itinerary,
      auth: true,
    );

    return response
        .map(_normalizeClientMatchAircraft)
        .where((aircraft) => aircraft.name.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> _normalizeAirport(Map<String, dynamic> json) {
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

  Map<String, dynamic> _normalizeReservation(Map<String, dynamic> json) {
    return {
      'aircraft_id':
          json['aircraft_id'] ?? json['aircraftId'] ?? json['plane_id'],
      'start_datetime':
          json['start_datetime'] ??
          json['startDatetime'] ??
          json['departure_at'],
      'end_datetime':
          json['end_datetime'] ?? json['endDatetime'] ?? json['arrival_at'],
      'status': (json['status'] ?? 'confirmed').toString().toLowerCase(),
    };
  }

  Map<String, dynamic> _normalizeClientTrip(Map<String, dynamic> json) {
    final matchedOptions =
        json['matched_options'] is List
            ? json['matched_options'] as List<dynamic>
            : const [];
    final firstMatch =
        matchedOptions.isNotEmpty && matchedOptions.first is Map<String, dynamic>
            ? matchedOptions.first as Map<String, dynamic>
            : <String, dynamic>{};
    final aircraft =
        firstMatch['aircraft'] is Map<String, dynamic>
            ? firstMatch['aircraft'] as Map<String, dynamic>
            : <String, dynamic>{};
    final departure =
        json['departure_datetime'] ??
        json['departure_date'] ??
        json['start_datetime'] ??
        DateTime.now().toIso8601String();

    return {
      'aircraft_id':
          aircraft['id'] ?? firstMatch['aircraft_id'] ?? json['id'] ?? '',
      'start_datetime': departure,
      'end_datetime': json['end_datetime'] ?? departure,
      'status': (json['status'] ?? 'pending').toString().toLowerCase(),
    };
  }

  Aircraft _normalizeClientMatchAircraft(Map<String, dynamic> json) {
    final aircraft =
        json['aircraft'] is Map<String, dynamic>
            ? json['aircraft'] as Map<String, dynamic>
            : <String, dynamic>{};

    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) {
        final sanitized = value.replaceAll(RegExp(r'[^0-9.]'), '');
        return double.tryParse(sanitized) ?? 0;
      }
      return 0;
    }

    int parseInt(dynamic value) {
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final total =
        json['final_price'] ?? json['price'] ?? json['quoted_price'] ?? 0;
    final minimumHours = parseDouble(aircraft['minimum_hours'] ?? 1);

    return Aircraft(
      id:
          (json['id'] ?? aircraft['id'] ?? aircraft['registration'] ?? '')
              .toString(),
      name:
          (aircraft['name'] ??
                  json['aircraft_name'] ??
                  json['name'] ??
                  aircraft['model'] ??
                  aircraft['category'] ??
                  '')
              .toString(),
      aircraftType:
          (json['cabin'] ??
                  json['cabin_type'] ??
                  json['type'] ??
                  aircraft['category'] ??
                  '')
              .toString(),
      capacityPassengers: parseInt(json['capacity'] ?? aircraft['capacity']),
      rentalPriceUsd:
          minimumHours <= 0 ? parseDouble(total) : parseDouble(total) / minimumHours,
      cruiseSpeedKnots: parseDouble(aircraft['cruise_speed_knots'] ?? 350),
      nationalExpensesUsd: 0,
      internationalExpensesUsd: 0,
      homeBase:
          (aircraft['base'] ?? aircraft['home_base'] ?? aircraft['location'] ?? '')
              .toString(),
      city: (aircraft['city'] ?? aircraft['base_city'] ?? '').toString(),
      crewOvernightUsd: 0,
      minimumHours: minimumHours <= 0 ? 1 : minimumHours,
    );
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
