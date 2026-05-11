import 'api_client.dart';

class QuoteService {
  static final ApiClient _apiClient = ApiClient();

  static Future<String> createQuote({
    required String fullName,
    required String email,
    required String phone,
    required String flightType,
    required double totalPrice,
  }) async {
    final response = await _apiClient.postMap(
      const ['/quotes', '/quote-requests'],
      {
        "full_name": fullName,
        "email": email,
        "phone": phone,
        "flight_type": flightType,
        "total_estimated_price": totalPrice,
      },
      auth: true,
    );

    return response["id"].toString();
  }

  static Future<void> createQuoteRoute(Map<String, dynamic> payload) async {
    await _apiClient.postMap(
      const ['/quote-routes', '/quote_routes'],
      payload,
      auth: true,
    );
  }

  static Future<void> createReservation(Map<String, dynamic> payload) async {
    await _apiClient.postMap(
      const ['/reservations', '/booking/reservations'],
      payload,
      auth: true,
    );
  }
}
