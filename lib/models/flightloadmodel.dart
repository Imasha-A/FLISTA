class FlightLoadModel {
  final String jCapacity;
  final String yCapacity;
  final String jBooked;
  final String yBooked;
  final String jCheckedIn;
  final String yCheckedIn;
  final String jCommercialStandby;
  final String yCommercialStandby;
  final String? jStaffListed;
  final String? yStaffListed;
  final String jStaffOnStandby;
  final String yStaffOnStandby;
  final String? jStaffAccepted;
  final String? yStaffAccepted;

  FlightLoadModel({
    required this.jCapacity,
    required this.yCapacity,
    required this.jBooked,
    required this.yBooked,
    required this.jCheckedIn,
    required this.yCheckedIn,
    required this.jCommercialStandby,
    required this.yCommercialStandby,
    required this.jStaffListed,
    required this.yStaffListed,
    required this.jStaffOnStandby,
    required this.yStaffOnStandby,
    required this.jStaffAccepted,
    required this.yStaffAccepted,
  });

  factory FlightLoadModel.fromJson(Map<String, dynamic> json) {
    return FlightLoadModel(
      jCapacity: json['Jcapacity'],
      yCapacity: json['Ycapacity'],
      jBooked: json['Jbooked'],
      yBooked: json['Ybooked'],
      jCheckedIn: json['Jcheckedin'],
      yCheckedIn: json['Ycheckedin'],
      jCommercialStandby: json['JCommercialStandby'],
      yCommercialStandby: json['YCommercialStandby'],
      jStaffListed: json['JStaffListed'],
      yStaffListed: json['YStaffListed'],
      jStaffOnStandby: json['JstaffOnStandby'],
      yStaffOnStandby: json['YstaffOnStandby'],
      jStaffAccepted: json['JstaffAccepted'],
      yStaffAccepted: json['YstaffAccepted'],
    );
  }
}
