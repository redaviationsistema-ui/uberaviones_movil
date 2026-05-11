import '../models/aircraft.dart';
import 'reservation_service.dart';

class AircraftService {
  static final ReservationService _reservationService = ReservationService();

  static Future<List<Aircraft>> getFleet() async {
    return _reservationService.getFleet();
  }

  static Future<Aircraft?> getAircraftById(String id) async {
    final fleet = await _reservationService.getFleet();
    for (final aircraft in fleet) {
      if (aircraft.id == id) return aircraft;
    }
    return null;
  }
}
