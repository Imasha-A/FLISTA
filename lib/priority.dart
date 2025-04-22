import 'package:flista_new/models/staffaccess.dart';
import 'package:flista_new/mytickets.dart';
import 'package:flista_new/yaana.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/staffmodel.dart';
import 'home.dart';
import 'history.dart';
import 'main.dart';

class PriorityPage extends StatefulWidget {
  final String selectedDate;
  final String scheduledTime;
  final String selectedUL;
  final String originCountryCode;
  final String destinationCountryCode;
  final List<String> ulList;
  const PriorityPage({
    Key? key,
    required this.selectedDate,
    required this.selectedUL,
    required this.scheduledTime,
    required this.originCountryCode,
    required this.destinationCountryCode,
    required this.ulList,
  }) : super(key: key);

  @override
  _PriorityState createState() => _PriorityState();
}

class _PriorityState extends State<PriorityPage> {
  final APIService _apiService = APIService();
  late String selectedDate;
  late String selectedUL; // Initialize selectedUL
  late List<String> ulList;
  List<StaffMember> staffMembers = [];
  bool isLoading = true;
  int _selectedIndex = 0;
  late String _userName = 'User Name';
  late String _userId = '123456';

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate; // Initialize the selected date
    selectedUL =
        widget.selectedUL; // Initialize selectedUL with the passed value
    ulList = widget.ulList;
    fetchData();
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

  // Add this function to handle logout
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyLoginPage()),
    );
  }

   void fetchPermissions() async {
  List<FlistaPermission> permissions = await _apiService.getFlistaModulePermissions();
  for (var p in permissions) {
    print('Module: ${p.moduleId}, Staff: ${p.staffId}, Active: ${p.isActive}');
  }
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
        staffMembers = response;
        // Sort staffMembers by the 'priority' field in ascending order
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
          // Navigate to Home Page
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeigth = MediaQuery.of(context).size.height;
    _loadUserName();
    _loadUserId();
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
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            : Transform.translate(
                offset: Offset(screenWidth * 0.01, 0),
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
                              height: screenHeigth * 0.12,
                              width: screenWidth * 0.8,
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
                            const SizedBox(height: 5.0),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Transform.translate(
                                      offset: Offset(screenWidth * 0.25, 0.0),
                                      child: Text(
                                        'Staff Information',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: screenWidth * 0.05),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: screenHeigth * 0.01,
                                ),
                                // Display a message if there are no staff members
                                if (staffMembers.isEmpty)
                                  const Text(
                                    'No staff information available',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                    ),
                                  )
                                else
                                  Column(
                                    children: staffMembers.map((staff) {
                                      // Mask fields if the name doesn't match _userName
                                      String fullName =
                                          '${staff.firstName} ${staff.lastName}';

                                      if (fullName.toLowerCase() !=
                                              _userName.toLowerCase() &&
                                          staff.staffID != _userId) {
                                        // Mask sensitive fields
                                        staff = StaffMember(
                                          title: 'xxx',
                                          firstName:
                                              'xxxxxx', // Masked first name
                                          lastName:
                                              'xxxxxx', // Masked last name
                                          staffID: 'xxxxxx', // Masked staff ID
                                          priority: staff.priority,
                                          status: staff.status,
                                          pnr: staff.pnr,
                                          actionStatus: staff.actionStatus,
                                          uniqueCustomerID:
                                              staff.uniqueCustomerID,
                                          paxType: staff.paxType,
                                          prodIdentificationRefCode:
                                              staff.prodIdentificationRefCode,
                                          givenName: staff.givenName,
                                          prodIdentificationPrimeID:
                                              staff.prodIdentificationPrimeID,
                                          gender: staff.gender,
                                          Title: staff.title,
                                          surname: staff.surname,
                                        );
                                      }

                                      return Column(
                                        children: [
                                          SizedBox(
                                            width: screenWidth * 2,
                                            height: screenHeigth * 0.115,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                // Handle button press
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        48, 53, 106, 204),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          9.0),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        screenWidth * 0.045),
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
                                                              color:
                                                                  Colors.white,
                                                              fontSize:
                                                                  screenWidth *
                                                                      0.04),
                                                        ),
                                                        // Priority and Status row
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                'Priority - ${staff.priority}',
                                                                style:
                                                                    TextStyle(
                                                                  color: const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      255,
                                                                      251,
                                                                      21),
                                                                  fontSize:
                                                                      screenWidth *
                                                                          0.04,
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                              'Status - ${staff.actionStatus}',
                                                              style: TextStyle(
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    255,
                                                                    110,
                                                                    26),
                                                                fontSize:
                                                                    screenWidth *
                                                                        0.04,
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
                                          SizedBox(
                                              height: screenHeigth * 0.015),
                                        ],
                                      );
                                    }).toList(),
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
                            HistoryPage(),
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
