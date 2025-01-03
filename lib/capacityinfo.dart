import 'package:flista_new/models/staffmodel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'priority.dart';
import '../services/api_service.dart';
import '../models/flightloadmodel.dart';
import 'dart:core';
import './history.dart';
import 'home.dart';
import './mypriority.dart';

class CapacityInfoPage extends StatefulWidget {
  final String selectedDate;
  final String selectedUL;
  final String scheduledTime;
  final String originCountryCode;
  final String destinationCountryCode;
  final List<String> ulList;
  final Function(String) onULSelected;

  const CapacityInfoPage({
    Key? key,
    required this.selectedDate,
    required this.selectedUL,
    required this.scheduledTime,
    required this.originCountryCode,
    required this.destinationCountryCode,
    required this.ulList,
    required this.onULSelected,
  }) : super(key: key);

  @override
  _CapacityInfoState createState() => _CapacityInfoState();
}

class _CapacityInfoState extends State<CapacityInfoPage> {
  late String selectedDate;
  late String selectedUL; // Initialize selectedUL
  late List<String> ulList; // Initialize ulList
  FlightLoadModel? flightLoad;
  late String formattedDate; // Declare formattedDate property
  late String formattedLongDate;
  bool isLoading = true;
  List<StaffMember> staffMembers = [];

  final APIService _apiService = APIService();
  late String _userName = 'User Name';
  late String _userId = '123456';

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
    selectedUL =
        widget.selectedUL; // Initialize selectedUL with the passed value
    ulList = widget.ulList; // Initialize ulList with the passed value
    formattedDate =
        APIService().formatDate(selectedDate); // Assign formattedDate value
    formattedLongDate = APIService()
        .formatLongDate(selectedDate); // Assign formattedLongDate value
    _fetchFlightLoadInfo();
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

  void fetchData() {
    _apiService
        .viewStaffMembers(
      selectedDate,
      widget.originCountryCode,
      selectedUL,
    )
        .then((response) {
      setState(() {
        staffMembers = response; // Update the list of staff members
        isLoading = false;
      });
      print(response);
    }).catchError((error) {
      print('Error fetching data: $error');
      setState(() {
        // Clear the staff members list and set isLoading to false
        staffMembers = [];
        isLoading = false;
      });
    }, test: (error) => error is Exception);
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

  void _fetchFlightLoadInfo() async {
    try {
      List<FlightLoadModel> flightLoadDataList =
          await APIService().fetchFlightLoadInfo(
        widget.selectedDate,
        formattedDate, // Pass the updated formatted date
        formattedLongDate, // Pass the updated formatted long date
        widget.originCountryCode,
        widget.destinationCountryCode,
        widget.selectedUL,
      );

      setState(() {
        if (flightLoadDataList.isNotEmpty) {
          flightLoad = flightLoadDataList.first;
        }
        isLoading = false; // Hide loader after data is fetched

        // Print each property of the fetched FlightLoadModel
        print('Jcapacity: "${flightLoad?.jCapacity}",');
        print('Ycapacity: "${flightLoad?.yCapacity}",');
        print('Jbooked: "${flightLoad?.jBooked}",');
        print('Ybooked: "${flightLoad?.yBooked}",');
        print('Jcheckedin: "${flightLoad?.jCheckedIn}",');
        print('Ycheckedin: "${flightLoad?.yCheckedIn}",');
        print('JCommercialStandby: "${flightLoad?.jCommercialStandby}",');
        print('YCommercialStandby: "${flightLoad?.yCommercialStandby}",');
        print('JStaffListed: "${flightLoad?.jStaffListed}",');
        print('YStaffListed: "${flightLoad?.yStaffListed}",');
        print('JstaffOnStandby: "${flightLoad?.jStaffOnStandby}",');
        print('YstaffOnStandby: "${flightLoad?.yStaffOnStandby}",');
        print('JstaffAccepted: "${flightLoad?.jStaffAccepted}",');
        print('YstaffAccepted: "${flightLoad?.yStaffAccepted}",');
      });
    } catch (error) {
      print('Error fetching flight load information: $error');
      setState(() {
        isLoading = false; // Hide loader in case of error
      });
    }
  }

  void _navigateToPriorityPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PriorityPage(
              selectedDate: selectedDate,
              selectedUL: selectedUL,
              scheduledTime: widget.scheduledTime,
              originCountryCode: widget.originCountryCode,
              destinationCountryCode: widget.destinationCountryCode,
              ulList: ulList)),
    );
  }

  void _navigateToMyPriorityPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MyPriorityPage(
              selectedDate: selectedDate,
              selectedUL: selectedUL,
              scheduledTime: widget.scheduledTime,
              originCountryCode: widget.originCountryCode,
              destinationCountryCode: widget.destinationCountryCode,
              ulList: ulList)),
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

  void _changeUL(bool next) {
    setState(() {
      isLoading = true; // Show loader when arrow is clicked

      // Update selectedDate based on arrow direction
      if (next) {
        selectedDate = _getNextDate(selectedDate);
      } else {
        selectedDate = _getPreviousDate(selectedDate);
      }

      // Update formattedDate and formattedLongDate with the new date values
      formattedDate = APIService().formatDate(selectedDate);
      formattedLongDate = APIService().formatLongDate(selectedDate);

      print('Selected Date: $selectedDate'); // Debug print statement
      print('Formatted Date: $formattedDate'); // Debug print statement
      print('Formatted Long Date: $formattedLongDate'); // Debug print statement

      // Fetch flight load information for the updated date
      _fetchFlightLoadInfo();
    });
  }

  String _getNextDate(String currentDate) {
    List<String> parts = currentDate.split(' ');
    int day = int.parse(parts[0]);
    String month = parts[1];
    int year = int.parse(parts[2]);
    DateTime parsedDate = DateTime(year, _getMonthNumber(month), day);
    DateTime nextDate = parsedDate.add(const Duration(days: 1));
    return "${nextDate.day} ${_getMonthName(nextDate.month)} ${nextDate.year}";
  }

  String _getPreviousDate(String currentDate) {
    List<String> parts = currentDate.split(' ');
    int day = int.parse(parts[0]);
    String month = parts[1];
    int year = int.parse(parts[2]);
    DateTime parsedDate = DateTime(year, _getMonthNumber(month), day);
    DateTime previousDate = parsedDate.subtract(const Duration(days: 1));
    return "${previousDate.day} ${_getMonthName(previousDate.month)} ${previousDate.year}";
  }

  int _getMonthNumber(String month) {
    switch (month) {
      case 'January':
        return 1;
      case 'February':
        return 2;
      case 'March':
        return 3;
      case 'April':
        return 4;
      case 'May':
        return 5;
      case 'June':
        return 6;
      case 'July':
        return 7;
      case 'August':
        return 8;
      case 'September':
        return 9;
      case 'October':
        return 10;
      case 'November':
        return 11;
      case 'December':
        return 12;
      default:
        throw FormatException("Invalid month: $month");
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        throw FormatException("Invalid month number: $month");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeigth = MediaQuery.of(context).size.height;
    bool areButtonsEnabled = false; // Initialize as false
    _loadUserName();
    _loadUserId();
    print(_userId);

    // Check if any staff member matches the condition
    for (var staff in staffMembers) {
      // Exclude staff with ID '23799' from the condition

      // Apply the regular condition for other staff members
      String fullName = '${staff.firstName} ${staff.lastName}';
      if (fullName == _userName && staff.staffID == _userId) {
        areButtonsEnabled = true; // Enable buttons for matching staff
        break; // Exit the loop early if condition is met
      }
    }
    if (_userId == '23799') {
      areButtonsEnabled = true; // Enable buttons for this staff ID
      // Exit the loop early if condition is met
    }
    print('areButtonsEnabled: $areButtonsEnabled');

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeigth * 0.153),
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
                      SizedBox(
                        height: screenHeigth * 0.007,
                      ),
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
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue), // Set the color to blue
              ),
            )
          : Transform.translate(
              offset: Offset(screenWidth * -0.001, screenHeigth * 0.001),
              child: SingleChildScrollView(
                child: SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeigth * 0.02),
                      SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          margin: const EdgeInsets.all(14.0),
                          height: screenHeigth * 0.72,
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
                          child: Stack(
                            children: [
                              Positioned(
                                right: 0,
                                top: 45,
                                bottom: 0,
                                child: Transform.translate(
                                  offset: Offset(
                                      screenWidth * 0.05, screenHeigth * 0.002),
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        right: screenWidth * 0.005),
                                    child: Image(
                                      image: const AssetImage(
                                          'assets/flight seatng 1.png'),
                                      fit: BoxFit.contain,
                                      width: screenWidth * 0.42,
                                    ),
                                  ),
                                ),
                              ),
                              // Adjust the padding to move the image to the right

                              Column(
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
                                              Color.fromARGB(75, 53, 87, 151),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(9.0),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: screenWidth * 0.1,
                                              vertical: screenHeigth * 0.001),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Transform.translate(
                                                  offset: Offset(
                                                      screenWidth * -0.03, 0.0),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      _changeUL(
                                                          false); // Change to previous UL number
                                                    },
                                                    child: const Icon(
                                                      Icons
                                                          .arrow_back_ios_rounded,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '       UL $selectedUL',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        screenWidth * 0.06,
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: screenWidth * .03),
                                                Transform.translate(
                                                  offset: Offset(
                                                      screenWidth * 0.04, 0.0),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      _changeUL(
                                                          true); // Change to next UL number
                                                    },
                                                    child: const Icon(
                                                      Icons
                                                          .arrow_forward_ios_rounded,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                // Added SizedBox for spacing
                                              ],
                                            ),
                                            SizedBox(
                                                height: screenHeigth * 0.002),
                                            Text(
                                              '  on $selectedDate', // Use selectedDate variable here
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: screenWidth * .04,
                                              ),
                                            ),
                                            SizedBox(
                                                height: screenHeigth * 0.002),
                                            Text(
                                              ' ${widget.scheduledTime.substring(0, 2)}:${widget.scheduledTime.substring(2)}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: screenWidth * .04,
                                              ),
                                            ),
                                            SizedBox(
                                                height: screenHeigth * 0.001),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .end, // Space between items
                                        children: [
                                          Text(
                                            'BC', // Business Class
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: screenWidth * 0.041,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(
                                            width: screenWidth * 0.09,
                                          ),
                                          Text(
                                            'EY', // Economy Class
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: screenWidth * 0.041,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(
                                            width: screenWidth * 0.04,
                                          ),
                                        ],
                                      ),

                                      // Capacity information content
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Capacity  ',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      screenWidth * 0.041)),
                                          Transform.translate(
                                            offset: Offset(screenWidth * 0.17,
                                                -0.5), //100.5
                                            child: Container(
                                              height: screenHeigth * 0.035,
                                              width: screenWidth * 0.075,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Center(
                                                child: Text(
                                                    '${flightLoad?.jCapacity}'),
                                              ),
                                            ),
                                          ),
                                          Transform.translate(
                                            offset: Offset(-screenWidth * 0.01,
                                                -0.5), //-12.55
                                            child: Container(
                                              height: screenHeigth * 0.035,
                                              width: screenWidth * 0.09,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Center(
                                                child: Text(
                                                    '${flightLoad?.yCapacity}'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Add more rows for other capacity information
                                      SizedBox(height: screenHeigth * 0.01),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Booked ',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      screenWidth * 0.041)),
                                          Transform.translate(
                                            offset: Offset(screenWidth * 0.188,
                                                1.0), //87.0
                                            child: Container(
                                              height: screenHeigth * 0.035,
                                              width: screenWidth * 0.075,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Center(
                                                child: Text(
                                                    '${flightLoad?.jBooked}'),
                                              ),
                                            ),
                                          ),
                                          Transform.translate(
                                            offset: Offset(-screenWidth * 0.01,
                                                1.0), //-11.55
                                            child: Container(
                                              height: screenHeigth * 0.035,
                                              width: screenWidth * 0.09,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Center(
                                                child: Text(
                                                    '${flightLoad?.yBooked}'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeigth * 0.01),
                                      // Add more rows for other capacity information
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Checked-In  ',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      screenWidth * 0.041)),
                                          Transform.translate(
                                            offset: Offset(screenWidth * 0.145,
                                                1.0), //52.0
                                            child: Container(
                                              height: screenHeigth * 0.035,
                                              width: screenWidth * 0.075,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Center(
                                                child: Text(
                                                    '${flightLoad?.jCheckedIn}'),
                                              ),
                                            ),
                                          ),
                                          Transform.translate(
                                            offset: Offset(-screenWidth * 0.012,
                                                1.0), //-11.55
                                            child: Container(
                                              height: screenHeigth * 0.035,
                                              width: screenWidth * 0.09,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Center(
                                                child: Text(
                                                    '${flightLoad?.yCheckedIn}'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeigth * 0.01),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Commercial Standby',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      screenWidth * 0.041)),
                                          Transform.translate(
                                            offset: Offset(screenWidth * 0.065,
                                                1.0), //87.0
                                            child: Container(
                                              height: screenHeigth * 0.035,
                                              width: screenWidth * 0.075,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Center(
                                                child: Text(
                                                    '${flightLoad?.jCommercialStandby}'),
                                              ),
                                            ),
                                          ),
                                          Transform.translate(
                                            offset: Offset(-screenWidth * 0.013,
                                                1.0), //-11.50
                                            child: Container(
                                              height: screenHeigth * 0.035,
                                              width: screenWidth * 0.09,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Center(
                                                child: Text(
                                                    '${flightLoad?.yCommercialStandby}'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeigth * 0.01),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Staff Listed  ',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      screenWidth * 0.041)),
                                          Transform.translate(
                                            offset: Offset(
                                                screenWidth * 0.14, 1.0), //65.0
                                            child: Container(
                                              height: screenHeigth * 0.035,
                                              width: screenWidth * 0.075,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Center(
                                                child: Text(
                                                    '${flightLoad?.jStaffListed ?? 0}'),
                                              ),
                                            ),
                                          ),
                                          Transform.translate(
                                            offset: Offset(-screenWidth * 0.016,
                                                1.0), //-11.50
                                            child: Container(
                                              height: screenHeigth * 0.035,
                                              width: screenWidth * 0.09,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Center(
                                                child: Text(
                                                    '${flightLoad?.yStaffListed ?? 0}'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeigth * 0.01),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Staff on Standby',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      screenWidth * 0.041)),
                                          Transform.translate(
                                            offset: Offset(screenWidth * 0.105,
                                                1.0), //31.0
                                            child: Container(
                                              height: screenHeigth * 0.035,
                                              width: screenWidth * 0.075,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Center(
                                                child: Text(
                                                    '${flightLoad?.jStaffOnStandby ?? 0}'),
                                              ),
                                            ),
                                          ),
                                          Transform.translate(
                                            offset: Offset(-screenWidth * 0.016,
                                                1.0), //-11.50
                                            child: Container(
                                              height: screenHeigth * 0.035,
                                              width: screenWidth * 0.09,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Center(
                                                child: Text(
                                                    '${flightLoad?.yStaffOnStandby ?? 0}'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeigth * 0.01),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Staff Accepted',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      screenWidth * 0.041)),
                                          Transform.translate(
                                            offset: Offset(screenWidth * 0.125,
                                                1.0), //31.0
                                            child: Container(
                                              height: screenHeigth * 0.035,
                                              width: screenWidth * 0.075,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Center(
                                                child: Text(
                                                    '${flightLoad?.jStaffAccepted ?? 0}'),
                                              ),
                                            ),
                                          ),
                                          Transform.translate(
                                            offset: Offset(-screenWidth * 0.016,
                                                1.0), //-11.50
                                            child: Container(
                                              height: screenHeigth * 0.035,
                                              width: screenWidth * 0.09,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Center(
                                                child: Text(
                                                    '${flightLoad?.yStaffAccepted ?? 0}'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeigth * 0.035),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton(
                                            onPressed: areButtonsEnabled
                                                ? () {
                                                    _navigateToMyPriorityPage(
                                                        context);
                                                  }
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromRGBO(
                                                      235, 97, 39, 1),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(9.0),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      screenWidth * 0.09),
                                            ),
                                            child: Text(
                                              'My Priority',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: screenWidth * 0.04),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: areButtonsEnabled
                                                ? () {
                                                    _navigateToPriorityPage(
                                                        context);
                                                  }
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(9.0),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      screenWidth * 0.03),
                                            ),
                                            child: Text(
                                              'Check-in Summary',
                                              style: TextStyle(
                                                  color: const Color.fromRGBO(
                                                      235, 97, 39, 1),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      screenWidth * 0.037),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeigth * 0.02),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
