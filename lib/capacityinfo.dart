import 'package:flista_new/models/staffmodel.dart';
import 'package:flista_new/mytickets.dart';
import 'package:flista_new/yaana.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'priority.dart';
import '../services/api_service.dart';
import '../models/flightloadmodel.dart';
import 'dart:core';
import './history.dart';
import 'home.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

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
  bool areButtonsEnabled = false;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

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

    _initializeState();
  }

  Future<void> _initializeState() async {
    await _loadUserName();
    await _loadUserId();
    await fetchData();

    // Check if any staff member matches the condition
    for (var staff in staffMembers) {
      String fullName = '${staff.firstName} ${staff.lastName}';

      if (fullName == _userName || staff.staffID == _userId) {
        setState(() {
          areButtonsEnabled = true; // Enable buttons for matching staff
        });

        print(fullName);
        print(_userName);
        print(staff.staffID);
        print(_userName);

        break; // Exit the loop early if condition is met
      }
    }
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? displayName = prefs.getString('displayName');
    setState(() {
      _userName = displayName ?? 'User Name';
    });
  }

  // Callback for pull-down refresh
  Future<void> _onRefresh() async {
    _fetchFlightLoadInfo();
    await _initializeState();
    _refreshController.refreshCompleted();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    setState(() {
      _userId = userId ?? '123456';
    });
  }

  Future<void> fetchData() async {
    try {
      var response = await _apiService.viewStaffMembers(
        selectedDate,
        widget.originCountryCode,
        selectedUL,
      );

      // Only update state if the widget is still mounted
      if (mounted) {
        setState(() {
          staffMembers = response; // Update the list of staff members
          isLoading = false;
        });

        // Check if any staff member matches the condition
        for (var staff in staffMembers) {
          String fullName = '${staff.firstName} ${staff.lastName}';

          if (fullName == _userName ||
              staff.staffID == _userId ||
              _userId == 'IN1913' ||
              _userId == 'IN1927' ||
              _userId == '23799' ||
              _userId == '23933' ||
              _userId == '16763' ||
              _userId == '12988') {
            setState(() {
              areButtonsEnabled = true; // Enable buttons for matching staff
            });

            print(fullName);
            print(_userName);
            print(staff.staffID);
            print(_userId);

            break; // Exit the loop early if condition is met
          }
        }
      }
    } catch (error) {
      // Only update state if the widget is still mounted
      if (mounted) {
        setState(() {
          staffMembers = [];
          isLoading = false;
        });
      }
      print('Error fetching data: $error');
    }
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

  BottomNavigationBarItem _buildCustomBottomNavigationBarItem(
      String iconPath, String label, bool isHighlighted) {
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
                  child: Image.asset(
                    iconPath,
                    height: 28, // Adjust size if needed
                    width: 28,
                    fit: BoxFit.contain,
                    color: const Color.fromRGBO(2, 77, 117, 1), // Optional tint
                  ),
                )
              : Image.asset(
                  iconPath,
                  height: 30,
                  width: 30,
                  fit: BoxFit.contain,
                ),
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

      // Fetch flight load information for the updated date
      _fetchFlightLoadInfo();
      areButtonsEnabled = false;
      _initializeState();
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

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/homebgnew.png"), // Change to your image
          fit: BoxFit.fitWidth,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(screenHeigth * 0.173),
          child: AppBar(
            backgroundColor: Colors.transparent,
            titleTextStyle: TextStyle(
                fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
            leading: Transform.translate(
              offset: const Offset(0, 0),
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
                          height: screenHeigth * 0.08,
                        ),
                        SizedBox(
                          height: screenHeigth * 0.04, // Parent height
                          width: screenWidth * 0.72, // Parent width
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // The line image (background) with reduced size
                              SizedBox(
                                height: screenHeigth *
                                    0.013, // Reduced height for the line image
                                width: screenWidth *
                                    0.72, // You can adjust this width if needed
                                child: const Image(
                                  image: AssetImage(
                                      'assets/airplane-route-line.png'),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              // The plane image (animated) with reduced size

                              SizedBox(
                                height: screenHeigth *
                                    0.07, // Smaller height for the plane image
                                width: screenWidth *
                                    0.3, // Adjust the width as needed
                                child: const Image(
                                  image: AssetImage(
                                      'assets/airplane-route-plane.png'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: screenHeigth * 0.03,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Transform.translate(
                                offset: Offset(-screenWidth * 0.086,
                                    -screenHeigth * 0.035),
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
            : SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                enablePullUp: false,
                onRefresh: _onRefresh,
                child: Transform.translate(
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
                              height: screenHeigth * 0.62,
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
                                      offset: Offset(screenWidth * 0.05,
                                          screenHeigth * 0.002),
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
                                      SizedBox(height: screenHeigth * 0.03),
                                      SizedBox(
                                        height: screenHeigth * 0.106,
                                        width: screenWidth * .8,
                                        child: Transform.translate(
                                          offset: const Offset(0.4, -15.0),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              // Handle checking availability
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color.fromARGB(
                                                  75, 53, 87, 151),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              // padding: EdgeInsets.symmetric(
                                              //   horizontal: screenWidth * 0.05,
                                              //   vertical: screenHeigth * 0.018, // Further reduced vertical padding
                                              // ),
                                              padding: EdgeInsets.zero,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize
                                                  .min, // Avoid extra space
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                // UL Number (Shifted closer)
                                                Transform.translate(
                                                  offset: Offset(0, 11),
                                                  child: Text(
                                                    'UL $selectedUL',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          screenWidth * 0.06,
                                                      height:
                                                          1.0, // Remove extra spacing
                                                    ),
                                                  ),
                                                ),

                                                // Row for Arrows and Date
                                                Transform.translate(
                                                  offset: Offset(0,
                                                      -2), // Moves Date row upwards
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize
                                                        .min, // Avoid extra space
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      // Left Arrow (Move to Previous Date)
                                                      GestureDetector(
                                                        onTap: () {
                                                          _changeUL(false);
                                                        },
                                                        child: Container(
                                                          width: screenWidth *
                                                              0.12, // Increased tap area
                                                          height: screenHeigth *
                                                              0.06,
                                                          alignment:
                                                              Alignment.center,
                                                          child: Icon(
                                                            Icons
                                                                .arrow_back_ios_rounded,
                                                            color: Colors.white,
                                                            size: screenWidth *
                                                                0.075, // Increased icon size
                                                          ),
                                                        ),
                                                      ),

                                                      SizedBox(
                                                          width: screenWidth *
                                                              0.09), // Increased spacing

                                                      // Selected Date (Reduced padding)
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    screenWidth *
                                                                        0.01), // Reduced horizontal padding
                                                        child: Text(
                                                          '$selectedDate',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize:
                                                                screenWidth *
                                                                    .04,
                                                            height:
                                                                1.0, // Remove extra spacing
                                                          ),
                                                        ),
                                                      ),

                                                      SizedBox(
                                                          width: screenWidth *
                                                              0.09), // Increased spacing

                                                      // Right Arrow (Move to Next Date)
                                                      GestureDetector(
                                                        onTap: () {
                                                          _changeUL(true);
                                                        },
                                                        child: Container(
                                                          width: screenWidth *
                                                              0.12, // Increased tap area
                                                          height: screenHeigth *
                                                              0.06,
                                                          alignment:
                                                              Alignment.center,
                                                          child: Icon(
                                                            Icons
                                                                .arrow_forward_ios_rounded,
                                                            color: Colors.white,
                                                            size: screenWidth *
                                                                0.075, // Increased icon size
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // Scheduled Time (Shifted closer)
                                                Transform.translate(
                                                  offset: Offset(0,
                                                      -12), // Moves scheduled time upwards
                                                  child: Text(
                                                    '${widget.scheduledTime.substring(0, 2)}:${widget.scheduledTime.substring(2)}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          screenWidth * .04,
                                                      height: screenWidth *
                                                          0.002, // Remove extra spacing
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                                width: screenWidth * 0.1,
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
                                                width: screenWidth * 0.043,
                                              ),
                                            ],
                                          ),

                                          // Capacity information content
                                          Row(
                                            children: [
                                              Text('Capacity',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          screenWidth * 0.041)),
                                              SizedBox(
                                                width: screenWidth * 0.27,
                                              ),
                                              Transform.translate(
                                                offset: Offset(
                                                    screenWidth * 0.13,
                                                    -0.5), //100.5
                                                child: Container(
                                                  height: screenHeigth * 0.035,
                                                  width: screenWidth * 0.12,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                        '${flightLoad?.jCapacity}',
                                                        style: TextStyle(
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 0, 0, 0),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                screenWidth *
                                                                    0.041)),
                                                  ),
                                                ),
                                              ),
                                              Transform.translate(
                                                offset: Offset(
                                                    screenWidth * 0.165,
                                                    -0.5), //-12.55
                                                child: Container(
                                                  height: screenHeigth * 0.035,
                                                  width: screenWidth * 0.12,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Center(
                                                    child: Text(
                                                        '${flightLoad?.yCapacity}',
                                                        style: TextStyle(
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 0, 0, 0),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                screenWidth *
                                                                    0.041)),
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
                                              Text('Booked',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          screenWidth * 0.041)),
                                              SizedBox(
                                                width: screenWidth * 0.23,
                                              ),
                                              Transform.translate(
                                                offset: Offset(
                                                    screenWidth * 0.037,
                                                    1.0), //87.0
                                                child: Container(
                                                  height: screenHeigth * 0.035,
                                                  width: screenWidth * 0.12,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Center(
                                                    child: Text(
                                                        '${flightLoad?.jBooked}',
                                                        style: TextStyle(
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 0, 0, 0),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                screenWidth *
                                                                    0.041)),
                                                  ),
                                                ),
                                              ),
                                              Transform.translate(
                                                offset: Offset(
                                                    -screenWidth * 0.01,
                                                    1.0), //-11.55
                                                child: Container(
                                                  height: screenHeigth * 0.035,
                                                  width: screenWidth * 0.12,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Center(
                                                    child: Text(
                                                        '${flightLoad?.yBooked}',
                                                        style: TextStyle(
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 0, 0, 0),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                screenWidth *
                                                                    0.041)),
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
                                              Text('Checked-In',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          screenWidth * 0.041)),
                                              SizedBox(
                                                width: screenWidth * 0.23,
                                              ),
                                              Transform.translate(
                                                offset: Offset(
                                                    screenWidth * 0.014,
                                                    1.0), //52.0
                                                child: Container(
                                                  height: screenHeigth * 0.035,
                                                  width: screenWidth * 0.12,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Center(
                                                    child: Text(
                                                        '${flightLoad?.jCheckedIn}',
                                                        style: TextStyle(
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 0, 0, 0),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                screenWidth *
                                                                    0.041)),
                                                  ),
                                                ),
                                              ),
                                              Transform.translate(
                                                offset: Offset(
                                                    -screenWidth * 0.01,
                                                    1.0), //-11.55
                                                child: Container(
                                                  height: screenHeigth * 0.035,
                                                  width: screenWidth * 0.12,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Center(
                                                    child: Text(
                                                        '${flightLoad?.yCheckedIn}',
                                                        style: TextStyle(
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 0, 0, 0),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                screenWidth *
                                                                    0.041)),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          screenWidth * 0.041)),
                                              Transform.translate(
                                                offset: Offset(
                                                    screenWidth * 0.07,
                                                    1.0), //87.0
                                                child: Container(
                                                  height: screenHeigth * 0.035,
                                                  width: screenWidth * 0.12,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Center(
                                                    child: Text(
                                                        '${flightLoad?.jCommercialStandby}',
                                                        style: TextStyle(
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 0, 0, 0),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                screenWidth *
                                                                    0.041)),
                                                  ),
                                                ),
                                              ),
                                              Transform.translate(
                                                offset: Offset(
                                                    -screenWidth * 0.008,
                                                    1.0), //-11.50
                                                child: Container(
                                                  height: screenHeigth * 0.035,
                                                  width: screenWidth * 0.12,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Center(
                                                    child: Text(
                                                        '${flightLoad?.yCommercialStandby}',
                                                        style: TextStyle(
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 0, 0, 0),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                screenWidth *
                                                                    0.041)),
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
                                              Text('Staff Listed',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          screenWidth * 0.041)),
                                              Transform.translate(
                                                offset: Offset(
                                                    screenWidth * 0.157,
                                                    1.0), //65.0
                                                child: Container(
                                                  height: screenHeigth * 0.035,
                                                  width: screenWidth * 0.12,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Center(
                                                    child: Text(
                                                        '${flightLoad?.jStaffListed ?? 0}',
                                                        style: TextStyle(
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 0, 0, 0),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                screenWidth *
                                                                    0.041)),
                                                  ),
                                                ),
                                              ),
                                              Transform.translate(
                                                offset: Offset(
                                                    -screenWidth * 0.009,
                                                    1.0), //-11.50
                                                child: Container(
                                                  height: screenHeigth * 0.035,
                                                  width: screenWidth * 0.12,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Center(
                                                    child: Text(
                                                        '${flightLoad?.yStaffListed ?? 0}',
                                                        style: TextStyle(
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 0, 0, 0),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                screenWidth *
                                                                    0.041)),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          screenWidth * 0.041)),
                                              Transform.translate(
                                                offset: Offset(
                                                    screenWidth * 0.11,
                                                    1.0), //31.0
                                                child: Container(
                                                  height: screenHeigth * 0.035,
                                                  width: screenWidth * 0.12,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                        '${flightLoad?.jStaffOnStandby ?? 0}',
                                                        style: TextStyle(
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 0, 0, 0),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                screenWidth *
                                                                    0.041)),
                                                  ),
                                                ),
                                              ),
                                              Transform.translate(
                                                offset: Offset(
                                                    -screenWidth * 0.01,
                                                    1.0), //-11.50
                                                child: Container(
                                                  height: screenHeigth * 0.035,
                                                  width: screenWidth * 0.12,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Center(
                                                    child: Text(
                                                        '${flightLoad?.yStaffOnStandby ?? 0}',
                                                        style: TextStyle(
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 0, 0, 0),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                screenWidth *
                                                                    0.041)),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          screenWidth * 0.041)),
                                              Transform.translate(
                                                offset: Offset(
                                                    screenWidth * 0.128,
                                                    1.0), //31.0
                                                child: Container(
                                                  height: screenHeigth * 0.035,
                                                  width: screenWidth * 0.12,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Center(
                                                    child: Text(
                                                        '${flightLoad?.jStaffAccepted ?? 0}',
                                                        style: TextStyle(
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 0, 0, 0),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                screenWidth *
                                                                    0.041)),
                                                  ),
                                                ),
                                              ),
                                              Transform.translate(
                                                offset: Offset(
                                                    -screenWidth * 0.008,
                                                    1.0), //-11.50
                                                child: Container(
                                                  height: screenHeigth * 0.035,
                                                  width: screenWidth * 0.12,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Center(
                                                    child: Text(
                                                        '${flightLoad?.yStaffAccepted ?? 0}',
                                                        style: TextStyle(
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 0, 0, 0),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                screenWidth *
                                                                    0.041)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                              height: screenHeigth * 0.047),

                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // ElevatedButton(
                                              //   onPressed: areButtonsEnabled
                                              //       ? () {
                                              //           _navigateToMyPriorityPage(
                                              //               context);
                                              //         }
                                              //       : null,
                                              //   style: ElevatedButton.styleFrom(
                                              //     backgroundColor: areButtonsEnabled
                                              //         ? const Color.fromRGBO(
                                              //             235,
                                              //             97,
                                              //             39,
                                              //             1) // Normal color when enabled
                                              //         : Colors
                                              //             .grey, // Color when disabled
                                              //     shape: RoundedRectangleBorder(
                                              //       borderRadius:
                                              //           BorderRadius.circular(9.0),
                                              //     ),
                                              //     disabledForegroundColor:
                                              //         Colors.grey.withOpacity(0.38),
                                              //     disabledBackgroundColor:
                                              //         const Color.fromARGB(
                                              //             169, 235, 98, 39),
                                              //     padding: EdgeInsets.symmetric(
                                              //         horizontal: screenWidth *
                                              //             0.09), // Ensures background color is grey when disabled
                                              //   ),
                                              //   child: Text(
                                              //     'My Priority(old)',
                                              //     style: TextStyle(
                                              //       color: areButtonsEnabled
                                              //           ? Colors.white
                                              //           : const Color.fromARGB(
                                              //               189,
                                              //               255,
                                              //               255,
                                              //               255), // Text color for enabled/disabled
                                              //       fontWeight: FontWeight.bold,
                                              //       fontSize: screenWidth * 0.04,
                                              //     ),
                                              //   ),
                                              // ),
                                              Container(
                                                width: screenWidth * 0.8,
                                                height: screenHeigth * 0.045,
                                                child: ElevatedButton(
                                                  onPressed: areButtonsEnabled
                                                      ? () {
                                                          _navigateToPriorityPage(
                                                              context);
                                                        }
                                                      : null,
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        areButtonsEnabled
                                                            ? Colors
                                                                .white // Normal color when enabled
                                                            : Colors
                                                                .grey, // Color when disabled
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              9.0),
                                                    ),
                                                    disabledForegroundColor:
                                                        const Color.fromARGB(
                                                                255,
                                                                255,
                                                                255,
                                                                255)
                                                            .withOpacity(0.38),
                                                    disabledBackgroundColor:
                                                        const Color.fromARGB(
                                                                255,
                                                                242,
                                                                236,
                                                                236)
                                                            .withOpacity(0.12),

                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: screenWidth *
                                                            0.03), // Ensures background color is grey when disabled
                                                  ),
                                                  child: Text(
                                                    'My Priority',
                                                    style: TextStyle(
                                                      color: areButtonsEnabled
                                                          ? const Color
                                                              .fromRGBO(
                                                              235,
                                                              97,
                                                              39,
                                                              1) // Normal color for text when enabled
                                                          : const Color
                                                              .fromARGB(
                                                              194,
                                                              235,
                                                              98,
                                                              39), // Color when disabled
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize:
                                                          screenWidth * 0.04,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
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
              type: BottomNavigationBarType.fixed,
              backgroundColor: Color.fromRGBO(2, 77, 117, 1),
              elevation: 1,
              currentIndex: 1,
              selectedItemColor: const Color.fromARGB(255, 234, 248, 249),
              unselectedItemColor: Colors.white,
              onTap: (index) async {
                switch (index) {
                  case 0: // History
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const HistoryPage(),
                        transitionDuration:
                            Duration(seconds: 0), // No animation
                      ),
                    );
                    break;
                  case 1: // Home
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            HomePage(selectedDate: selectedDate),
                        transitionDuration:
                            Duration(seconds: 0), // No animation
                      ),
                    );
                    break;

                  case 2: // My Tickets
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const MyTickets(),
                        transitionDuration:
                            Duration(seconds: 0), // No animation
                      ),
                    );
                    break;
                  case 3: // Yaaana

                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            Yaana(),
                        transitionDuration:
                            const Duration(seconds: 0), // No animation
                      ),
                    );
                    break;
                }
              },
              items: [
                _buildCustomBottomNavigationBarItem(
                    'assets/history.png', 'History', false),
                _buildCustomBottomNavigationBarItem(
                    'assets/home.png', 'Home', false),
                _buildCustomBottomNavigationBarItem(
                    'assets/ticket.png', 'My Tickets', false),
                _buildCustomBottomNavigationBarItem(
                    'assets/chatbot.png', 'Yaana', false),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
