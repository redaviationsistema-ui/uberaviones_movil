import '../core/supabase_client.dart';
import '../models/airport.dart';

class AirportService {

  static Future<List<Airport>> getAirports() async {

    final response = await SupabaseService.client
        .from('aeropuertos_mexico')
        .select();

    return response
        .map<Airport>((json) => Airport.fromJson(json))
        .toList();
  }

  static Future<List<Airport>> getAirportsByState(String state) async {

    final response = await SupabaseService.client
        .from('aeropuertos_mexico')
        .select()
        .eq('ESTADO', state);

    return response
        .map<Airport>((json) => Airport.fromJson(json))
        .toList();
  }

}