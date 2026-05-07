import '../core/supabase_client.dart';
import '../models/aircraft.dart';

class AircraftService {

  static Future<List<Aircraft>> getFleet() async {

    final response = await SupabaseService.client
        .from('aircraft_fleet')
        .select()
        .eq('is_active', true);

    return response
        .map<Aircraft>((json) => Aircraft.fromJson(json))
        .toList();
  }

  static Future<Aircraft?> getAircraftById(String id) async {

    final data = await SupabaseService.client
        .from('aircraft_fleet')
        .select()
        .eq('id', id)
        .single();

    return Aircraft.fromJson(data);
  }

}