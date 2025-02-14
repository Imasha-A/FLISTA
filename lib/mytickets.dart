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

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadUserId();
    _loadUserIdFromPreferences().then((_) async {
      String pnr = await _fetchPNR(); // Wait for the PNR to be retrieved
      fetchData(pnr); // Pass the retrieved PNR to fetchData
    });
    _loadData();
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
    String pnr = '5TP2SH';
    return pnr;
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

  Future<void> fetchData(String pnr) async {
    try {
      allTicketInfo = await _apiService.viewTicketInformation(pnr);
      allFlightInfo = await _apiService.viewFlightInformation(pnr);

      // Print stored ticket details
      for (var ticket in allTicketInfo) {
        print(
            'Name: ${ticket.firstName} ${ticket.lastName}, Ticket No: ${ticket.TicketNumber}, Passport: ${ticket.PassportNumber}, Seat: ${ticket.SeatMapped}, Barcode: ${ticket.Ticket2DBarcode}');
      }
      for (var flights in allFlightInfo) {
        print(
            'Flight Number: ${flights.flightNumber}, Dep Date: ${flights.depDate}, Dep Time: ${flights.depTime}, Arr Date: ${flights.arrDate}, Arr Time: ${flights.arrTime}, BoardPoint: ${flights.Boardpoint}, Off Point: ${flights.Offpoint},, Off Point: ${flights.terminal}');
      }
    } catch (e) {
      print('Error fetching ticket information: $e');
    }

    await Future.delayed(Duration(seconds: 1));
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
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    _loadUserId();

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/homebgnew.png"),
          fit: BoxFit.contain,
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
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(22.0),
                      ),
                      child: const Image(
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
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.035),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //REPLACE WITH IF INFO IS THERE IN API, PASS THE ID TO API AND SEE IF DETAILS RETURN
                      if (_userId == "23799" ||
                          _userId == "IN1927" ||
                          _userId == "IN1913" ||
                          _userId == "23933" ||
                          allTicketInfo != []) //temporary
                        Container(
                            width: screenWidth * 0.99,
                            height: screenHeight * 0.992,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(49, 121, 167, 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(children: [
                              // Ticket Card Image
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: screenWidth * 0.875,
                                  height: screenHeight * 0.92,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image:
                                          AssetImage("assets/ticketCard.png"),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                              // Content Overlay
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.075,
                                  vertical: screenHeight * 0.045,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Header Section
                                    Stack(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Passenger",
                                                style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.038)),
                                            Text(
                                              ticket!.firstName,
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.04,
                                                fontWeight: FontWeight.bold,
                                                color: const Color.fromARGB(
                                                    255, 25, 25, 26),
                                              ),
                                            ),
                                            Text(
                                              ticket!.lastName,
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.04,
                                                fontWeight: FontWeight.bold,
                                                color: const Color.fromARGB(
                                                    255, 25, 25, 26),
                                              ),
                                            ),
                                            Text(
                                              ' (${ticket!.PassportNumber})',
                                              style: TextStyle(
                                                  color: const Color.fromARGB(
                                                      255, 25, 25, 26),
                                                  fontSize: screenWidth * 0.04,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.02),
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
                                                        ticket!.TicketNumber,
                                                        style: TextStyle(
                                                          fontSize:
                                                              screenWidth *
                                                                  0.04,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 25, 25, 26),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
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
                                                              FontWeight.bold,
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 25, 25, 26),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.01),
                                            Image.asset(
                                              'assets/barcode.png',
                                              width: screenWidth * 0.8,
                                              height: screenHeight * 0.14,
                                              fit: BoxFit.contain,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: screenHeight * 0.04),
                                    // Main Ticket Information - depart
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              flight!.Boardpoint,
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.07,
                                                fontWeight: FontWeight.bold,
                                                color: const Color.fromARGB(
                                                    255, 25, 25, 26),
                                              ),
                                            ),
                                            Text(
                                              "CITY MAKE",
                                              style: TextStyle(
                                                  fontSize: screenWidth * 0.03,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.01),
                                            Text(
                                              formatDate(flight!.depDate),
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.03,
                                                color: const Color.fromARGB(
                                                    255, 25, 25, 26),
                                              ),
                                            ),
                                            Text(
                                              formatTime(flight!.depTime),
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.03,
                                                color: const Color.fromARGB(
                                                    255, 25, 25, 26),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              "assets/airplaneticket.png",
                                              width: screenWidth * 0.3,
                                              height: screenHeight * 0.05,
                                              fit: BoxFit.contain,
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.03),
                                            Text(
                                              "UL255",
                                              style: TextStyle(
                                                  fontSize: screenWidth * 0.04,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "Terminal${flight!.terminal}",
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.03,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              flight!.Offpoint,
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.07,
                                                fontWeight: FontWeight.bold,
                                                color: const Color.fromARGB(
                                                    255, 25, 25, 26),
                                              ),
                                            ),
                                            Text(
                                              "CITY MAKE",
                                              style: TextStyle(
                                                  fontSize: screenWidth * 0.03,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.01),
                                            Text(
                                              formatDate(flight!.arrDate),
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.03,
                                                color: const Color.fromARGB(
                                                    255, 25, 25, 26),
                                              ),
                                            ),
                                            Text(
                                              formatTime(flight!.arrTime),
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.03,
                                                color: const Color.fromARGB(
                                                    255, 25, 25, 26),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: screenHeight * 0.02),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: screenHeight * 0.01),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text("Status",
                                                      style: TextStyle(
                                                          fontSize:
                                                              screenWidth *
                                                                  0.038)),
                                                  Text("SA FIXXX",
                                                      style: TextStyle(
                                                          fontSize:
                                                              screenWidth *
                                                                  0.038)),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text("Baggage",
                                                      style: TextStyle(
                                                          fontSize:
                                                              screenWidth *
                                                                  0.038)),
                                                  Text(
                                                    "30KG GET",
                                                    style: TextStyle(
                                                        fontSize:
                                                            screenWidth * 0.04,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text("Duration",
                                                      style: TextStyle(
                                                          fontSize:
                                                              screenWidth *
                                                                  0.038)),
                                                  Text(
                                                    "03:35",
                                                    style: TextStyle(
                                                        fontSize:
                                                            screenWidth * 0.04,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: screenHeight * 0.01),
                                        Center(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              // Define the action when the button is pressed
                                              print(
                                                  'Excess Baggage button pressed');
                                            },
                                            child: Text('Excess Baggage'),
                                            style: ElevatedButton.styleFrom(
                                              disabledBackgroundColor:
                                                  Color.fromARGB(255, 238, 238,
                                                      243), // Background color when disabled
                                              elevation: 0,
                                              foregroundColor:
                                                  const Color.fromARGB(255, 107,
                                                      109, 118), // Text color
                                              backgroundColor: const Color
                                                  .fromARGB(255, 255, 255,
                                                  255), // Button background color
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      screenWidth * 0.25,
                                                  vertical: screenHeight *
                                                      0.005), // Button padding
                                              textStyle: TextStyle(
                                                  fontSize: screenWidth *
                                                      0.037), // Text size
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        5), // Rounded corners
                                                side: BorderSide(
                                                  color: Color.fromARGB(
                                                      255,
                                                      144,
                                                      140,
                                                      159), // Border color
                                                  width: 1, // Border width
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.04),
                                      ],
                                    ),
                                    // Main Ticket Information - arrival
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "DXB",
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.07,
                                                fontWeight: FontWeight.w900,
                                                color: const Color.fromRGBO(
                                                    49, 121, 167, 1),
                                              ),
                                            ),
                                            Text(
                                              "Dubai",
                                              style: TextStyle(
                                                  fontSize: screenWidth * 0.03,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.01),
                                            Text(
                                              "30 Jan 2025",
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.03,
                                              ),
                                            ),
                                            Text(
                                              "11:00 (Local)",
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.03,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              "assets/airplaneticket.png",
                                              width: screenWidth * 0.3,
                                              height: screenHeight * 0.05,
                                              fit: BoxFit.contain,
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.03),
                                            Text(
                                              "UL256",
                                              style: TextStyle(
                                                  fontSize: screenWidth * 0.04,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "Terminal : 1",
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.03,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "CMB",
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.07,
                                                fontWeight: FontWeight.w900,
                                                color: const Color.fromRGBO(
                                                    49, 121, 167, 1),
                                              ),
                                            ),
                                            Text(
                                              "Colombo",
                                              style: TextStyle(
                                                  fontSize: screenWidth * 0.03,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.01),
                                            Text(
                                              "30 Jan 2025",
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.03,
                                              ),
                                            ),
                                            Text(
                                              "02:17 AM",
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.03,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: screenHeight * 0.02),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: screenHeight * 0.01),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text("Status",
                                                      style: TextStyle(
                                                          fontSize:
                                                              screenWidth *
                                                                  0.038)),
                                                  Text(
                                                    "SA",
                                                    style: TextStyle(
                                                        fontSize:
                                                            screenWidth * 0.04,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text("Baggage",
                                                      style: TextStyle(
                                                          fontSize:
                                                              screenWidth *
                                                                  0.038)),
                                                  Text(
                                                    "30KG",
                                                    style: TextStyle(
                                                        fontSize:
                                                            screenWidth * 0.04,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text("Duration",
                                                      style: TextStyle(
                                                          fontSize:
                                                              screenWidth *
                                                                  0.038)),
                                                  Text(
                                                    "03:17",
                                                    style: TextStyle(
                                                        fontSize:
                                                            screenWidth * 0.04,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: screenHeight * 0.01),
                                        Center(
                                          child: ElevatedButton(
                                            onPressed:
                                                null, // Setting onPressed to null disables the button
                                            child: Text('Excess Baggage'),
                                            style: ElevatedButton.styleFrom(
                                              disabledBackgroundColor:
                                                  Color.fromARGB(255, 238, 238,
                                                      243), // Background color when disabled
                                              elevation: 0,
                                              foregroundColor:
                                                  const Color.fromARGB(255, 107,
                                                      109, 118), // Text color
                                              backgroundColor: const Color
                                                  .fromARGB(255, 255, 255,
                                                  255), // Button background color
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      screenWidth * 0.25,
                                                  vertical:
                                                      screenHeight * 0.005),
                                              textStyle: TextStyle(
                                                  fontSize:
                                                      screenWidth * 0.037),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                side: BorderSide(
                                                  color: Color.fromARGB(
                                                      255, 144, 140, 159),
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ]))
                      else
                        Align(
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
                                  color: const Color.fromARGB(255, 93, 93, 93),
                                ),
                              ),
                              Text(
                                'You do not have any',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.06,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 93, 93, 93),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'booking information',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.06,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 93, 93, 93),
                                ),
                                textAlign: TextAlign.center,
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
                        transitionDuration: Duration(seconds: 0),
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
                            Duration(seconds: 0), // No animation
                      ),
                    );
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
