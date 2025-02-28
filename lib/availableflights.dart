import 'package:flista_new/mytickets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'capacityinfo.dart';
import '../models/availableflightsmodel.dart';
import '../services/api_service.dart';
import './history.dart';
import 'databasehelper.dart';
import 'home.dart';
import 'main.dart';

class AvailableFlightsPage extends StatefulWidget {
  final String selectedDate;
  final String originCountryCode;
  final String destinationCountryCode;
  const AvailableFlightsPage({
    Key? key,
    required this.selectedDate,
    required this.originCountryCode, // New
    required this.destinationCountryCode,
  }) : super(key: key);

  @override
  _AvailableFlightsState createState() => _AvailableFlightsState();
}

class _AvailableFlightsState extends State<AvailableFlightsPage> {
  late String selectedDate;
  List<AvailableFlightModel> ulList = [];
  String selectedUL = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;

    // Assign availableFlights to ulList
    print('Formatted date: ${APIService().formatDate(selectedDate)}');
    _fetchFlightInfo();
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

  void _fetchFlightInfo() async {
    try {
      // Print the origin and destination country codes
      print(
          'Origin Country Code: ${APIService().formatOriginCountryCode(widget.originCountryCode)}');
      print(
          'Destination Country Code: ${APIService().formatDestinationCountryCode(widget.destinationCountryCode)}');

      // Call getFlightInfo method from APIService
      List<dynamic> flightInfo = await APIService().getFlightInfo(
        widget.selectedDate,
        widget.originCountryCode,
        widget.destinationCountryCode,
      );

      // Extract flight information from the response and update ulList
      ulList = flightInfo
          .map((flight) => AvailableFlightModel.fromJson(flight))
          .toList();

      // Print the result
      print('ulList: $ulList');

      // Update the UI with the fetched data
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      // Handle any errors that occur during the API call
      print('Error fetching flight information: $error');
    }
  }

  Future<void> _saveFlightInfoToDB(
      String ulNumber, String scheduledTime) async {
    if (ulNumber.isEmpty ||
        scheduledTime.isEmpty ||
        widget.originCountryCode.isEmpty ||
        widget.destinationCountryCode.isEmpty ||
        widget.selectedDate.isEmpty) {
      print('Error: One or more fields are empty');
      return;
    }

    Map<String, dynamic> flight = {
      'origin_country_code': widget.originCountryCode,
      'destination_country_code': widget.destinationCountryCode,
      'selected_date': widget.selectedDate,
      'ul_number': ulNumber,
      'scheduled_time': scheduledTime,
    };

    print('Inserting flight to DB: $flight');
    await DBHelper().insertFlight(flight);
    print('Saved to DB: $flight');
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

  void _navigateToCapacityInfoPage(
      BuildContext context, String selectedUL, String scheduledTime) {
    List<String> ulNumbers = ulList.map((flight) => flight.ulNumber).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CapacityInfoPage(
          selectedDate: selectedDate,
          selectedUL: selectedUL,
          scheduledTime:
              scheduledTime, // Pass scheduledTime to CapacityInfoPage
          originCountryCode: widget.originCountryCode,
          destinationCountryCode: widget.destinationCountryCode,
          ulList: ulNumbers, // Pass the list of ulNumbers instead of ulList
          onULSelected: (selectedUL) {
            // Handle the selected UL
          },
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
                          height: screenHeight * 0.08,
                        ),
                        SizedBox(
                          height: screenHeight * 0.04, // Parent height
                          width: screenWidth * 0.72, // Parent width
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // The line image (background) with reduced size
                              SizedBox(
                                height: screenHeight *
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
                                height: screenHeight *
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
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue), // Set the color to blue
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.all(16.0),
                      width: screenWidth * 1.6,
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
                          SizedBox(height: screenHeight * 0.03),
                          Transform.translate(
                            offset: Offset(
                                screenWidth * -0.09, screenHeight * -0.035),
                            child: Text(
                              'Available Flights',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.08,
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: Offset(
                                screenWidth * -0.18, screenHeight * -0.038),
                            child: Text(
                              'on ${widget.selectedDate}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.045),
                            ),
                          ),

                          for (var flight in ulList)
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: screenWidth *
                                      0.01), // Add space between buttons
                              child: ElevatedButton(
                                onPressed: () {
                                  _navigateToCapacityInfoPage(context,
                                      flight.ulNumber, flight.scheduledTime);
                                  _saveFlightInfoToDB(
                                      flight.ulNumber, flight.scheduledTime);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(96, 151, 181, 237),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.17,
                                    vertical: screenHeight * 0.010,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Transform.translate(
                                      offset: Offset(screenWidth * -0.13, 0.0),
                                      child: Text(
                                        'UL${flight.ulNumber}\nScheduled: ${flight.scheduledTime.substring(0, 2)}:${flight.scheduledTime.substring(2)}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                          fontSize: screenWidth * 0.05,
                                        ),
                                      ),
                                    ),
                                    Transform.translate(
                                      offset: Offset(screenWidth * 0.12, 0.0),
                                      child: const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          // New condition to display message if ulList is empty or null
                          if (ulList.isEmpty)
                            Padding(
                              padding:
                                  EdgeInsets.only(bottom: screenHeight * 0.03),
                              child: Text(
                                'No flights available for the selected date and route.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.045,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
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
      ),
    );
  }
}
