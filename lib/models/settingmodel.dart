class FlistaSetting {
  final String settingId;
  final String settingCode;
  final String value;

  FlistaSetting({
    required this.settingId,
    required this.settingCode,
    required this.value,
  });

  factory FlistaSetting.fromJson(Map<String, dynamic> json) {
    return FlistaSetting(
      settingId: json['SETTING_ID'],
      settingCode: json['SETTING_CODE'],
      value: json['VALUESS'],
    );
  }
}
