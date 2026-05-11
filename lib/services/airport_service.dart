import '../models/airport.dart';
import 'reservation_service.dart';

class AirportService {
  static final ReservationService _reservationService = ReservationService();

  static Future<List<Airport>> getAirports() async {
    return _reservationService.getAllAirports();
  }

  static Future<List<Airport>> getAirportsByState(String state) async {
    final airports = await _reservationService.getAllAirports();
    final normalizedState = state.trim().toUpperCase();

    return airports.where((airport) {
      final airportState = airport.state?.trim().toUpperCase() ?? '';
      return airportState == normalizedState;
    }).toList();
  }
}
