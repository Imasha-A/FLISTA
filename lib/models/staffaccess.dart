class FlistaPermission {
  final String moduleId;
  final String staffId;
  final String isActive;
  final String personName;
  final String specialValues;

  FlistaPermission({
    required this.moduleId,
    required this.staffId,
    required this.isActive,
    required this.personName,
    required this.specialValues,
  });

  factory FlistaPermission.fromJson(Map<String, dynamic> json) {
    return FlistaPermission(
      moduleId: json['MODULE_ID'] ?? '',
      staffId: json['STAFF_ID'] ?? '',
      isActive: json['IS_ACTIVE'] ?? '',
      personName: json['PERSON_NAME'] ?? '',
      specialValues: json['SPECIAL_VALUES'] ?? '',
    );
  }
}
