import 'package:flista_new/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'databasehelper.dart';
import 'capacityinfo.dart';
import 'main.dart'; // Import the CapacityInfoPage

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<String> uniqueFlights = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFlightHistory();
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

  Future<void> _fetchFlightHistory() async {
    final List<Map<String, dynamic>> fetchedFlights =
        await DBHelper().getFlights();
    print('Fetched Flights: $fetchedFlights');

    Set<String> flightsSet = {}; // Using a temporary set to ensure uniqueness
    for (var flight in fetchedFlights) {
      // Construct a unique key for each flight
      String flightKey =
          '${flight['ul_number']}_${flight['origin_country_code']}_${flight['destination_country_code']}_${flight['selected_date']}_${flight['scheduled_time']}';

      // Add unique flight to the set
      flightsSet.add(flightKey);
    }

    setState(() {
      uniqueFlights = flightsSet
          .toList()
          .reversed
          .toList(); // Convert set to list and reverse it
      isLoading = false;
    });
  }

  Future<void> _clearFlightHistory() async {
    await DBHelper().clearFlights();
    setState(() {
      uniqueFlights.clear(); // Clear the list
    });
  }

  void _navigateToCapacityInfoPage(String flightKey) {
    // Extract necessary flight details from flightKey
    List<String> keyParts = flightKey.split('_');
    String selectedDate = keyParts[3];
    String selectedUL = keyParts[0];
    String scheduledTime = keyParts[4];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CapacityInfoPage(
          selectedDate: selectedDate,
          selectedUL: selectedUL,
          scheduledTime: scheduledTime,
          originCountryCode:
              keyParts[1].trim(), // Format the origin country code
          destinationCountryCode:
              keyParts[2].trim(), // Format the destination country code
          ulList: const [], // Pass any necessary data
          onULSelected: (ul) {}, // Pass any necessary data
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () async {
                // Show confirmation dialog
                bool? confirmDelete = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        "Confirm Deletion",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromRGBO(2, 77, 117, 1),
                          fontSize: screenWidth * 0.06,
                        ),
                      ),
                      content: Text(
                        "Are you sure you want to clear the flight history?",
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
                );

                // If the user confirms, clear the flight history
                if (confirmDelete == true) {
                  await _clearFlightHistory();
                }
              },
            ),
          ],
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
              image: DecorationImage(
                image: AssetImage('assets/istockphoto-155362201-612x612 1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: screenWidth * 0.03),
                    Text(
                      'Flight Search History',
                      style: TextStyle(
                          color: const Color.fromRGBO(2, 77, 117, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.06),
                    ),
                    SizedBox(height: screenWidth * 0.006),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.all(16.0),
                      width: double.infinity,
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
                          SizedBox(height: screenWidth * 0.04),
                          Container(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: uniqueFlights.length,
                              itemBuilder: (context, index) {
                                final flightKey = uniqueFlights[index];

                                return Dismissible(
                                  key: Key(flightKey),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerRight,
                                        end: Alignment.centerLeft,
                                        stops: [
                                          0.26,
                                          0.05
                                        ], // Change the color transition based on the swipe position
                                        colors: [
                                          Colors.red,
                                          Color.fromRGBO(16, 38, 53, 0.761),
                                        ],
                                      ),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30.0),
                                    child: const Icon(Icons.delete,
                                        color: Colors.white),
                                  ),
                                  confirmDismiss: (direction) async {
                                    if (direction ==
                                        DismissDirection.endToStart) {
                                      return await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                              "Confirm Deletion",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: const Color.fromRGBO(
                                                    2, 77, 117, 1),
                                                fontSize: screenWidth * 0.06,
                                              ),
                                            ),
                                            content: Text(
                                              "Are you sure you want to delete this flight?",
                                              style: TextStyle(
                                                color: const Color.fromRGBO(
                                                    2, 77, 117, 1),
                                                fontSize: screenWidth * 0.045,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                  },
                                                  child: Text(
                                                    "No",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          const Color.fromRGBO(
                                                              2, 77, 117, 1),
                                                      fontSize:
                                                          screenWidth * 0.042,
                                                    ),
                                                  )),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                },
                                                child: Text(
                                                  "Yes",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: const Color.fromRGBO(
                                                        2, 77, 117, 1),
                                                    fontSize:
                                                        screenWidth * 0.042,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                    return false;
                                  },
                                  onDismissed: (direction) {
                                    setState(() {
                                      uniqueFlights.remove(flightKey);
                                    });

                                    if (uniqueFlights.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'All flights have been deleted.')),
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _navigateToCapacityInfoPage(flightKey);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(9.0),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0,
                                          vertical: 15.0,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'UL${flightKey.split('_')[0]}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: screenWidth * 0.058,
                                                ),
                                              ),
                                              Text(
                                                '${flightKey.split('_')[1].trim()} - ${flightKey.split('_')[2].trim()}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: screenWidth * 0.052,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: screenWidth * 0.02),
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Flight Date: ',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        screenWidth * 0.04,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: flightKey.split('_')[3],
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        screenWidth * 0.04,
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: screenWidth * 0.02),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: 'Scheduled Time: ',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize:
                                                            screenWidth * 0.04,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          '${flightKey.split('_')[4].substring(0, 2)}:${flightKey.split('_')[4].substring(2)}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize:
                                                            screenWidth * 0.04,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Icon(
                                                Icons.arrow_forward,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (uniqueFlights.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Text(
                                'No flight history available.',
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
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(22.0)),
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
                backgroundColor: const Color.fromRGBO(3, 47, 70, 1),
                elevation: 0,
                currentIndex: 1,
                selectedItemColor: const Color.fromARGB(255, 234, 248, 249),
                unselectedItemColor: Colors.white,
                onTap: (index) async {
                  switch (index) {
                    case 0:
                      break;
                    case 1:
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const HomePage(
                            selectedDate: '',
                          ),
                          transitionDuration:
                              Duration(seconds: 0), // No animation
                        ),
                      );
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
                      Icons.history, 'History', true),
                  _buildCustomBottomNavigationBarItem(
                      Icons.home, 'Home', false),
                  _buildCustomBottomNavigationBarItem(
                      Icons.logout, 'Logout', false),
                ],
              ),
            )));
  }
}
