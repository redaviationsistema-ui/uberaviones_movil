import '../core/supabase_client.dart';

class QuoteService {

  static Future<String> createQuote({

    required String fullName,
    required String email,
    required String phone,
    required String flightType,
    required double totalPrice

  }) async {

    final response = await SupabaseService.client
        .from('quotes')
        .insert({

      "full_name": fullName,
      "email": email,
      "phone": phone,
      "flight_type": flightType,
      "total_estimated_price": totalPrice

    })
        .select()
        .single();

    return response["id"].toString();
  }

}