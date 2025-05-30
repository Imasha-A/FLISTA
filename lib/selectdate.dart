import 'package:flista_new/home.dart';
import 'package:flista_new/models/staffaccess.dart';
import 'package:flista_new/models/staffmodel.dart';
import 'package:flista_new/mytickets.dart';
import 'package:flista_new/services/api_service.dart';
import 'package:flista_new/yaana.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'availableflights.dart';
import './history.dart';
import 'main.dart';

class SelectDatePage extends StatefulWidget {
  final String selectedDate;
  final String originCountryCode; // Added parameter
  final String destinationCountryCode; // Added parameter
  const SelectDatePage({
    Key? key,
    required this.selectedDate,
    required this.originCountryCode,
    required this.destinationCountryCode,
  }) : super(key: key);

  @override
  _SelectDatePageState createState() => _SelectDatePageState();
}

class _SelectDatePageState extends State<SelectDatePage> {
  late String selectedDate;
  bool _animate = false;
  final APIService _apiService = APIService();
  late String _userName = 'User Name';
  late String _userId = '123456';  List<String> datePickerAccess=[];
  List<StaffMember> staffMembers = [];
  bool _isLoading = true;

 @override
void initState() {
  super.initState();
  selectedDate = widget.selectedDate;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    setState(() {
      _animate = true;
    });
  });
  _initializePermissionsAndUser();
}


  String _originCountry = '      CMB';
  String _destinationCountry = '       BKK';
    double _sliderDays = 0;
  DateTime newdate = DateTime.now();

 Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //String? displayName = prefs.getString('displayName');
    setState(() {
      //_userName = displayName ?? 'User Name';
      _userName = prefs.getString('displayName') ?? 'User Name'; // Null check
    });
  }

  Future<void> _initializePermissionsAndUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  _userId = prefs.getString('userId') ?? '123456';
  _userName = prefs.getString('displayName') ?? 'User Name';

  List<FlistaPermission> permissions = await _apiService.getFlistaModulePermissions();
  datePickerAccess = permissions
      .where((p) => p.moduleId == 'NO_RESTRICTIONS_FOR_DATE_SEARCH' && p.isActive == "TRUE")
      .map((p) => p.staffId)
      .toList();

  print('Date Picker Access: $datePickerAccess');
  setState(() {
    _isLoading = false;
  });
}


  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //String? userId = prefs.getString('userId');
    setState(() {
      //_userId = userId ?? '123456';
       _userId = prefs.getString('userId') ?? '123456'; // Null check
    });
  }
  void _swapCountries() {
    setState(() {
      final String temp = _originCountry;
      _originCountry = _destinationCountry;
      _destinationCountry = temp;
    });
  }

  void fetchdDatePickerPermission() async {
    List<FlistaPermission> permissions = await _apiService.getFlistaModulePermissions();

    datePickerAccess = permissions
      .where((p) => p.moduleId == 'NO_RESTRICTIONS_FOR_DATE_SEARCH'&& p.isActive=="TRUE")
      .map((p) => p.staffId)
      .toList();

      print('Date Picker Access: $datePickerAccess');
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyLoginPage()),
    );
  }

  void _navigateToAvailableFlightsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AvailableFlightsPage(
          selectedDate: selectedDate,
          originCountryCode: widget.originCountryCode, 
          destinationCountryCode:
              widget.destinationCountryCode, 
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
    return Scaffold(
      backgroundColor: Color.fromARGB(0, 255, 255, 255),
      body: Center(child: CircularProgressIndicator()),
    );
  }
    double screenWidth = MediaQuery.of(context).size.width;

    double screenHeight = MediaQuery.of(context).size.height;

    // Calculate today, tomorrow, and the day after tomorrow dates
    DateTime now = DateTime.now();
    DateTime tomorrow = now.add(const Duration(days: 1));
    DateTime dayAfterTomorrow = now.add(const Duration(days: 2));
    DateTime dayAfterDayAfterTomorrow = now.add(const Duration(days: 3));

    // Format the dates
    String formattedToday =
        '${now.day} ${_getMonthName(now.month)} ${now.year}';
    String formattedTomorrow =
        '${tomorrow.day} ${_getMonthName(tomorrow.month)} ${tomorrow.year}';
    String formattedDayAfterTomorrow =
        '${dayAfterTomorrow.day} ${_getMonthName(dayAfterTomorrow.month)} ${dayAfterTomorrow.year}';
    String formattedDayAfterDayAfterTomorrow =
        '${dayAfterDayAfterTomorrow.day} ${_getMonthName(dayAfterDayAfterTomorrow.month)} ${dayAfterDayAfterTomorrow.year}';

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
          preferredSize: Size.fromHeight(screenHeight * 0.173),
          child: AppBar(
            backgroundColor: Colors.transparent,
            titleTextStyle: TextStyle(
                fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
            leading: Transform.translate(
              offset: const Offset(0, 0),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          HomePage(selectedDate: selectedDate),
                      transitionDuration: Duration(seconds: 0), // No animation
                    ),
                  );
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
                        SizedBox(height: screenHeight * 0.08),
                        SizedBox(
                          height: screenHeight * 0.04, // Parent height
                          width: screenWidth * 0.72, // Parent width
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                             
                              SizedBox(
                                height: screenHeight *
                                    0.013, 
                                width: screenWidth *
                                    0.72, 
                                child: const Image(
                                  image: AssetImage(
                                      'assets/airplane-route-line.png'),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              // The plane image (animated) with reduced size
                              AnimatedAlign(
                                alignment: _animate
                                    ? Alignment.center
                                    : Alignment.centerLeft,
                                duration: const Duration(seconds: 3),
                                curve: Curves.easeInOut,
                                child: SizedBox(
                                  height: screenHeight *
                                      0.07, // Smaller height for the plane image
                                  width: screenWidth *
                                      0.14, // Adjust the width as needed
                                  child: const Image(
                                    image: AssetImage(
                                        'assets/airplane-route-plane.png'),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.03,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Transform.translate(
                                offset: Offset(-screenWidth * 0.086,
                                    -screenHeight * 0.035),
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
                                    screenWidth * 0.08, -screenHeight * 0.035),
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
        body: SizedBox(
          height: screenHeight * 0.9,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.02),
                Transform.translate(
                  offset: Offset(screenWidth * -0.001, 0.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.all(16.0),
                    height: screenHeight * ((datePickerAccess.contains(_userId))? 0.75 : 0.5),
                    width: screenWidth * 1,
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
                    child: SingleChildScrollView(
                      // Add scrolling
                      child: Column(
                        children: [
                          Transform.translate(
                            offset: const Offset(0.0, -3.0),
                            child: Text(
                              'Select a Date',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.055,
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Center(
                            child: SizedBox(
                              width:
                                  screenWidth * 0.8, // Customize the width here
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedDate = formattedToday;
                                  });
                                  _navigateToAvailableFlightsPage(
                                      context); // Handle checking availability
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(235, 97, 39, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.015),
                                  elevation: screenWidth * 0.015,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        'Today',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: screenWidth * 0.055,
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        formattedToday,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: screenWidth * 0.044,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        _getDayOfWeek(now.weekday),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedDate = formattedTomorrow;
                                  });
                                  _navigateToAvailableFlightsPage(
                                      context); // Handle checking availability
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  shadowColor:
                                      const Color.fromARGB(255, 33, 144, 213),
                                  side: const BorderSide(
                                      width: 1.5,
                                      color: Color.fromARGB(0, 255, 255, 255)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.082,
                                      vertical: screenHeight * 0.017),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Tomorrow',
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 4, 88, 141),
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth * 0.045,
                                      ),
                                    ),
                                    Text(
                                      formattedTomorrow,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 4, 88, 141),
                                        fontSize: screenWidth * 0.034,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _getDayOfWeek(tomorrow.weekday),
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 4, 88, 141),
                                        fontSize: screenWidth * 0.036,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedDate = formattedDayAfterTomorrow;
                                  });
                                  _navigateToAvailableFlightsPage(
                                      context); // Handle checking availability
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  shadowColor:
                                      const Color.fromARGB(255, 33, 144, 213),
                                  side: const BorderSide(
                                      width: 1.5,
                                      color: Color.fromARGB(0, 255, 255, 255)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.08,
                                      vertical: screenHeight * 0.017),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Day After',
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 4, 88, 141),
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth * 0.045,
                                      ),
                                    ),
                                    Text(
                                      formattedDayAfterTomorrow,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 4, 88, 141),
                                        fontSize: screenWidth * 0.034,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _getDayOfWeek(dayAfterTomorrow.weekday),
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 4, 88, 141),
                                        fontSize: screenWidth * 0.036,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedDate =
                                    formattedDayAfterDayAfterTomorrow;
                              });
                              _navigateToAvailableFlightsPage(
                                  context); // Handle checking availability
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              shadowColor:
                                  const Color.fromARGB(255, 33, 144, 213),
                              side: const BorderSide(
                                  width: 1,
                                  color: Color.fromARGB(0, 255, 255, 255)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.235,
                                  vertical: screenHeight * 0.013),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'The Next Day',
                                  style: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 4, 88, 141),
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.045,
                                  ),
                                ),
                                Text(
                                  formattedDayAfterDayAfterTomorrow,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 4, 88, 141),
                                    fontSize: screenWidth * 0.036,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _getDayOfWeek(
                                      dayAfterDayAfterTomorrow.weekday),
                                  style: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 4, 88, 141),
                                    fontWeight: FontWeight.w400,
                                    fontSize: screenWidth * 0.038,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
          SizedBox(height: screenHeight * 0.01),

 if (datePickerAccess.contains(_userId))

 
  Padding(
  padding: EdgeInsets.symmetric(
    horizontal: screenWidth * 0.02,
    vertical: screenHeight * 0.01,
  ),
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(screenWidth * 0.04),
    ),
    padding: EdgeInsets.all(screenWidth * 0.04),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // the label — we’ll rebuild this when newdate changes
        Text(
          'Selected date: ${newdate.day} ${_getMonthName(newdate.month)} ${newdate.year}',
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w700,
            color: const Color.fromARGB(255, 4, 88, 141),
          ),
        ),
        SizedBox(height: screenHeight * 0.01),

        // the date picker
        SizedBox(
          width: screenWidth * 1.7,
          height: screenHeight * 0.1,
          child: CupertinoTheme(
            data: CupertinoTheme.of(context).copyWith(
              primaryColor: const Color.fromARGB(255, 4, 88, 141),
              textTheme: CupertinoTextThemeData(
                dateTimePickerTextStyle: TextStyle(
                  color: const Color.fromARGB(255, 4, 88, 141),
                  fontSize: screenWidth * 0.043,
                ),
              ),
            ),
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              backgroundColor: Colors.white,
              initialDateTime: newdate,
              onDateTimeChanged: (DateTime picked) {
                setState(() {
                  newdate = picked;
                });
              },
            ),
          ),
        ),

        SizedBox(height: screenHeight * 0.01),

        // the formatted-button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 4, 88, 141),
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.01,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
            ),
            onPressed: () {
              // Format using your helper:
              final formattedDate =
                  '${newdate.day} ${_getMonthName(newdate.month)} ${newdate.year}';
              setState(() {
                selectedDate = formattedDate;
              });
              // Pass the formatted string (or the DateTime) to your next page:
              _navigateToAvailableFlightsPage(context);
            },
            child: Text(
              'Check Availability',
              style: TextStyle(
                fontSize: screenWidth * 0.038,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ),
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
                // Form card
                SizedBox(height: screenHeight * 0.01)
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
                    'assets/chatboticon.png', 'Yaana', false),
              ],
            ),
          ),
        ),
      ),
    );
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
        return '';
    }
  }

  String _getDayOfWeek(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }
}
