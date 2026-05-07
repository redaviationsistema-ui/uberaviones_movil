import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/airport.dart';
import '../models/aircraft.dart';

class ReservationService {

  final supabase = Supabase.instance.client;

  /// AIRPORTS MEXICO
  Future<List<Airport>> getNationalAirports() async {

    final response = await supabase
        .from('aeropuertos_mexico')
        .select();

    return (response as List)
        .map((json) => Airport.fromJson(json))
        .toList();
  }

  /// INTERNATIONAL AIRPORTS
  Future<List<Airport>> getInternationalAirports() async {

    final response = await supabase
        .from('airports_geo')
        .select();

    return (response as List)
        .map((json) => Airport.fromJson(json))
        .toList();
  }

  /// AIRCRAFT FLEET
  Future<List<Aircraft>> getFleet() async {

    final response = await supabase
        .from('aircraft_fleet')
        .select()
        .eq('is_active', true);

    return (response as List)
        .map((json) => Aircraft.fromJson(json))
        .toList();
  }


  Future<bool> checkAvailability(
      String aircraftId,
      String startISO,
      String endISO) async {

    final response = await supabase
        .from('reservations')
        .select('id')
        .eq('aircraft_id', aircraftId)
        .inFilter('status', ['pending', 'confirmed'])
        .lt('start_datetime', endISO)
        .gt('end_datetime', startISO);

    return (response as List).isEmpty;
  }
}