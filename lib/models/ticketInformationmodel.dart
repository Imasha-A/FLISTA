class TicketInformation {
  final String firstName;
  final String lastName;
  final String TicketNumber;
  final String PassportNumber;
  final String SeatMapped;
  final String Ticket2DBarcode;
  final String PNRNumber;

  TicketInformation({
    required this.firstName,
    required this.lastName,
    required this.TicketNumber,
    required this.PassportNumber,
    required this.SeatMapped,
    required this.Ticket2DBarcode,
    required this.PNRNumber,
    
  });

  factory TicketInformation.fromJson(Map<String, dynamic> json) {
    return TicketInformation(
      firstName: json['FirstName'] ?? '',
      lastName: json['Lastname'] ?? '',
      TicketNumber: json['TicketNumber'] ?? '',
      PassportNumber: json['PassportNumber'] ?? '',
      SeatMapped: json['SeatMapped'] ?? '',
      Ticket2DBarcode: json['Ticket2DBarcode'] ?? '',
      PNRNumber: json['PNRNumber'] ?? '',
    );
  }
}

