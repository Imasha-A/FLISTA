class CheckinSummery {
  final int? jInfantsAccepted;
  final int? yInfantsAccepted;
  final int? jBookableStaffAccepted;
  final int? yBookableStaffAccepted;


    final int? jCapacity;
  final int? yCapacity;
  final int? jBooked;
  final int? yBooked;
    final int? jCheckedIn;
  final int? yCheckedIn;
  final int? jCommercialStandby;
  final int? yCommercialStandby;

  final int? jStaffListed;
  final int? yStaffListed;
    final int? jStaffOnStandby;
  final int? yStaffOnStandby;
  final int? jStaffAccepted;
  final int? yStaffAccepted;
  CheckinSummery({
    this.jInfantsAccepted,
    this.yInfantsAccepted,
    this.jBookableStaffAccepted,
    this.yBookableStaffAccepted,

    this.jCapacity,
    this.yCapacity,
    this.jBooked,
    this.yBooked,

    this.jCheckedIn,
    this.yCheckedIn,
    this.jCommercialStandby,
    this.yCommercialStandby,

     this.jStaffListed,
    this.yStaffListed,
    this.jStaffOnStandby,
    this.yStaffOnStandby,
    
      this.jStaffAccepted,
    this.yStaffAccepted,
    
  
  });
  
   factory CheckinSummery.fromJson(Map<String, dynamic> json) {
  return CheckinSummery(
    jCapacity: int.tryParse(json['SCN'].toString()),
    yCapacity: int.tryParse(json['SCNy'].toString()),

    jBooked: int.tryParse(json['BOO'].toString()),
    yBooked: int.tryParse(json['BOOy'].toString()),

    jCheckedIn: int.tryParse(json['JCA'].toString()),
    yCheckedIn: int.tryParse(json['JCAy'].toString()),

    jInfantsAccepted: int.tryParse(json['IJA'].toString()),
    yInfantsAccepted: int.tryParse(json['IJAy'].toString()),

    jCommercialStandby: int.tryParse(json['JCS'].toString()),
    yCommercialStandby: int.tryParse(json['JCSy'].toString()),

    jStaffListed: int.tryParse(json['LRS'].toString()),
    yStaffListed: int.tryParse(json['LRSy'].toString()),

    jStaffOnStandby: int.tryParse(json['RJF'].toString()),
    yStaffOnStandby: int.tryParse(json['RJFy'].toString()),

    jStaffAccepted: int.tryParse(json['RJS'].toString()),
    yStaffAccepted: int.tryParse(json['RJSy'].toString()),

    jBookableStaffAccepted: int.tryParse(json['JSA'].toString()),
    yBookableStaffAccepted: int.tryParse(json['JSAy'].toString()),

  );
}

}
