import 'package:flista_new/models/ticketInformationmodel.dart';
import 'package:flista_new/models/flightmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/staffmodel.dart';
import 'home.dart';
import 'history.dart';
import 'main.dart';

class MyPriorityPage extends StatefulWidget {
  final String selectedDate;
  final String scheduledTime;
  final String selectedUL;
  final String originCountryCode;
  final String destinationCountryCode;
  final List<String> ulList;
  const MyPriorityPage({
    Key? key,
    required this.selectedDate,
    required this.selectedUL,
    required this.scheduledTime,
    required this.originCountryCode,
    required this.destinationCountryCode,
    required this.ulList,
  }) : super(key: key);

  @override
  _MyPriorityState createState() => _MyPriorityState();
}

class _MyPriorityState extends State<MyPriorityPage> {
  final APIService _apiService = APIService();
  late String selectedDate;
  late String selectedUL;
  late List<String> ulList;
  late String _userId;
  List<StaffMember> staffMembers = [];
  bool isLoading = true;
  int _selectedIndex = 0;
  late String _userName = 'User Name';
  List<TicketInformation> allTicketInfo = [];
  List<FlightInformation> allFlightInfo = [];
  late Future<List<Map<String, dynamic>>> airportDataFuture;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate; // Initialize the selected date
    selectedUL =
        widget.selectedUL; // Initialize selectedUL with the passed value
    ulList = widget.ulList;

    airportDataFuture = APIService.getOriginsAndDestinations();
    _loadUserName();
    _loadUserIdFromPreferences().then((_) {
      fetchData();
    });
  }

  String? getCountryFromCode(
      String code, List<Map<String, dynamic>> airportData) {
    final match = airportData.firstWhere((entry) => entry['code'] == code,
        orElse: () => {});
    return match['name'];
  }

  // Add this function to handle logout
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyLoginPage()),
    );
  }

  Future<void> _loadUserIdFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId') ??
          '16231'; // Load the userId (default to '123456')
    });
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? displayName = prefs.getString('displayName');
    setState(() {
      _userName = displayName ?? 'User Name';
    });
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

  void fetchData() {
    _apiService
        .viewStaffMembers(
      selectedDate,
      widget.originCountryCode,
      selectedUL,
    )
        .then((response) async {
      setState(() {
        // Filter staff members based on userId or userName
        if (_userId == 'IN1913' ||
            _userId == 'IN1927' ||
            _userId == '23799' ||
            _userId == '23933' ||
            _userId == '16763' ||
            _userId == '12988') {
          staffMembers = response;
        } else {
          staffMembers = response.where((staff) {
            String fullName = '${staff.firstName} ${staff.lastName}';
            // Display staff if their ID matches _userId or name matches _userName
            return staff.staffID == _userId ||
                fullName.toLowerCase() == _userName.toLowerCase();
          }).toList();
        }

        // Sort staffMembers by priority, with missing priority at the bottom
        staffMembers.sort((a, b) {
          if (a.priority == "" && b.priority == "") {
            return 0;
          } else if (a.priority == "") {
            return 1;
          } else if (b.priority == "") {
            return -1;
          } else {
            return a.priority.compareTo(b.priority);
          }
        });

        isLoading = false;
      });
      print("imasha");

      for (var staff in staffMembers) {
        try {
          if (staff.pnr.isNotEmpty) {
            // Fetch ticket information for the given PNR
            final ticketInfoList =
                await _apiService.viewTicketInformation(staff.pnr);

            // Add the fetched ticket information to the list
            allTicketInfo.addAll(ticketInfoList);

            // Optional: Print details for debugging
            print('PNR: ${staff.pnr}');
            for (var ticketInfo in ticketInfoList) {
              print('--- Ticket Information ---');
              print(
                  'Passenger Name: ${ticketInfo.firstName} ${ticketInfo.lastName}');
              print('Ticket Number: ${ticketInfo.TicketNumber}');
              print('Flight Numbers: ${ticketInfo.FlightNumbers}');
              print('Passport Number: ${ticketInfo.PassportNumber}');
              print('Seat Mapped: ${ticketInfo.SeatMapped}');

              print('--------------------------');
            }
          } else {
            print(
                'No PNR available for staff: ${staff.firstName} ${staff.lastName}');
          }
        } catch (error) {
          print(
              'Error fetching ticket information for PNR ${staff.pnr}: $error');
        }
      }
      for (var staff in staffMembers) {
        try {
          if (staff.pnr.isNotEmpty) {
            // Fetch flight information for the given PNR
            final flightInfoList =
                await _apiService.viewFlightInformation(staff.pnr);

            // Add the fetched flight information to the list
            allFlightInfo.addAll(flightInfoList);

            // Optional: Print details for debugging
            print('PNR: ${staff.pnr}');
            for (var flightInfo in flightInfoList) {
              print('--- Flight Information ---');
              print('Dep Date: ${flightInfo.depDate}');
              print('Dep Time: ${flightInfo.depTime}');
              print('Arr Date: ${flightInfo.arrDate}');
              print('Arr Time: ${flightInfo.arrTime}');
              print('--------------------------');
            }
          } else {
            print('PNR is empty for staff member: ${staff.firstName}');
          }
        } catch (error) {
          print(
              'Error fetching flight information for PNR ${staff.pnr}: $error');
        }
      }
    }).catchError((error) {
      print('Error fetching data: $error');
      setState(() {
        staffMembers = [];
        isLoading = false;
      });
    }, test: (error) => error is Exception);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HistoryPage()),
          );
          break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(selectedDate: selectedDate)),
          );
          break;
        case 2:
          // Navigate to Info Page
          break;
      }
    });
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

  void _changeUL(bool next) {
    setState(() {
      int currentIndex = ulList.indexOf(selectedUL);

      if (next) {
        if (currentIndex < ulList.length - 1) {
          selectedUL = ulList[currentIndex + 1];
        } else {
          // Handle if already at the last UL number
        }
      } else {
        if (currentIndex > 0) {
          selectedUL = ulList[currentIndex - 1];
        } else {
          // Handle if already at the first UL number
        }
      }
    });
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

//TICKET INFORMATION DISPLAY
  void showTicketDetailsPopup(
    BuildContext context,
    StaffMember staffMember,
    TicketInformation ticket,
    FlightInformation flight,
    String flightNumber,
    String originCountryCode,
    String destinationCountryCode,
    String selectedUL,
  ) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color.fromRGBO(49, 121, 167, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Section with Background and Title
              Stack(
                children: [
                  Container(
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.08,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/airplanebg.png"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                  ),
                  Positioned(
                    top: screenHeight * 0.02,
                    left: screenWidth * 0.05,
                    child: Text(
                      "Ticket Details",
                      style: TextStyle(
                        fontSize: screenHeight * 0.025,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    top: screenHeight * 0.01,
                    right: screenWidth * 0.05,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
              // Main Ticket Information
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/ticketCard.png"),
                    fit: BoxFit.fill,
                  ),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: screenHeight * 0.03,
                    vertical: screenWidth * 0.015),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: screenHeight * 0.01),
                        // Flight Information Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  flight.Boardpoint,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.07,
                                    fontWeight: FontWeight.w900,
                                    color:
                                        const Color.fromRGBO(49, 121, 167, 1),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                FutureBuilder<List<Map<String, dynamic>>>(
                                  future:
                                      APIService.getOriginsAndDestinations(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text(
                                        "Loading country...",
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.03),
                                      );
                                    } else if (snapshot.hasError ||
                                        !snapshot.hasData) {
                                      return Text(
                                        "Error fetching country",
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.03),
                                      );
                                    }
                                    final country = getCountryFromCode(
                                        flight.Boardpoint, snapshot.data!);
                                    return Text(
                                      country ?? "Unknown country",
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.03),
                                    );
                                  },
                                ),
                                Text(
                                  formatDate(flight.depDate),
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  formatTime(flight.depTime),
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  flight.Offpoint,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.07,
                                    fontWeight: FontWeight.w900,
                                    color:
                                        const Color.fromRGBO(49, 121, 167, 1),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                FutureBuilder<List<Map<String, dynamic>>>(
                                  future:
                                      APIService.getOriginsAndDestinations(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text(
                                        "Loading country...",
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.03),
                                      );
                                    } else if (snapshot.hasError ||
                                        !snapshot.hasData) {
                                      return Text(
                                        "Error fetching country",
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.03),
                                      );
                                    }
                                    final country = getCountryFromCode(
                                        flight.Offpoint, snapshot.data!);
                                    return Text(
                                      country ?? "Unknown country",
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.03),
                                    );
                                  },
                                ),
                                Text(
                                  formatDate(flight.arrDate),
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  formatTime(flight.arrTime),
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Image.asset(
                          "assets/airplaneProgress.png",
                          width: screenWidth * 0.2,
                          height: screenHeight * 0.1,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Passenger Information - Single line
                            Text(
                              "Passenger",
                              style: TextStyle(
                                fontSize: screenWidth * 0.038,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.008),
                            Text(
                              "${staffMember.firstName} ${staffMember.lastName} (${ticket.PassportNumber})",
                              style: TextStyle(
                                fontSize: screenWidth * 0.036,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),

                            // Row with Ticket No and Flight
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Ticket No",
                                          style: TextStyle(
                                              fontSize: screenWidth * 0.038)),
                                      Text(
                                        ticket.TicketNumber,
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.038,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Flight",
                                          style: TextStyle(
                                              fontSize: screenWidth * 0.038)),
                                      Text(
                                        flightNumber,
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.038,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),

                            // Row with PNR and Seat
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("PNR",
                                          style: TextStyle(
                                              fontSize: screenWidth * 0.038)),
                                      Text(
                                        staffMember.pnr,
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.038,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Seat",
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.038),
                                      ),
                                      Text(
                                        ticket.SeatMapped.isEmpty
                                            ? '  -  '
                                            : ticket
                                                .SeatMapped, // Check if SeatMapped is empty
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.038,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign
                                            .center, // Center align the text
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),

                            // Row with Status and Duration
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Status",
                                          style: TextStyle(
                                              fontSize: screenWidth * 0.038)),
                                      Text(
                                        staffMember.status,
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.038,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Duration",
                                          style: TextStyle(
                                              fontSize: screenWidth * 0.038)),
                                      Text(
                                        calculateDuration(
                                            flight.depDate,
                                            flight.depTime,
                                            flight.arrDate,
                                            flight.arrTime),
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.038,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Button at the end
                        SizedBox(height: screenHeight * 0.025),
                        Center(
                          child: SizedBox(
                            width: screenWidth * 0.4,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 205, 85, 33),
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.015,
                                  horizontal: screenWidth * 0.09,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      screenHeight * 0.01),
                                ),
                              ),
                              child: Text(
                                "Close",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.038,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
            ],
          ),
        );
      },
    );
  }

// END OF TICKET INFORMATION DISPLAY

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeigth = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeigth * 0.153), //130.0
        child: AppBar(
          backgroundColor: Colors.transparent,
          titleTextStyle:
              const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          leading: Transform.translate(
            offset: const Offset(8.0, 12.0),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),
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
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(22.0)),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(22.0)),
                    child: Container(
                      child: const Image(
                        image: AssetImage(
                            'assets/istockphoto-155362201-612x612 1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // New content added to the flexibleSpace
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeigth * 0.007),
                      // Image above the form card
                      SizedBox(
                        height:
                            screenHeigth * 0.13, // Adjust the height as needed
                        width: screenWidth * 0.78,
                        child: const Image(
                          image: AssetImage('assets/airplane-route.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Transform.translate(
                              offset: Offset(
                                  -screenWidth * 0.035, -screenHeigth * 0.035),
                              child: Text(
                                widget.originCountryCode
                                    .trim(), // Trim to remove leading/trailing spaces
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.06),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Transform.translate(
                              offset: Offset(
                                  screenWidth * 0.08, -screenHeigth * 0.035),
                              child: Text(
                                widget.destinationCountryCode
                                    .trim(), // Trim to remove leading/trailing spaces
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.06),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          : Transform.translate(
              offset: Offset(screenWidth * -0.001, 0),
              child: SingleChildScrollView(
                // Wrap the form with SingleChildScrollView
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeigth * 0.02),
                    // Form card
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.all(14.0),
                      width: screenWidth * 0.95,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromRGBO(51, 123, 169, 1),
                            Color.fromRGBO(2, 77, 117, 1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: screenHeigth * 0.02),
                          SizedBox(
                            height: screenHeigth * 0.17,
                            width: screenWidth * .8,
                            child: Transform.translate(
                              offset: const Offset(0.4, -15.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  // Handle checking availability
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(158, 38, 64, 112),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.1,
                                      vertical: screenHeigth * 0.001),
                                  // Adjusted padding
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          '          UL $selectedUL',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: screenWidth * 0.06,
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * .03),
                                        // Added SizedBox for spacing
                                      ],
                                    ),
                                    SizedBox(height: screenHeigth * 0.002),
                                    Text(
                                      ' on $selectedDate', // Use selectedDate variable here
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenWidth * .04,
                                      ),
                                    ),
                                    SizedBox(height: screenHeigth * 0.002),
                                    Text(
                                      '  ${widget.scheduledTime.substring(0, 2)}:${widget.scheduledTime.substring(2)}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenWidth * .04,
                                      ),
                                    ),
                                    SizedBox(height: screenHeigth * 0.002),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Transform.translate(
                                    offset: Offset(screenWidth * 0.3, 0.0),
                                    child: Text(
                                      'My Priority',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenWidth * .05),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15.0,
                              ),
                              // Display a message if there are no staff members
                              if (staffMembers.isEmpty)
                                Text(
                                  'No staff information available',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * .04,
                                  ),
                                )
                              else
                                Column(
                                  children: staffMembers.map((staff) {
                                    return Column(
                                      children: [
                                        SizedBox(
                                          width: screenWidth * 2,
                                          height: screenHeigth * 0.175,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              // Assuming you have ticket data associated with the staff member
                                              TicketInformation ticket =
                                                  await _apiService
                                                      .viewTicketInformation(
                                                          staff.pnr)
                                                      .then((ticketList) {
                                                // You can get the ticket you need based on your logic
                                                return ticketList
                                                    .first; // Modify this according to your requirement
                                              });

                                              FlightInformation flight =
                                                  await _apiService
                                                      .viewFlightInformation(
                                                          staff.pnr)
                                                      .then((flightList) {
                                                // You can get the ticket you need based on your logic
                                                return flightList
                                                    .first; // Modify this according to your requirement
                                              });

                                              // Show the popup with staff and ticket details
                                              showTicketDetailsPopup(
                                                  context,
                                                  staff,
                                                  ticket,
                                                  flight,
                                                  widget.originCountryCode,
                                                  widget.destinationCountryCode,
                                                  widget.scheduledTime,
                                                  selectedUL);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      48, 53, 106, 204),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(9.0),
                                              ),
                                              padding: const EdgeInsets.all(
                                                  17.0), // Consistent padding
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      // Full name and ID
                                                      Text(
                                                        '${staff.title}. ${staff.firstName} ${staff.lastName} (${staff.staffID})',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize:
                                                              screenWidth *
                                                                  0.04,
                                                        ),
                                                      ),
                                                      // Priority and Status row
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              'Priority - ${staff.priority}',
                                                              style: TextStyle(
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    255,
                                                                    251,
                                                                    21),
                                                                fontSize:
                                                                    screenWidth *
                                                                        0.035,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            'Status - ${staff.actionStatus}',
                                                            style: TextStyle(
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  255, 110, 26),
                                                              fontSize:
                                                                  screenWidth *
                                                                      0.035,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: screenHeigth * 0.015),
                                      ],
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeigth * 0.02),
                  ],
                ),
              ),
            ),
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
            backgroundColor: Colors.transparent,
            elevation: 1,
            currentIndex: 0,
            selectedItemColor: const Color.fromARGB(255, 234, 248, 249),
            unselectedItemColor: Colors.white,
            onTap: (index) async {
              switch (index) {
                case 0:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HistoryPage()),
                  );
                  break;
                case 1:
                  // Navigate to Home Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HomePage(selectedDate: selectedDate)),
                  );
                  break;
                case 2:
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
              _buildCustomBottomNavigationBarItem(Icons.home, 'Home', true),
              _buildCustomBottomNavigationBarItem(
                  Icons.logout, 'Logout', false),
            ],
          ),
        ),
      ),
    );
  }
}
