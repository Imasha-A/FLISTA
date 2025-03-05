import 'dart:convert';
import 'dart:typed_data';

import 'package:flista_new/history.dart';
import 'package:flista_new/home.dart';
import 'package:flista_new/main.dart';
import 'package:flista_new/models/staffmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flista_new/models/ticketInformationmodel.dart';
import 'package:flista_new/models/flightmodel.dart';
import '../services/api_service.dart';
import 'dart:ui' as ui;
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class MyTickets extends StatefulWidget {
  const MyTickets({super.key});
  @override
  State<MyTickets> createState() => _MyTicketsState();
}

class _MyTicketsState extends State<MyTickets> {
  String _userName = "username";
  String _userId = "12345";
  bool _isLoading = true;
  final APIService _apiService = APIService();
  List<StaffMember> staffMembers = [];
  List<TicketInformation> allTicketInfo = [];
  List<FlightInformation> allFlightInfo = [];
  TicketInformation? ticket;
  FlightInformation? flight;
  late Future<List<Map<String, dynamic>>> airportDataFuture;
  Uint8List? imageBytes;
  String selectedValue = 'all';
  String standardBaggageAllowance = '';
  String segmentTattooNumber = '';
  String excessBaggageInfo = '';
  double? latitude = 0.0;
  double? longitude = 0.0;
  bool _hasRequestedPermissionBefore = false;
  // Track standby status separately for each segment
  Map<String, bool> _standbyStatusMap = {};

  Location location = Location();
  LocationData? _locationData;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loadStandbyStatus(); // Load persisted standby status
    _loadUserName();
    _loadUserId();
    airportDataFuture = APIService.getOriginsAndDestinations();
    _loadUserIdFromPreferences().then((_) async {
      String pnr = await _fetchPNR(); // Wait for the PNR to be retrieved
      fetchData(pnr); // Pass the retrieved PNR to fetchData
    });
    _loadData();
    _loadUserId();
  }

  Future<void> _loadUserIdFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId') ??
          '16231'; // Load the userId (default to '123456')
    });
  }

  //CHANGE,JUST A PLACEHOLDER UNTIL SERVICE IS GIVEN, PLEASE REPLACE THIS!
  Future<String> _fetchPNR() async {
    String pnr = '67YGXB';
    return pnr;
    //5VU8HD
  }

  // Future<String> _fetchPNR() async {
  //   try {
  //     if (_userId.isEmpty) {
  //       await _loadUserIdFromPreferences(); // Ensure _userId is loaded
  //     }

  //     List<StaffPNRModal> pnrList = await _apiService.viewStaffPNR(_userId);

  //     if (pnrList.isNotEmpty) {
  //       String pnr = pnrList.first.pnr;
  //       print("Fetched PNR: $pnr");
  //       return pnr; // Successfully fetched PNR
  //     }
  //   } catch (e) {
  //     print("Error fetching PNR: $e");
  //   }

  //   return "No PNR found"; // Return a default message without throwing an exception
  // }

  String? getCityFromCode(String code, List<Map<String, dynamic>> airportData) {
    final match = airportData.firstWhere(
      (entry) => entry['code'].toString().trim() == code.trim(),
      orElse: () => {'name': 'Unknown City'},
    );

    String? fullName = match['name'];
    if (fullName != null && fullName.contains(" - ")) {
      return fullName.split(" - ")[0].trim();
    }
    return fullName;
  }

  String formatDate(String date) {
    final year =
        "20" + date.substring(4, 6); // Assuming the year is in 'YY' format
    final month = date.substring(2, 4);
    final day = date.substring(0, 2);

    final dateTime = DateTime.parse("$year-$month-$day");
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  String formatTime(String time) {
    final hours = time.substring(0, 2);
    final minutes = time.substring(2, 4);

    return "$hours:$minutes (Local)";
  }

// Helper to get the standard baggage allowance for a given flight segment
  String getStandardBaggageAllowanceForFlight(
      String flightSegmentTattooNumber, TicketInformation ticket) {
    if (ticket.baggageAllowances != null) {
      for (var baggage in ticket.baggageAllowances!) {
        final Map<String, dynamic> baggageMap = baggage as Map<String, dynamic>;
        String baggageSegment =
            (baggageMap['SegmentTattooNumber'] as String?) ?? '';
        if (baggageSegment == flightSegmentTattooNumber) {
          return (baggageMap['StandardBaggageAllowance'] as String?) ?? '';
        }
      }
    }
    return '';
  }

// Helper to get the excess baggage info for a given flight segment
  String getExcessBaggageInfoForFlight(
      String flightSegmentTattooNumber, TicketInformation ticket) {
    if (ticket.baggageAllowances != null) {
      for (var baggage in ticket.baggageAllowances!) {
        final Map<String, dynamic> baggageMap = baggage as Map<String, dynamic>;
        String baggageSegment =
            (baggageMap['SegmentTattooNumber'] as String?) ?? '';
        if (baggageSegment == flightSegmentTattooNumber) {
          List<dynamic>? excessInfoList =
              baggageMap['ExcessBaggageInfo'] as List<dynamic>?;
          if (excessInfoList != null && excessInfoList.isNotEmpty) {
            return excessInfoList.map((excess) {
              final Map<String, dynamic> excessMap =
                  excess as Map<String, dynamic>;
              String type = excessMap['Type'] ?? 'N/A';
              String freeText = excessMap['FreeText'] ?? 'N/A';
              String otherDetails = excessMap['OtherDetails'] ?? 'N/A';
              print(excessMap);
              return 'Type: $type\nFreeText: $freeText\nOtherDetails: $otherDetails';
            }).join('\n\n'); // Adds a blank line between each entry
          }
        }
      }
    }
    return '';
  }

  Future<void> fetchData(String pnr) async {
    try {
      allTicketInfo = await _apiService.viewTicketInformation(pnr);
      allFlightInfo = await _apiService.viewFlightInformation(pnr);
      print(allTicketInfo);

      // Print stored ticket details
      for (var ticket in allTicketInfo) {
        print(
            'Name: ${ticket.firstName} ${ticket.lastName}, Ticket No: ${ticket.TicketNumber}, Passport: ${ticket.PassportNumber}, Seat: ${ticket.SeatMapped}, Barcode: ${ticket.Ticket2DBarcode}');
      }
      for (var flights in allFlightInfo) {
        print(
            'Flight Number: ${flights.flightNumber}, Dep Date: ${flights.depDate}, Dep Time: ${flights.depTime}, Arr Date: ${flights.arrDate}, Arr Time: ${flights.arrTime}, BoardPoint: ${flights.Boardpoint}, Off Point: ${flights.Offpoint}');
      }
    } catch (e) {
      print('Error fetching ticket information: $e');
    }
    print(allTicketInfo);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadData() async {
    String pnr = await _fetchPNR();
    TicketInformation? fetchedTicket;
    FlightInformation? fetchedFlight;

    if (pnr.isNotEmpty) {
      fetchedTicket = await _apiService
          .viewTicketInformation(pnr)
          .then((list) => list.isNotEmpty ? list.first : null);
      fetchedFlight = await _apiService
          .viewFlightInformation(pnr)
          .then((list) => list.isNotEmpty ? list.first : null);
    }

    setState(() {
      ticket = fetchedTicket;
      flight = fetchedFlight;

      if (ticket?.baggageAllowances != null &&
          ticket!.baggageAllowances!.isNotEmpty) {
        // Assuming you want to extract data from the first baggage allowance
        final Map<String, dynamic> baggageMap =
            ticket?.baggageAllowances![0] as Map<String, dynamic>;

        print("Baggage Allowance Details: $baggageMap");

        segmentTattooNumber =
            (baggageMap['SegmentTattooNumber'] as String?) ?? '';
        print("SegmentTattooNumber: $segmentTattooNumber");
        print(flight!.SegmentTattooNumber);

        // Only populate standardBaggageAllowance if SegmentTattooNumber matches flight's SegmentTattooNumber
        if (segmentTattooNumber == flight!.SegmentTattooNumber) {
          standardBaggageAllowance =
              (baggageMap['StandardBaggageAllowance'] as String?) ?? '';
          print("Standard Baggage Allowance: $standardBaggageAllowance");
        } else {
          print(
              "SegmentTattooNumber does not match, standardBaggageAllowance not populated.");
        }

        List<dynamic>? excessInfoList =
            baggageMap['ExcessBaggageInfo'] as List<dynamic>?;

        print(excessInfoList);
        if (excessInfoList != null && excessInfoList.isNotEmpty) {
          // Concatenates all excess baggage info entries
          excessBaggageInfo = excessInfoList.map((excess) {
            final Map<String, dynamic> excessMap =
                excess as Map<String, dynamic>;

            String type = excessMap['Type'] ?? 'N/A';
            String freeText = excessMap['FreeText'] ?? 'N/A';
            String otherDetails = excessMap['OtherDetails'] ?? 'N/A';

            return 'Type: $type | FreeText: $freeText | OtherDetails: $otherDetails';
          }).join('\n'); // Each entry appears on a new line

          print("Excess Baggage Info: $excessBaggageInfo");
        } else {
          print("No excess baggage info found.");
        }
      } else {
        print("No baggage allowances found in the ticket.");
      }

      _isLoading = false;
    });

    if (ticket == null) {
      print("ticket is NULL");
    } else {
      print("ticket exists: ${ticket!.TicketNumber}");
    }

    if (ticket?.Ticket2DBarcode == null || ticket!.Ticket2DBarcode!.isEmpty) {
      print("Ticket2DBarcode is NULL or EMPTY");
    } else {
      print(
          "Ticket2DBarcode exists: ${ticket!.Ticket2DBarcode!.substring(0, 20)}..."); // Print only the first 20 chars
    }

    try {
      if (ticket?.Ticket2DBarcode != null &&
          ticket!.Ticket2DBarcode!.isNotEmpty) {
        imageBytes = base64Decode(ticket!.Ticket2DBarcode!);
        print("Base64 Decoding Success");
      }
    } catch (e) {
      print("Base64 Decoding Failed: $e");
    }
  }

  // New function to load the standby status from SharedPreferences
  Future<void> _loadStandbyStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _standbyStatusMap = Map<String, bool>.from(
          jsonDecode(prefs.getString('standbyStatus') ?? '{}'));
    });
  }

  Future<void> sendData(
      double latitude,
      double longitude,
      String _userId,
      String boardPoint,
      String offPoint,
      String segmentTattooNumber,
      String pnr,
      String ticketNumber) async {
    String result = "success";
    //String result = await _apiService.sendLocationData(latitude, longitude, _userId, "Stand-by");
    print(result);

    if (result == "success") {
      String key =
          "$ticketNumber-$segmentTattooNumber"; // Unique key per segment & ticket

      setState(() {
        _standbyStatusMap[key] = true; // Store status uniquely
      });

      // Save the successful standby state for this segment in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('standbyStatus', jsonEncode(_standbyStatusMap));

      double screenWidth = MediaQuery.of(context).size.width;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Standby Successful",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(2, 77, 117, 1),
                fontSize: screenWidth * 0.06,
              ),
            ),
            content: Text(
              "Your standby request was successful.",
              style: TextStyle(
                color: Color.fromRGBO(2, 77, 117, 1),
                fontSize: screenWidth * 0.045,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "OK",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: const Color.fromRGBO(2, 77, 117, 1),
                    fontSize: screenWidth * 0.042,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      double screenWidth = MediaQuery.of(context).size.width;
      // Show failure dialog (Styled)
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Standby Failed",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color.fromRGBO(2, 77, 117, 1),
                fontSize: screenWidth * 0.06,
              ),
            ),
            content: Text(
              "Your standby request failed. Please try again.",
              style: TextStyle(
                color: const Color.fromRGBO(2, 77, 117, 1),
                fontSize: screenWidth * 0.045,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "OK",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: const Color.fromRGBO(2, 77, 117, 1),
                    fontSize: screenWidth * 0.042,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  } //success

  Future<void> _getLocation(String boardPoint, String offPoint,
      String segmentTattooNumber, String pnr, String TicketNumber) async {
    try {
      bool serviceEnabled;
      PermissionStatus permissionGranted;

      // Check if location services are enabled
      serviceEnabled = await location.serviceEnabled();
      print("Location services enabled: $serviceEnabled");

      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        print("Requested location service. Enabled: $serviceEnabled");

        if (!serviceEnabled) {
          setState(() => _error = "Location services are disabled.");
          print("Error: Location services are disabled.");
          return;
        }
      }

      // Check location permission
      permissionGranted = await location.hasPermission();
      print("Initial permission status: $permissionGranted");

      if (!_hasRequestedPermissionBefore) {
        // First time: use the system prompt
        if (permissionGranted == PermissionStatus.denied) {
          permissionGranted = await location.requestPermission();
          print(
              "Requested permission via system prompt. New status: $permissionGranted");
          _hasRequestedPermissionBefore = true;
        }
      } else {
        // Subsequent attempts: show custom dialog if permission isn't granted
        if (permissionGranted != PermissionStatus.granted) {
          bool shouldOpenSettings = await showPermissionDialog();
          if (shouldOpenSettings) {
            await ph.openAppSettings();
            // Re-check permission after returning from settings
            permissionGranted = await location.hasPermission();
            if (permissionGranted != PermissionStatus.granted) {
              setState(() => _error = "Location permission denied.");
              print("Error: Location permission still denied after settings.");
              return;
            }
          } else {
            setState(() => _error = "Location permission denied.");
            print("User declined to open settings. Permission denied.");
            return;
          }
        }
      }

      // If permission is granted, get location data
      if (permissionGranted == PermissionStatus.granted) {
        _locationData = await location.getLocation();
        print("Location data received: $_locationData");

        // Access latitude and longitude
        latitude = _locationData?.latitude;
        longitude = _locationData?.longitude;

        setState(() {
          _error = null; // Clear error if successful
        });

        print("Latitude: $latitude, Longitude: $longitude");

        await sendData(latitude!, longitude!, _userId, boardPoint, offPoint,
            segmentTattooNumber, pnr, TicketNumber);
      }
    } catch (e) {
      setState(() => _error = "Error: $e");
      print("Exception caught: $e");
    }
  }

  Future<bool> showPermissionDialog() async {
    bool? response = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        double screenWidth = MediaQuery.of(context).size.width;
        return AlertDialog(
          title: Text(
            "Location Permission Required",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color.fromRGBO(2, 77, 117, 1),
              fontSize: screenWidth * 0.06,
            ),
          ),
          content: Text(
            "Do you want to grant location access?",
            style: TextStyle(
              color: const Color.fromRGBO(2, 77, 117, 1),
              fontSize: screenWidth * 0.045,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "No",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: const Color.fromRGBO(2, 77, 117, 1),
                  fontSize: screenWidth * 0.042,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                "Yes",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: const Color.fromRGBO(2, 77, 117, 1),
                  fontSize: screenWidth * 0.042,
                ),
              ),
            ),
          ],
        );
      },
    );
    return response ?? false;
  }

  String calculateDuration(
      String depDate, String depTime, String arrDate, String arrTime) {
    // Parse the date and time strings
    final departure = DateTime(
      2000 + int.parse(depDate.substring(4)), // Year
      int.parse(depDate.substring(2, 4)), // Month
      int.parse(depDate.substring(0, 2)), // Day
      int.parse(depTime.substring(0, 2)), // Hour
      int.parse(depTime.substring(2, 4)), // Minute
    );

    final arrival = DateTime(
      2000 + int.parse(arrDate.substring(4)), // Year
      int.parse(arrDate.substring(2, 4)), // Month
      int.parse(arrDate.substring(0, 2)), // Day
      int.parse(arrTime.substring(0, 2)), // Hour
      int.parse(arrTime.substring(2, 4)), // Minute
    );

    // Calculate the duration
    final duration = arrival.difference(departure);

    // Format the duration as "Xh Ym"
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return "${hours}h ${minutes}m";
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    List<TicketInformation> displayedTickets = selectedValue == 'all'
        ? allTicketInfo
        : allTicketInfo.where((ticket) {
            String fullName = '${ticket.firstName} ${ticket.lastName}';
            return fullName == selectedValue;
          }).toList();
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/homebgnew.png"),
          fit: BoxFit.fitWidth,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.1),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(0, 43, 71, 1),
                    Color.fromRGBO(52, 164, 224, 1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(22.0),
                ),
              ),
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(22.0),
                      ),
                      child: Image(
                        image: AssetImage(
                            'assets/istockphoto-155362201-612x612 1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.05,
                        top: MediaQuery.of(context).size.height * 0.06,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              'My Ticket Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.055,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Scaffold(
                body: Stack(children: [
                if (allTicketInfo.length > 1)
                  Positioned(
                    top: screenHeight * 0.0001,
                    right: screenWidth * 0.065,
                    child: Container(
                      width:
                          screenWidth * 0.88, // Fixed width (adjust as needed)
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(0, 255, 255, 255),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color.fromARGB(0, 224, 224, 224),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * .02,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded:
                              true, // Ensures the dropdown fills the fixed width
                          value: selectedValue,
                          icon: const Icon(
                            Icons.tune_rounded,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text(
                                'All Ticket Details',
                                style: TextStyle(
                                    fontSize:
                                        screenWidth * 0.035), // Match font size
                              ),
                            ),
                            ...allTicketInfo.map((ticket) {
                              String fullName =
                                  '${ticket.firstName} ${ticket.lastName}';
                              return DropdownMenuItem(
                                value: fullName,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final textStyle =
                                        TextStyle(fontSize: screenWidth * 0.03);
                                    // Measure the text to determine if it overflows
                                    final textSpan = TextSpan(
                                        text: fullName, style: textStyle);
                                    final textPainter = TextPainter(
                                      text: textSpan,
                                      maxLines: 1,
                                      textDirection: ui.TextDirection.ltr,
                                    );
                                    textPainter.layout(
                                        maxWidth: constraints.maxWidth);
                                    final isOverflowing =
                                        textPainter.didExceedMaxLines;

                                    return GestureDetector(
                                      onLongPress: () {
                                        if (isOverflowing) {
                                          final overlay = Overlay.of(context);
                                          final RenderBox renderBox = context
                                              .findRenderObject() as RenderBox;
                                          final Offset position = renderBox
                                              .localToGlobal(Offset.zero);

                                          OverlayEntry overlayEntry =
                                              OverlayEntry(
                                            builder: (context) => Positioned(
                                              left: position.dx -
                                                  20, // Adjust as needed
                                              top: position.dy -
                                                  45, // Positioned slightly above the text
                                              child: Material(
                                                color: Colors.transparent,
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.8),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                        maxWidth: screenWidth *
                                                            0.85), // Set desired max width
                                                    child: Text(
                                                      fullName,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize:
                                                              screenWidth *
                                                                  0.03),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                          overlay.insert(overlayEntry);

                                          Future.delayed(
                                              const Duration(seconds: 2), () {
                                            overlayEntry
                                                .remove(); // Auto-dismiss the overlay after 2 seconds
                                          });
                                        }
                                      },
                                      child: Text(
                                        fullName,
                                        style: textStyle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedValue = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                Positioned.fill(
                  top: allTicketInfo.length > 1 ? screenHeight * 0.053 : 0,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.035),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //REPLACE WITH IF INFO IS THERE IN API, PASS THE ID TO API AND SEE IF DETAILS RETURN
                          if (_userId == "IN1927" ||
                              _userId == "IN1913" ||
                              _userId == "23933" ||
                              allFlightInfo.isNotEmpty) //temporary
                            Column(
                              children: displayedTickets.map<Widget>((ticket) {
                                return Container(
                                    margin: EdgeInsets.only(
                                        bottom: screenHeight * 0.02),
                                    width: screenWidth * 0.99,
                                    decoration: BoxDecoration(
                                      color:
                                          const Color.fromRGBO(49, 121, 167, 1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Stack(children: [
                                      // Content Overlay
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.035,
                                          vertical: screenHeight * 0.025,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            // Header Section
                                            Container(
                                              width: double
                                                  .infinity, // Ensures it takes the full width
                                              padding: EdgeInsets.only(
                                                  top: screenWidth *
                                                      0.04, // Padding on the top
                                                  left: screenWidth *
                                                      0.04, // Padding on the left
                                                  right: screenWidth * 0.04,
                                                  bottom: screenWidth *
                                                      0.01 // Padding on the right
                                                  // No padding at the bottom
                                                  ),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(
                                                      10), // Rounded top-left corner
                                                  topRight: Radius.circular(
                                                      10), // Rounded top-right corner
                                                  bottomLeft: Radius.circular(
                                                      0), // No rounding on bottom-left
                                                  bottomRight: Radius.circular(
                                                      0), // No rounding on bottom-right
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize
                                                    .min, // Ensures the container adjusts to content size
                                                children: [
                                                  Text("Passenger",
                                                      style: TextStyle(
                                                          fontSize:
                                                              screenWidth *
                                                                  0.038)),
                                                  LayoutBuilder(
                                                    builder:
                                                        (BuildContext context,
                                                            BoxConstraints
                                                                constraints) {
                                                      final fullName =
                                                          '${ticket!.lastName} ${ticket!.firstName}';
                                                      final textStyle =
                                                          TextStyle(
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 25, 25, 26),
                                                        fontSize:
                                                            screenWidth * 0.04,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      );

                                                      final textSpan = TextSpan(
                                                          text: fullName,
                                                          style: textStyle);
                                                      final textPainter =
                                                          TextPainter(
                                                        text: textSpan,
                                                        maxLines: 1,
                                                        textDirection: ui
                                                            .TextDirection.ltr,
                                                      );
                                                      textPainter.layout(
                                                          maxWidth: constraints
                                                              .maxWidth);
                                                      final isOverflowing =
                                                          textPainter
                                                              .didExceedMaxLines;

                                                      return GestureDetector(
                                                        onTap: () {
                                                          if (isOverflowing) {
                                                            final overlay =
                                                                Overlay.of(
                                                                    context);
                                                            final RenderBox
                                                                renderBox =
                                                                context.findRenderObject()
                                                                    as RenderBox;
                                                            final Offset
                                                                offset =
                                                                renderBox
                                                                    .localToGlobal(
                                                                        Offset
                                                                            .zero);

                                                            OverlayEntry
                                                                overlayEntry =
                                                                OverlayEntry(
                                                              builder:
                                                                  (context) =>
                                                                      Positioned(
                                                                left: offset
                                                                        .dx -
                                                                    10, // Align horizontally with the text
                                                                top: offset.dy -
                                                                    45, // Position slightly above the text
                                                                child: Material(
                                                                  color: Colors
                                                                      .transparent,
                                                                  child:
                                                                      Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            4),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              0.8),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                    ),
                                                                    child:
                                                                        ConstrainedBox(
                                                                      constraints:
                                                                          BoxConstraints(
                                                                              maxWidth: screenWidth * 0.8),
                                                                      child:
                                                                          Text(
                                                                        fullName,
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 14),
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        softWrap:
                                                                            true,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            );

                                                            overlay.insert(
                                                                overlayEntry);

                                                            Future.delayed(
                                                                const Duration(
                                                                    seconds: 2),
                                                                () {
                                                              overlayEntry
                                                                  .remove(); // Auto-dismiss the overlay after 2 seconds
                                                            });
                                                          }
                                                        },
                                                        child: Text(
                                                          fullName,
                                                          style: textStyle,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  Text(
                                                    '${ticket!.PassportNumber}',
                                                    style: TextStyle(
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 25, 25, 26),
                                                      fontSize:
                                                          screenWidth * 0.04,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          screenHeight * 0.02),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text("Ticket No",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        screenWidth *
                                                                            0.038)),
                                                            Text(
                                                              ticket!
                                                                  .TicketNumber,
                                                              style: TextStyle(
                                                                fontSize:
                                                                    screenWidth *
                                                                        0.04,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    25,
                                                                    25,
                                                                    26),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Text("Booking ref",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        screenWidth *
                                                                            0.038)),
                                                            Text(
                                                              ticket!.PNRNumber,
                                                              style: TextStyle(
                                                                fontSize:
                                                                    screenWidth *
                                                                        0.04,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    25,
                                                                    25,
                                                                    26),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          screenHeight * 0.01),
                                                  Center(
                                                    child: imageBytes != null
                                                        ? Container(
                                                            width: screenWidth *
                                                                0.8,
                                                            height:
                                                                screenHeight *
                                                                    0.1,
                                                            child: Image.memory(
                                                              imageBytes!,
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                          )
                                                        : const Text(
                                                            "No barcode available"),
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          screenHeight * 0.02),
                                                ],
                                              ),
                                            ),

                                            Container(
                                              width: double
                                                  .infinity, // Ensures it takes the full width

                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(0),
                                                  topRight: Radius.circular(0),
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10),
                                                ),
                                              ),

                                              child: Column(
                                                children: allFlightInfo
                                                    .map<Widget>((flight) {
                                                  String baggageAllowance =
                                                      getStandardBaggageAllowanceForFlight(
                                                          flight
                                                              .SegmentTattooNumber,
                                                          ticket!);
                                                  String excessInfo =
                                                      getExcessBaggageInfoForFlight(
                                                          flight
                                                              .SegmentTattooNumber,
                                                          ticket!);
                                                  print(excessInfo);
                                                  return Column(
                                                    children: [
                                                      Image.asset(
                                                        "assets/line.png",
                                                        width: screenWidth *
                                                            1, // Adjust as needed
                                                        fit: BoxFit.cover,
                                                      ),
                                                      SizedBox(
                                                          height: screenHeight *
                                                              0.01),
                                                      // Main Ticket Information - Departure and Arrival
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                          left: screenWidth *
                                                              0.04,
                                                          right: screenWidth *
                                                              0.04,
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  flight
                                                                      .Boardpoint,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        screenWidth *
                                                                            0.07,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        25,
                                                                        25,
                                                                        26),
                                                                  ),
                                                                ),
                                                                FutureBuilder<
                                                                    List<
                                                                        Map<String,
                                                                            dynamic>>>(
                                                                  future:
                                                                      airportDataFuture, // Use the initialized Future
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    if (snapshot
                                                                            .connectionState ==
                                                                        ConnectionState
                                                                            .waiting) {
                                                                      return Text(
                                                                        "Loading...",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                screenWidth * 0.03),
                                                                      );
                                                                    } else if (snapshot
                                                                            .hasError ||
                                                                        !snapshot
                                                                            .hasData ||
                                                                        snapshot
                                                                            .data!
                                                                            .isEmpty) {
                                                                      return Text(
                                                                        "Error fetching country",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                screenWidth * 0.03),
                                                                      );
                                                                    }

                                                                    final country = getCityFromCode(
                                                                        flight
                                                                            .Boardpoint,
                                                                        snapshot
                                                                            .data!);
                                                                    final displayText =
                                                                        country ??
                                                                            "Unknown country";
                                                                    final fixedWidth =
                                                                        screenWidth *
                                                                            0.16; // The maximum width the text is allowed to occupy

                                                                    return Container(
                                                                      width:
                                                                          fixedWidth,
                                                                      child:
                                                                          LayoutBuilder(
                                                                        builder:
                                                                            (context,
                                                                                constraints) {
                                                                          final textStyle =
                                                                              TextStyle(fontSize: screenWidth * 0.03);
                                                                          final textSpan = TextSpan(
                                                                              text: displayText,
                                                                              style: textStyle);
                                                                          final textPainter =
                                                                              TextPainter(
                                                                            text:
                                                                                textSpan,
                                                                            textDirection:
                                                                                ui.TextDirection.ltr,
                                                                          );
                                                                          // Layout the text with the fixed max width
                                                                          textPainter.layout(
                                                                              maxWidth: constraints.maxWidth);
                                                                          // Check if the text's width exceeds the allowed width
                                                                          final isOverflowing =
                                                                              textPainter.width >= constraints.maxWidth;

                                                                          return GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              if (isOverflowing) {
                                                                                final overlay = Overlay.of(context);
                                                                                final RenderBox renderBox = context.findRenderObject() as RenderBox;
                                                                                final Offset position = renderBox.localToGlobal(Offset.zero);

                                                                                OverlayEntry overlayEntry = OverlayEntry(
                                                                                  builder: (context) => Positioned(
                                                                                    left: position.dx, // Align horizontally with the text
                                                                                    top: position.dy - 30, // Position slightly above the text
                                                                                    child: Material(
                                                                                      color: Colors.transparent,
                                                                                      child: Container(
                                                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.black.withOpacity(0.8),
                                                                                          borderRadius: BorderRadius.circular(8),
                                                                                        ),
                                                                                        child: Text(
                                                                                          displayText,
                                                                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                );

                                                                                overlay.insert(overlayEntry);

                                                                                Future.delayed(const Duration(seconds: 2), () {
                                                                                  overlayEntry.remove();
                                                                                });
                                                                              }
                                                                            },
                                                                            child:
                                                                                Text(
                                                                              displayText,
                                                                              style: textStyle,
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        screenHeight *
                                                                            0.01),
                                                                Text(
                                                                  formatDate(flight
                                                                      .depDate),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        screenWidth *
                                                                            0.03,
                                                                    color: const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        25,
                                                                        25,
                                                                        26),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  formatTime(flight
                                                                      .depTime),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        screenWidth *
                                                                            0.03,
                                                                    color: const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        25,
                                                                        25,
                                                                        26),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            // Flight Image
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Image.asset(
                                                                  "assets/airplaneticket.png",
                                                                  width:
                                                                      screenWidth *
                                                                          0.3,
                                                                  height:
                                                                      screenHeight *
                                                                          0.05,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        screenHeight *
                                                                            0.01),
                                                                Text(
                                                                  "UL255",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          screenWidth *
                                                                              0.04,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ],
                                                            ),
                                                            // Arrival Info
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Text(
                                                                  flight
                                                                      .Offpoint,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        screenWidth *
                                                                            0.07,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        25,
                                                                        25,
                                                                        26),
                                                                  ),
                                                                ),
                                                                FutureBuilder<
                                                                    List<
                                                                        Map<String,
                                                                            dynamic>>>(
                                                                  future:
                                                                      airportDataFuture, // Use the initialized Future
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    if (snapshot
                                                                            .connectionState ==
                                                                        ConnectionState
                                                                            .waiting) {
                                                                      return Text(
                                                                        "Loading...",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                screenWidth * 0.03),
                                                                      );
                                                                    } else if (snapshot
                                                                            .hasError ||
                                                                        !snapshot
                                                                            .hasData ||
                                                                        snapshot
                                                                            .data!
                                                                            .isEmpty) {
                                                                      return Text(
                                                                        "Error fetching country",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                screenWidth * 0.03),
                                                                      );
                                                                    }

                                                                    final country = getCityFromCode(
                                                                        flight
                                                                            .Offpoint,
                                                                        snapshot
                                                                            .data!);
                                                                    final displayText =
                                                                        country ??
                                                                            "Unknown country";
                                                                    final fixedWidth =
                                                                        screenWidth *
                                                                            0.16; // The maximum width the text is allowed to occupy

                                                                    return Container(
                                                                      width:
                                                                          fixedWidth,
                                                                      child:
                                                                          LayoutBuilder(
                                                                        builder:
                                                                            (context,
                                                                                constraints) {
                                                                          final textStyle =
                                                                              TextStyle(fontSize: screenWidth * 0.03);
                                                                          final textSpan = TextSpan(
                                                                              text: displayText,
                                                                              style: textStyle);
                                                                          final textPainter =
                                                                              TextPainter(
                                                                            text:
                                                                                textSpan,
                                                                            textDirection:
                                                                                ui.TextDirection.ltr,
                                                                          );
                                                                          // Layout the text with the fixed max width
                                                                          textPainter.layout(
                                                                              maxWidth: constraints.maxWidth);
                                                                          // Check if the text's width exceeds the allowed width
                                                                          final isOverflowing =
                                                                              textPainter.width >= constraints.maxWidth;

                                                                          return GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              if (isOverflowing) {
                                                                                final overlay = Overlay.of(context);
                                                                                final RenderBox renderBox = context.findRenderObject() as RenderBox;
                                                                                final Offset position = renderBox.localToGlobal(Offset.zero);

                                                                                OverlayEntry overlayEntry = OverlayEntry(
                                                                                  builder: (context) => Positioned(
                                                                                    left: position.dx, // Align horizontally with the text
                                                                                    top: position.dy - 30, // Position slightly above the text
                                                                                    child: Material(
                                                                                      color: Colors.transparent,
                                                                                      child: Container(
                                                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.black.withOpacity(0.8),
                                                                                          borderRadius: BorderRadius.circular(8),
                                                                                        ),
                                                                                        child: Text(
                                                                                          displayText,
                                                                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                );

                                                                                overlay.insert(overlayEntry);

                                                                                Future.delayed(const Duration(seconds: 2), () {
                                                                                  overlayEntry.remove();
                                                                                });
                                                                              }
                                                                            },
                                                                            child:
                                                                                Text(
                                                                              displayText,
                                                                              style: textStyle,
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        screenHeight *
                                                                            0.01),
                                                                Text(
                                                                  formatDate(flight
                                                                      .arrDate),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        screenWidth *
                                                                            0.03,
                                                                    color: const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        25,
                                                                        25,
                                                                        26),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  formatTime(flight
                                                                      .arrTime),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        screenWidth *
                                                                            0.03,
                                                                    color: const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        25,
                                                                        25,
                                                                        26),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      // Additional Flight Details
                                                      SizedBox(
                                                          height: screenHeight *
                                                              0.02),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                          left: screenWidth *
                                                              0.04,
                                                          right: screenWidth *
                                                              0.04,
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text("Status",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              screenWidth * 0.038)),
                                                                  Text(
                                                                    flight.confirmedStatus
                                                                            .isNotEmpty
                                                                        ? flight
                                                                            .confirmedStatus[0] // Display the first status element
                                                                        : "N/A", // Fallback text if the list is empty
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            screenWidth *
                                                                                0.038,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                      "Baggage",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              screenWidth * 0.038)),
                                                                  Text(
                                                                    baggageAllowance
                                                                            .isEmpty
                                                                        ? 'N/A'
                                                                        : '${baggageAllowance}g',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          screenWidth *
                                                                              0.04,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Text(
                                                                      "Duration",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              screenWidth * 0.038)),
                                                                  Text(
                                                                    calculateDuration(
                                                                        flight
                                                                            .depDate,
                                                                        flight
                                                                            .depTime,
                                                                        flight
                                                                            .arrDate,
                                                                        flight
                                                                            .arrTime),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            screenWidth *
                                                                                0.04,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          height: screenHeight *
                                                              0.025),
                                                      Row(
                                                        children: [
                                                          if (excessBaggageInfo
                                                              .isNotEmpty)
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(
                                                                left:
                                                                    screenWidth *
                                                                        0.04,
                                                                right:
                                                                    screenWidth *
                                                                        0.04,
                                                                top: 0,
                                                                bottom: 0,
                                                              ),
                                                              child: Center(
                                                                child:
                                                                    ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    // Show a popup with the excess baggage info
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return AlertDialog(
                                                                          title:
                                                                              Text(
                                                                            "Excess Baggage Info",
                                                                            style:
                                                                                TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: const Color.fromRGBO(2, 77, 117, 1),
                                                                              fontSize: screenWidth * 0.06,
                                                                            ),
                                                                          ),
                                                                          content:
                                                                              Text(
                                                                            excessBaggageInfo.replaceAll(RegExp(r', |\|'), '\n').trim(), // Trim leading/trailing spaces
                                                                            style:
                                                                                TextStyle(
                                                                              color: const Color.fromRGBO(2, 77, 117, 1),
                                                                              fontSize: screenWidth * 0.043,
                                                                            ),
                                                                          ),
                                                                          actions: [
                                                                            TextButton(
                                                                              onPressed: () => Navigator.pop(context),
                                                                              child: Text(
                                                                                "Close",
                                                                                style: TextStyle(
                                                                                  fontWeight: FontWeight.w700,
                                                                                  color: const Color.fromRGBO(2, 77, 117, 1),
                                                                                  fontSize: screenWidth * 0.042,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                  child: const Text(
                                                                      'Excess Baggage'),
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    disabledBackgroundColor:
                                                                        const Color
                                                                            .fromARGB(
                                                                            255,
                                                                            238,
                                                                            238,
                                                                            243),
                                                                    elevation:
                                                                        0,
                                                                    foregroundColor:
                                                                        const Color
                                                                            .fromARGB(
                                                                            255,
                                                                            107,
                                                                            109,
                                                                            118),
                                                                    backgroundColor:
                                                                        const Color
                                                                            .fromARGB(
                                                                            255,
                                                                            255,
                                                                            255,
                                                                            255),
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            screenWidth *
                                                                                0.1,
                                                                        vertical:
                                                                            screenHeight *
                                                                                0.005),
                                                                    textStyle: TextStyle(
                                                                        fontSize:
                                                                            screenWidth *
                                                                                0.036),
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      side:
                                                                          const BorderSide(
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            144,
                                                                            140,
                                                                            159),
                                                                        width:
                                                                            1,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          if (excessBaggageInfo
                                                              .isEmpty)
                                                            SizedBox(
                                                              width:
                                                                  screenWidth *
                                                                      0.55,
                                                            ),
                                                          SizedBox(
                                                            width: screenWidth *
                                                                0.28, // Customize width
                                                            height: screenHeight *
                                                                0.045, // Customize height
                                                            child:
                                                                ElevatedButton(
                                                              style:
                                                                  ButtonStyle(
                                                                backgroundColor:
                                                                    MaterialStateProperty
                                                                        .resolveWith<
                                                                            Color>(
                                                                  (Set<MaterialState>
                                                                      states) {
                                                                    // Use per-segment tracking instead of a global boolean
                                                                    return _standbyStatusMap["${ticket.TicketNumber}-${flight.SegmentTattooNumber}"] ==
                                                                            true
                                                                        ? Colors
                                                                            .green
                                                                        : const Color
                                                                            .fromARGB(
                                                                            255,
                                                                            55,
                                                                            55,
                                                                            55);
                                                                  },
                                                                ),
                                                                // Force text (foreground) color to remain white in all states.
                                                                foregroundColor:
                                                                    MaterialStateProperty
                                                                        .resolveWith<
                                                                            Color>(
                                                                  (Set<MaterialState>
                                                                      states) {
                                                                    return Colors
                                                                        .white;
                                                                  },
                                                                ),
                                                                padding:
                                                                    MaterialStateProperty
                                                                        .all(
                                                                  EdgeInsets
                                                                      .symmetric(
                                                                    horizontal: _standbyStatusMap[
                                                                                "${ticket.TicketNumber}-${flight.SegmentTattooNumber}"] ==
                                                                            true
                                                                        ? screenWidth *
                                                                            0.03
                                                                        : screenWidth *
                                                                            0.05,
                                                                    vertical:
                                                                        screenHeight *
                                                                            0.005,
                                                                  ),
                                                                ),
                                                                shape:
                                                                    MaterialStateProperty
                                                                        .all(
                                                                  RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                    side:
                                                                        BorderSide(
                                                                      color: _standbyStatusMap["${ticket.TicketNumber}-${flight.SegmentTattooNumber}"] ==
                                                                              true
                                                                          ? Colors
                                                                              .green
                                                                          : const Color
                                                                              .fromARGB(
                                                                              255,
                                                                              55,
                                                                              55,
                                                                              55),
                                                                      width: 1,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              // Disable the button after successful standby for this specific segment.
                                                              onPressed: _standbyStatusMap[
                                                                          "${ticket.TicketNumber}-${flight.SegmentTattooNumber}"] ==
                                                                      true
                                                                  ? null // Disable button if standby was already successful for this segment
                                                                  : () async {
                                                                      bool
                                                                          confirmStandby =
                                                                          await showDialog<bool>(
                                                                                context: context,
                                                                                builder: (BuildContext context) {
                                                                                  return AlertDialog(
                                                                                    title: Text(
                                                                                      "Confirm Standby",
                                                                                      style: TextStyle(
                                                                                        fontWeight: FontWeight.bold,
                                                                                        color: const Color.fromRGBO(2, 77, 117, 1),
                                                                                        fontSize: screenWidth * 0.06,
                                                                                      ),
                                                                                    ),
                                                                                    content: Text(
                                                                                      "Are you sure you want to confirm standby?",
                                                                                      style: TextStyle(
                                                                                        color: const Color.fromRGBO(2, 77, 117, 1),
                                                                                        fontSize: screenWidth * 0.045,
                                                                                      ),
                                                                                    ),
                                                                                    actions: [
                                                                                      TextButton(
                                                                                        onPressed: () {
                                                                                          Navigator.of(context).pop(false); // User chose "No"
                                                                                        },
                                                                                        child: Text(
                                                                                          "No",
                                                                                          style: TextStyle(
                                                                                            fontWeight: FontWeight.w700,
                                                                                            color: const Color.fromRGBO(2, 77, 117, 1),
                                                                                            fontSize: screenWidth * 0.042,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      TextButton(
                                                                                        onPressed: () {
                                                                                          Navigator.of(context).pop(true); // User chose "Yes"
                                                                                        },
                                                                                        child: Text(
                                                                                          "Yes",
                                                                                          style: TextStyle(
                                                                                            fontWeight: FontWeight.w700,
                                                                                            color: const Color.fromRGBO(2, 77, 117, 1),
                                                                                            fontSize: screenWidth * 0.042,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  );
                                                                                },
                                                                              ) ??
                                                                              false; // Default to false if dialog returns null

                                                                      // If user confirmed standby, call _getLocation() with segmentTattooNumber
                                                                      if (confirmStandby) {
                                                                        _getLocation(
                                                                            flight.Boardpoint,
                                                                            flight.Offpoint,
                                                                            flight.SegmentTattooNumber,
                                                                            ticket.PNRNumber,
                                                                            ticket.TicketNumber);
                                                                      }
                                                                    },
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min, // Keeps row content compact
                                                                mainAxisAlignment: _standbyStatusMap[
                                                                            "${ticket.TicketNumber}-${flight.SegmentTattooNumber}"] ==
                                                                        true
                                                                    ? MainAxisAlignment
                                                                        .start
                                                                    : MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                      "Standby"),
                                                                  if (_standbyStatusMap[
                                                                          "${ticket.TicketNumber}-${flight.SegmentTattooNumber}"] ==
                                                                      true)
                                                                    SizedBox(
                                                                        width: screenWidth *
                                                                            0.02), // Adds spacing without using Padding
                                                                  if (_standbyStatusMap[
                                                                          "${ticket.TicketNumber}-${flight.SegmentTattooNumber}"] ==
                                                                      true)
                                                                    Icon(
                                                                        Icons
                                                                            .check,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            16),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      SizedBox(
                                                          height: screenHeight *
                                                              0.02),
                                                    ],
                                                  );
                                                }).toList(), // Convert the map to a List<Widget>
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]));
                              }).toList(),
                            )
                          else
                            FutureBuilder(
                              future: Future.delayed(Duration(
                                  seconds: 6)), // Adjust delay as needed
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox(); // Show nothing while waiting
                                }
                                return Align(
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: [
                                      SizedBox(height: screenHeight * 0.15),
                                      Image.asset(
                                        'assets/noticket.png',
                                        width: screenWidth * 0.4,
                                        height: screenHeight * 0.2,
                                        fit: BoxFit.fill,
                                      ),
                                      Text(
                                        'Sorry..',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.065,
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromARGB(
                                              255, 93, 93, 93),
                                        ),
                                      ),
                                      Text(
                                        'You do not have any',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.06,
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromARGB(
                                              255, 93, 93, 93),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        'booking information',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.06,
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromARGB(
                                              255, 93, 93, 93),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ])),
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22.0)),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(2, 77, 117, 1),
                  Color.fromRGBO(2, 77, 117, 1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: 2,
              selectedItemColor: const Color.fromARGB(255, 234, 248, 249),
              unselectedItemColor: Colors.white,
              onTap: (index) async {
                switch (index) {
                  case 0:
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const HistoryPage(),
                        transitionDuration: const Duration(seconds: 0),
                      ),
                    );
                    break;
                  case 1:
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const HomePage(
                          selectedDate: '',
                        ),
                        transitionDuration:
                            const Duration(seconds: 0), // No animation
                      ),
                    );
                  case 2: // My Tickets
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const MyTickets(),
                        transitionDuration:
                            const Duration(seconds: 0), // No animation
                      ),
                    );
                    break;
                  case 3: // Logout
                    bool? confirmLogout = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            "Confirm Logout",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: const Color.fromRGBO(2, 77, 117, 1),
                              fontSize: screenWidth * 0.06,
                            ),
                          ),
                          content: Text(
                            "Are you sure you want to log out?",
                            style: TextStyle(
                              color: const Color.fromRGBO(2, 77, 117, 1),
                              fontSize: screenWidth * 0.045,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(false); // User chose "No"
                              },
                              child: Text(
                                "No",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: const Color.fromRGBO(2, 77, 117, 1),
                                  fontSize: screenWidth * 0.042,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(true); // User chose "Yes"
                              },
                              child: Text(
                                "Yes",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: const Color.fromRGBO(2, 77, 117, 1),
                                  fontSize: screenWidth * 0.042,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    // If the user confirms, perform the logout
                    if (confirmLogout == true) {
                      _logout(); // Call the logout function
                    }
                    break;
                }
              },
              items: [
                _buildCustomBottomNavigationBarItem(
                    Icons.history, 'History', false),
                _buildCustomBottomNavigationBarItem(Icons.home, 'Home', false),
                _buildCustomBottomNavigationBarItem(
                    Icons.airplane_ticket_outlined, 'My Tickets', true),
                _buildCustomBottomNavigationBarItem(
                    Icons.logout, 'Logout', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildCustomBottomNavigationBarItem(
      IconData icon, String label, bool isHighlighted) {
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          isHighlighted
              ? Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 234, 248, 249),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    icon,
                    color: const Color.fromRGBO(2, 77, 117, 1),
                  ),
                )
              : Icon(icon),
        ],
      ),
      label: label,
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyLoginPage()),
    );
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? displayName = prefs.getString('displayName');
    setState(() {
      _userName = displayName ?? 'User Name';
    });
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    setState(() {
      _userId = userId ?? '123456';
    });
  }
}
