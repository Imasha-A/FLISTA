class StaffMember {
  final String firstName;
  final String lastName;
  final String staffID;
  final String priority;
  final String status;
  final String title;
  final String actionStatus;

  StaffMember({
    required this.firstName,
    required this.lastName,
    required this.staffID,
    required this.priority,
    required this.status,
    required this.title,
    required this.actionStatus,
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
    );
  }
}
