class StaffMember {
  final String firstName;
  final String lastName;
  final String staffID;
  final String priority;
  final String status;
  final String title;
  final String actionStatus;
  final String pnr;
  final String uniqueCustomerID;
  final String paxType;
  final String prodIdentificationRefCode;
  final String prodIdentificationPrimeID;
  final String givenName;
  final String gender;
  final String Title;
  final String surname;


  StaffMember({
    required this.firstName,
    required this.lastName,
    required this.staffID,
    required this.priority,
    required this.status,
    required this.title,
    required this.actionStatus,
    required this.pnr,
    required this.uniqueCustomerID,
    required this.paxType,
    required this.prodIdentificationRefCode,
    required this.prodIdentificationPrimeID,
    required this.givenName,
    required this.gender,
    required this.Title,
     required this.surname,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      firstName: json['FirstName'] ?? '',
      lastName: json['LastName'] ?? '',
      staffID: json['StaffID'] ?? '',
      priority: json['Priority'] ?? '',
      status: json['Status'] ?? '',
      title: json['Title'] ?? '',
      actionStatus: json['ActionStatus'] ?? '',
      pnr: json['PNR'] ?? '',
      uniqueCustomerID: json['UniqueCustomerID'] ?? '',
      paxType: json['paxType'] ?? '',
      prodIdentificationRefCode: json['prodIdentificationRefCode'] ?? '',
      prodIdentificationPrimeID: json['prodIdentificationPrimeID'] ?? '',
      givenName: json['givenName'] ?? '',
      gender: json['gender'] ?? '',
      Title: json['Title'] ?? '',
      surname: json['surname'] ?? '',
    );
  }
}
