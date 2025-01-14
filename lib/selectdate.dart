import 'package:flista_new/home.dart';
import 'package:flista_new/mytickets.dart';
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

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
  }

  String _originCountry = '      CMB';
  String _destinationCountry = '       BKK';

  void _swapCountries() {
    setState(() {
      final String temp = _originCountry;
      _originCountry = _destinationCountry;
      _destinationCountry = temp;
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

  void _navigateToAvailableFlightsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AvailableFlightsPage(
          selectedDate: selectedDate,
          originCountryCode: widget.originCountryCode, // Pass originCountryCode
          destinationCountryCode:
              widget.destinationCountryCode, // Pass destinationCountryCode
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

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
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
                  MaterialPageRoute(
                      builder: (context) =>
                          HomePage(selectedDate: selectedDate)),
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
                        height:
                            screenHeight * 0.054, // Adjust the height as needed
                        width: screenWidth * 0.72,
                        child: const Image(
                          image: AssetImage('assets/airplane-route.png'),
                          fit: BoxFit.fill,
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
                              offset: Offset(
                                  -screenWidth * 0.086, -screenHeight * 0.035),
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
        height: screenHeight * 0.8,
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
                  height: screenHeight * 0.48,
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
                                backgroundColor: Colors.transparent,
                                shadowColor:
                                    const Color.fromARGB(255, 33, 144, 213),
                                side: const BorderSide(
                                    width: 1.5, color: Colors.white),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9.0),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.05,
                                    vertical: screenHeight * 0.017),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Tomorrow',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.045,
                                    ),
                                  ),
                                  Text(
                                    formattedTomorrow,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.034,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _getDayOfWeek(tomorrow.weekday),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.036,
                                      fontWeight: FontWeight.w300,
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
                                backgroundColor: Colors.transparent,
                                shadowColor:
                                    const Color.fromARGB(255, 33, 144, 213),
                                side: const BorderSide(
                                    width: 1.5, color: Colors.white),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9.0),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.05,
                                    vertical: screenHeight * 0.017),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Day After',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.045,
                                    ),
                                  ),
                                  Text(
                                    formattedDayAfterTomorrow,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.034,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _getDayOfWeek(dayAfterTomorrow.weekday),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.036,
                                      fontWeight: FontWeight.w300,
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
                              selectedDate = formattedDayAfterDayAfterTomorrow;
                            });
                            _navigateToAvailableFlightsPage(
                                context); // Handle checking availability
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor:
                                const Color.fromARGB(255, 33, 144, 213),
                            side: const BorderSide(
                                width: 1.5, color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.25,
                                vertical: screenHeight * 0.014),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'The Next Day',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.05,
                                ),
                              ),
                              Text(
                                formattedDayAfterDayAfterTomorrow,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.036,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _getDayOfWeek(dayAfterDayAfterTomorrow.weekday),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                  fontSize: screenWidth * 0.038,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Form card
              SizedBox(height: screenHeight * 0.02)
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
            backgroundColor: Colors.transparent,
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
                      transitionDuration: Duration(seconds: 0), // No animation
                    ),
                  );
                  break;
                case 1: // Home
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          HomePage(selectedDate: selectedDate),
                      transitionDuration: Duration(seconds: 0), // No animation
                    ),
                  );
                  break;
                case 2: // My Tickets
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const MyTickets(),
                      transitionDuration: Duration(seconds: 0), // No animation
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

                  if (confirmLogout == true) {
                    _logout(); // Call the logout function
                  }
                  break;
              }
            },
            items: [
              _buildCustomBottomNavigationBarItem(
                  Icons.history, 'History', false),
              _buildCustomBottomNavigationBarItem(
                  Icons.home_outlined, 'Home', false),
              _buildCustomBottomNavigationBarItem(
                  Icons.airplane_ticket_outlined, 'My Tickets', false),
              _buildCustomBottomNavigationBarItem(
                  Icons.logout, 'Logout', false),
            ],
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
