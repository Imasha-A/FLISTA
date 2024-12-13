class FlightInfo {
  final String flightNo;
  final String departureDate;
  final String arrivalDate;
  final String departureStation;
  final String arrivalStation;
  final String departureTime;
  final String arrivalTime;

  FlightInfo({
    required this.flightNo,
    required this.departureDate,
    required this.arrivalDate,
    required this.departureStation,
    required this.arrivalStation,
    required this.departureTime,
    required this.arrivalTime,
  });

  factory FlightInfo.fromJson(Map<String, dynamic> json) {
    return FlightInfo(
      flightNo: json['FlightNo'],
      departureDate: json['DepartureDate'],
      arrivalDate: json['ArrivalDate'],
      departureStation: json['DepartureStation'],
      arrivalStation: json['ArrivalStation'],
      departureTime: json['DepartuerTime'],
      arrivalTime: json['ArrivalTime'],
    );
  }
}

