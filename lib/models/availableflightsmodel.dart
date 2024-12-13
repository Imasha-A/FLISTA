class AvailableFlightModel {
  final String ulNumber;
  final String scheduledTime;
  final String flightDate; // New field for flight date
  String? originCountryCode; // New field for origin country code
  String? destinationCountryCode; // New field for destination country code

  AvailableFlightModel({
    required this.ulNumber,
    required this.scheduledTime,
    required this.flightDate,
  });

  factory AvailableFlightModel.fromJson(Map<String, dynamic> json) {
    return AvailableFlightModel(
      ulNumber: json['FlightNo'],
      scheduledTime: json['DepartuerTime'],
      flightDate: json['DepartureDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FlightNo': ulNumber,
      'DepartuerTime': scheduledTime,
      'DepartureDate': flightDate,
      'OriginCountryCode': originCountryCode,
      'DestinationCountryCode': destinationCountryCode,
    };
  }
}
