class FlightInfo {
  final String flightNo;
  final String departureDate;
  final String arrivalDate;
  final String departureStation;
  final String arrivalStation;
  final String departureTime;
  final String arrivalTime;
  final List confirmedStatus;
  final String terminal;

  FlightInfo({
    required this.flightNo,
    required this.departureDate,
    required this.arrivalDate,
    required this.departureStation,
    required this.arrivalStation,
    required this.departureTime,
    required this.arrivalTime,
    required this.confirmedStatus,
    required this.terminal,
  });

  factory FlightInfo.fromJson(Map<String, dynamic> json) {
    return FlightInfo(
      flightNo: json['FlightNumber'],
      departureDate: json['DepDate'],
      arrivalDate: json['ArrDate'],
      departureStation: json['Boardpoint'],
      arrivalStation: json['Offpoint'],
      departureTime: json['DepTime'],
      arrivalTime: json['ArrTime'],
      confirmedStatus: json['ConfirmedStatus'],
      terminal: json['terminal'],
    );
  }
}
