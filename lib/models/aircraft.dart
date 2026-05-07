class Aircraft {
  final String id;
  final String name;
  final String aircraftType;
  final int capacityPassengers;
  final double rentalPriceUsd;
  final double cruiseSpeedKnots;
  final double nationalExpensesUsd;
  final double internationalExpensesUsd;
  final String homeBase;
  final String city;
  final double crewOvernightUsd;
  final double minimumHours;
  

  Aircraft({
    required this.id,
    required this.name,
    required this.aircraftType,
    required this.capacityPassengers,
    required this.rentalPriceUsd,
    required this.cruiseSpeedKnots,
    required this.nationalExpensesUsd,
    required this.internationalExpensesUsd,
    required this.homeBase,
    required this.city,
    required this.crewOvernightUsd,
    required this.minimumHours,
  });

  double get cruiseSpeed => cruiseSpeedKnots;

  factory Aircraft.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    return Aircraft(
      id: json["id"].toString(),
      name: json["name"] ?? "",
      aircraftType: json["aircraft_type"] ?? "",
      capacityPassengers: json["capacity_passengers"] ?? 0,
      rentalPriceUsd: parseDouble(json["rental_price_usd"]),
      cruiseSpeedKnots: parseDouble(json["cruise_speed_knots"] ?? 350),
      nationalExpensesUsd: parseDouble(json["national_expenses_usd"]),
      internationalExpensesUsd: parseDouble(
        json["international_expenses_usd"],
      ),
      homeBase: json["home_base"] ?? "",
      city: json["city"] ?? "",
      minimumHours: parseDouble(json['minimum_hours']),
      crewOvernightUsd: parseDouble(json['crew_overnight_usd']),
    );
  }

  Map<String, dynamic> toCacheMap() {
    return {
      'id': id,
      'name': name,
      'aircraft_type': aircraftType,
      'capacity_passengers': capacityPassengers,
      'rental_price_usd': rentalPriceUsd,
      'cruise_speed_knots': cruiseSpeedKnots,
      'national_expenses_usd': nationalExpensesUsd,
      'international_expenses_usd': internationalExpensesUsd,
      'home_base': homeBase,
      'city': city,
      'crew_overnight_usd': crewOvernightUsd,
      'minimum_hours': minimumHours,
      'is_active': 1,
    };
  }
}
