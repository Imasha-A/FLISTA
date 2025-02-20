class StaffPNRModal {
  final String title;
  final String firstName;
  final String lastName;
  final String pnr;

  StaffPNRModal({
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.pnr,
  });

  factory StaffPNRModal.fromJson(Map<String, dynamic> json) {
    return StaffPNRModal(
      title: json['Title'] ?? '',
      firstName: json['FirstName'] ?? '',
      lastName: json['LastName'] ?? '',
      pnr: json['RecordLocator'] ?? '',
    );
  }
}
