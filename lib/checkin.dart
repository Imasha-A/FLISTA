import 'package:flista_new/models/checkinmodel.dart';
import 'package:flista_new/models/staffaccess.dart';
import 'package:flista_new/models/staffmodel.dart';
import 'package:flista_new/mytickets.dart';
import 'package:flista_new/yaana.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'priority.dart';
import '../services/api_service.dart';
import '../models/flightloadmodel.dart';
import 'dart:core';
import './history.dart';
import 'home.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

class CheckInPage extends StatefulWidget {
  final String selectedDate;
  final String selectedUL;
  final String scheduledTime;
  final String originCountryCode;
  final String destinationCountryCode;
  final Function(String) onULSelected;

  const CheckInPage({
    Key? key,
    required this.selectedDate,
    required this.selectedUL,
    required this.scheduledTime,
    required this.originCountryCode,
    required this.destinationCountryCode,
    required this.onULSelected,
  }) : super(key: key);

  @override
  _CheckInState createState() => _CheckInState();
}

class _CheckInState extends State<CheckInPage> {
  late String selectedDate;
  late String selectedUL; 
  late List<String> ulList; 
  FlightLoadModel? flightLoad;
  CheckinSummery? checkinSummery;
  late String formattedDate; 
  late String formattedLongDate;
  bool isLoading = true;
  List<StaffMember> staffMembers = [];
  final APIService _apiService = APIService();
  late String _userName = 'User Name';
  late String _userId = '123456';

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
    selectedUL =
        widget.selectedUL; 
    formattedDate =
        APIService().formatDate(selectedDate); 
    formattedLongDate = APIService()
        .formatLongDate(selectedDate);
    _fetchFlightLoadInfo();

    _initializeState();

    _fetchFlightExtraInfo();
  }

  Future<void> _initializeState() async {
    await _loadUserName();
    await _loadUserId();
    await fetchData();

  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? displayName = prefs.getString('displayName');
    setState(() {
      _userName = displayName ?? 'User Name';
    });
  }

Widget _buildDataRow(String label, dynamic jValue, dynamic yValue, double screenWidth, double screenHeigth) {
  return Row(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: Container(
          width: screenWidth * 0.5,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.041,
            ),
          ),
        ),
      ),
      
      // BC/J value
      Expanded(
        child: Center(
          child: Container(
            height: screenHeigth * 0.035,
            width: screenWidth * 0.12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$jValue',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.041,
                ),
              ),
            ),
          ),
        ),
      ),
      
      // EY/Y value
      Expanded(
        child: Center(
          child: Container(
            height: screenHeigth * 0.035,
            width: screenWidth * 0.12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$yValue',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.041,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
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
     
      if (mounted) {
        setState(() {
          staffMembers = response; 
          isLoading = false;
        });

       
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          staffMembers = [];
          isLoading = false;
        });
      }
      print('Error fetching data: $error');
    }
  }

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

      print (    formattedDate
      );

       print (   
      widget.originCountryCode,
     );

       print (    
      widget.selectedUL,
 );

       print (    
      _userId);
      List<FlightLoadModel> flightLoadDataList =
          await APIService().fetchFlightLoadInfo(
        widget.selectedDate,
        formattedDate, 
        formattedLongDate, 
        widget.originCountryCode,
        widget.destinationCountryCode,
        widget.selectedUL,
        _userId,
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
        isLoading = false; 
      });
    }
  }


 void _fetchFlightExtraInfo() async {
  await _loadUserId();
  await fetchData();

  try {
    DateTime flightDate = DateTime.now(); 
    String formattedDate = DateFormat('yyyyMMdd').format(flightDate);

    var responseList = await _apiService.viewCheckInStatus(
      formattedDate,
      widget.originCountryCode,
      widget.selectedUL,
      _userId,
    );

   List<CheckinSummery> summaryList = responseList;

    setState(() {
      if (summaryList.isNotEmpty) {
        checkinSummery = summaryList.first;
      }
      isLoading = false;
    });
  } catch (error) {
    print('Error fetching flight load information: $error');
    setState(() {
      isLoading = false;
    });
  }
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
                    height: 28, 
                    width: 28,
                    fit: BoxFit.contain,
                    color: const Color.fromRGBO(2, 77, 117, 1), 
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
      isLoading = true; 

      if (next) {
        selectedDate = _getNextDate(selectedDate);
      } else {
        selectedDate = _getPreviousDate(selectedDate);
      }

      formattedDate = APIService().formatDate(selectedDate);
      formattedLongDate = APIService().formatLongDate(selectedDate);

      _fetchFlightLoadInfo();
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
                          height: screenHeigth * 0.04, 
                          width: screenWidth * 0.72, 
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                            
                              SizedBox(
                                height: screenHeigth *
                                    0.013, 
                                width: screenWidth *
                                    0.72, 
                                child: const Image(
                                  image: AssetImage(
                                      'assets/airplane-route-line.png'),
                                  fit: BoxFit.fill,
                                ),
                              ),

                              SizedBox(
                                height: screenHeigth *
                                    0.07, 
                                width: screenWidth *
                                    0.3, 
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
                                      .trim(), 
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
                                      .trim(), 
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
                              height: screenHeigth * 0.68,
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

                                  Column(
  children: [
    SizedBox(height: screenHeigth * 0.02),
                            SizedBox(
                              height: screenHeigth * 0.12,
                              width: screenWidth * 0.8,
                              child: Transform.translate(
                                offset: const Offset(0.4, -15.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(158, 38, 64, 112),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9.0),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            '         UL $selectedUL',
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
                                        '$selectedDate', // Use selectedDate variable here
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: screenWidth * .04,
                                        ),
                                      ),
                                      SizedBox(height: screenHeigth * 0.002),
                                      Text(
                                        '${widget.scheduledTime.substring(0, 2)}:${widget.scheduledTime.substring(2)}',
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
                                      Column(
  children: [
    Row(
      children: [
        SizedBox(width: screenWidth * 0.53),
        Expanded(
          child: Center(
            child: Text(
              'BC', 
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.041,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              'EY', 
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.041,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
    SizedBox(height: screenHeigth * 0.015),
    
    // Data rows
    _buildDataRow('Capacity', checkinSummery?.jCapacity?? 0, checkinSummery?.yCapacity ?? 0, screenWidth, screenHeigth),
    SizedBox(height: screenHeigth * 0.01),
    
    _buildDataRow('Booked', checkinSummery?.jBooked?? 0, checkinSummery?.yBooked?? 0, screenWidth, screenHeigth),
    SizedBox(height: screenHeigth * 0.01),
    
    _buildDataRow('Checked-In', checkinSummery?.jCheckedIn?? 0, checkinSummery?.yCheckedIn?? 0, screenWidth, screenHeigth),
    SizedBox(height: screenHeigth * 0.01),

     _buildDataRow('Infants Accepted', checkinSummery?.jInfantsAccepted?? 0, checkinSummery?.yInfantsAccepted?? 0, screenWidth, screenHeigth),
     SizedBox(height: screenHeigth * 0.01),
    
    _buildDataRow('Commercial Standby', checkinSummery?.jCommercialStandby ?? 0, checkinSummery?.yCommercialStandby?? 0, screenWidth, screenHeigth),
    SizedBox(height: screenHeigth * 0.01),
    
    _buildDataRow('Staff Listed', checkinSummery?.jStaffListed ?? 0, checkinSummery?.yStaffListed ?? 0, screenWidth, screenHeigth),
    SizedBox(height: screenHeigth * 0.01),
    
    _buildDataRow('Staff on Standby', checkinSummery?.jStaffOnStandby ?? 0, checkinSummery?.yStaffOnStandby ?? 0, screenWidth, screenHeigth),
    SizedBox(height: screenHeigth * 0.01),
    
    _buildDataRow('Staff Accepted', checkinSummery?.jStaffAccepted ?? 0, checkinSummery?.yStaffAccepted ?? 0, screenWidth, screenHeigth),
    SizedBox(height: screenHeigth * 0.01),
    
     _buildDataRow('Bookable Staff Accepted', checkinSummery?.jBookableStaffAccepted ?? 0, checkinSummery?.yBookableStaffAccepted ?? 0, screenWidth, screenHeigth),
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
                            Duration(seconds: 0), 
                      ),
                    );
                    break;
                  case 3: 

                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            Yaana(),
                        transitionDuration:
                            const Duration(seconds: 0), 
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
                    'assets/chatboticon.png', 'Yaana', false),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
