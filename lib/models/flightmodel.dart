class FlightInformation {
  final String flightNumber;
  final String depDate;
  final String depTime;
  final String arrDate;
  final String arrTime;
  final String Boardpoint;
  final String Offpoint;
  final List confirmedStatus;

  FlightInformation({
    required this.flightNumber,
    required this.depDate,
    required this.depTime,
    required this.arrDate,
    required this.arrTime,
    required this.Boardpoint,
    required this.Offpoint,
    required this.confirmedStatus,
  });

  factory FlightInformation.fromJson(Map<String, dynamic> json) {
    return FlightInformation(
      flightNumber: json['FlightNumber'] ?? '',
      depDate: json['DepDate'] ?? '',
      depTime: json['DepTime'] ?? '',
      arrDate: json['ArrDate'] ?? '',
      arrTime: json['ArrTime'] ?? '',
      Boardpoint: json['Boardpoint'] ?? '',
      Offpoint: json['Offpoint'] ?? '',
      confirmedStatus: json['ConfirmedStatus'] ?? [],
    );
  }
}
