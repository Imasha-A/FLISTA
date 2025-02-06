import 'package:device_info_plus/device_info_plus.dart';
import 'package:flista_new/mytickets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'selectdate.dart';
import '../models/flightsearchmodel.dart';
import './history.dart';
import './services/api_service.dart';
import 'main.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  final String selectedDate;
  const HomePage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String selectedDate;
  late String originCountryCode;
  late String destinationCountryCode;
  late String _userName = 'User Name';
  late String _userId = '123456';
  String? _errorMessage;

  bool _isLoading = true;
  List<Map<String, String>> _filteredOriginCountries = [];
  List<Map<String, String>> _filteredDestinationCountries = [];

  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _originFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();
  final FocusNode _searchFocusNode = FocusNode();

  OverlayEntry? _originOverlayEntry;
  OverlayEntry? _destinationOverlayEntry;
  Future<int>? majorVersion;

  final FlightSearchModel _flightSearchModel = FlightSearchModel(
    originCountries: [],
    destinationCountries: [],
    selectedOriginCountry: null,
    selectedOriginCountryCode: null,
    selectedDestinationCountry: null,
    selectedDestinationCountryCode: null,
  );

  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
    majorVersion = getAndroidVersion();
    originCountryCode = '';
    destinationCountryCode = '';
    _originController.text = _flightSearchModel.selectedOriginCountry ?? '';
    _destinationController.text =
        _flightSearchModel.selectedDestinationCountry ?? '';
    _filteredOriginCountries = _flightSearchModel.originCountries;
    _filteredDestinationCountries = _flightSearchModel.destinationCountries;
    _getSelectedCountries();
    _loadUserName();
    _saveUserNameToPreferences();
    _loadUserId().then((_) {
      _saveUserIdToPreferences(); // Save userId to SharedPreferences after loading it
    });
    _fetchAirportList();
    _originFocusNode.addListener(() {
      if (!_originFocusNode.hasFocus) {
        // Validate input when the field loses focus
        _validateOriginInput();
      } else if (_originController.text.isNotEmpty) {
        _showOriginSuggestions();
      } else {
        _hideOriginSuggestions();
      }
    });
    _destinationFocusNode.addListener(() {
      if (!_destinationFocusNode.hasFocus) {
        // Validate input when the field loses focus
        _validateDestinationInput();
      } else if (_destinationController.text.isNotEmpty) {
        _showDestinationSuggestions();
      } else {
        _hideDestinationSuggestions();
      }
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

  Future<void> _saveUserIdToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', _userId); // Save the userId
  }

  Future<void> _saveUserNameToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userName); // Save the variable username
  }

  void _validateOriginInput() {
    bool isValid = _flightSearchModel.originCountries.any((country) =>
        country['name'] == _originController.text ||
        country['code'] == _originController.text);

    if (!isValid) {
      // Clear invalid input
      setState(() {
        _flightSearchModel.selectedOriginCountry = null;
        _flightSearchModel.selectedOriginCountryCode = null;
        _originController.clear();
      });
    }
  }

  // Add a validation function for the destination input
  void _validateDestinationInput() {
    bool isValid = _flightSearchModel.destinationCountries.any((country) =>
        country['name'] == _destinationController.text ||
        country['code'] == _destinationController.text);

    if (!isValid) {
      // Clear invalid input
      setState(() {
        _flightSearchModel.selectedDestinationCountry = null;
        _flightSearchModel.selectedDestinationCountryCode = null;
        _destinationController.clear();
      });
    }
  }

  Future<void> _fetchAirportList() async {
    APIService apiService = APIService();
    List<Map<String, String>> airportList = await apiService.fetchAirportList();

    setState(() {
      _flightSearchModel.originCountries = airportList.map((airport) {
        return {'name': airport['name']!, 'code': airport['code']!};
      }).toList();

      _flightSearchModel.destinationCountries = airportList.map((airport) {
        return {'name': airport['name']!, 'code': airport['code']!};
      }).toList();

      _filteredOriginCountries = _flightSearchModel.originCountries;
      print(_filteredOriginCountries);
      _filteredDestinationCountries = _flightSearchModel.destinationCountries;
      _isLoading = false;
    });
  }

  String abbreviateAirportName(String name) {
    return name;
  }

  void _filterOriginCountries(String query) {
    setState(() {
      _filteredOriginCountries = _flightSearchModel.originCountries
          .where((country) =>
              (country['name']!.toLowerCase().contains(query.toLowerCase()) ||
                  country['code']!
                      .toLowerCase()
                      .contains(query.toLowerCase())) &&
              country['code'] !=
                  _flightSearchModel.selectedDestinationCountryCode)
          .toList();

      if (query.isNotEmpty) {
        _showOriginSuggestions();
      } else {
        _hideOriginSuggestions();
      }
    });
  }

  void _filterDestinationCountries(String query) {
    setState(() {
      _filteredDestinationCountries = _flightSearchModel.destinationCountries
          .where((country) =>
              (country['name']!.toLowerCase().contains(query.toLowerCase()) ||
                  country['code']!
                      .toLowerCase()
                      .contains(query.toLowerCase())) &&
              country['code'] != _flightSearchModel.selectedOriginCountryCode)
          .toList();

      if (query.isNotEmpty) {
        _showDestinationSuggestions();
      } else {
        _hideDestinationSuggestions();
      }
    });
  }

  void _selectOriginCountry(Map<String, String> country) {
    setState(() {
      _flightSearchModel.selectedOriginCountry =
          abbreviateAirportName(country['name']!);
      _flightSearchModel.selectedOriginCountryCode = country['code'];
      _originController.text = abbreviateAirportName(country['name']!);
      _filteredOriginCountries = [];
      _hideOriginSuggestions();
    });
  }

  void _selectDestinationCountry(Map<String, String> country) {
    setState(() {
      _flightSearchModel.selectedDestinationCountry =
          abbreviateAirportName(country['name']!);
      _flightSearchModel.selectedDestinationCountryCode = country['code'];
      _destinationController.text = abbreviateAirportName(country['name']!);
      _filteredDestinationCountries = [];
      _hideDestinationSuggestions();
    });
  }

  // void _swapCountries() {
  //   setState(() {
  //     if (_flightSearchModel.selectedOriginCountry != null &&
  //         _flightSearchModel.selectedDestinationCountry != null) {
  //       // Swap origin and destination countries
  //       final String temp = _flightSearchModel.selectedOriginCountry!.trim();
  //       final String tempCode =
  //           _flightSearchModel.selectedOriginCountryCode!.trim();
  //       _flightSearchModel.selectedOriginCountry =
  //           _flightSearchModel.selectedDestinationCountry!.trim();
  //       _flightSearchModel.selectedOriginCountryCode =
  //           _flightSearchModel.selectedDestinationCountryCode!.trim();
  //       _flightSearchModel.selectedDestinationCountry = temp;
  //       _flightSearchModel.selectedDestinationCountryCode = tempCode;

  //       // Update controllers
  //       _originController.text = _flightSearchModel.selectedOriginCountry!;
  //       _destinationController.text =
  //           _flightSearchModel.selectedDestinationCountry!;
  //     } else {
  //       // Show error if one of the countries is null
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content:
  //               Text('Please select both origin and destination countries.'),
  //         ),
  //       );
  //     }

  //     // Save and refresh countries
  //     _saveSelectedCountries();
  //     _getSelectedCountries();
  //   });
  // }

  // void _swapCountries() {
  //   if (_flightSearchModel.selectedOriginCountry != null &&
  //       _flightSearchModel.selectedDestinationCountry != null) {
  //     setState(() {
  //       // Swap origin and destination countries
  //       final String temp = _flightSearchModel.selectedOriginCountry!.trim();
  //       final String tempCode =
  //           _flightSearchModel.selectedOriginCountryCode!.trim();
  //       _flightSearchModel.selectedOriginCountry =
  //           _flightSearchModel.selectedDestinationCountry!.trim();
  //       _flightSearchModel.selectedOriginCountryCode =
  //           _flightSearchModel.selectedDestinationCountryCode!.trim();
  //       _flightSearchModel.selectedDestinationCountry = temp;
  //       _flightSearchModel.selectedDestinationCountryCode = tempCode;

  //       // Update text field controllers
  //       _originController.text = _flightSearchModel.selectedOriginCountry!;
  //       _destinationController.text =
  //           _flightSearchModel.selectedDestinationCountry!;

  //       // Refresh country filters
  //       _filteredOriginCountries = _flightSearchModel.originCountries;
  //       _filteredDestinationCountries = _flightSearchModel.destinationCountries;
  //     });

  //     // Save and refresh countries
  //     _saveSelectedCountries();
  //     _getSelectedCountries();
  //   } else {
  //     // Show error if one of the countries is null
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Please select both origin and destination countries.'),
  //       ),
  //     );
  //   }
  // }

  void _swapCountries() {
    if (_flightSearchModel.selectedOriginCountry != null &&
        _flightSearchModel.selectedDestinationCountry != null) {
      setState(() {
        // Swap origin and destination countries
        final String tempCountry = _flightSearchModel.selectedOriginCountry!;
        final String tempCode = _flightSearchModel.selectedOriginCountryCode!;
        _flightSearchModel.selectedOriginCountry =
            _flightSearchModel.selectedDestinationCountry!;
        _flightSearchModel.selectedOriginCountryCode =
            _flightSearchModel.selectedDestinationCountryCode!;
        _flightSearchModel.selectedDestinationCountry = tempCountry;
        _flightSearchModel.selectedDestinationCountryCode = tempCode;

        // Update text field controllers
        _originController.text = _flightSearchModel.selectedOriginCountryCode!;
        _destinationController.text =
            _flightSearchModel.selectedDestinationCountryCode!;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both origin and destination countries.'),
        ),
      );
    }
  }

  void _navigateToSelectDatePage(BuildContext context) async {
    final shouldClearControllers = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectDatePage(
          selectedDate: selectedDate,
          originCountryCode: _flightSearchModel.selectedOriginCountryCode ?? '',
          destinationCountryCode:
              _flightSearchModel.selectedDestinationCountryCode ?? '',
        ),
      ),
    );

    // Clear controllers if the result is `true`
    if (shouldClearControllers == true) {
      setState(() {
        _originController.clear();
        _destinationController.clear();
        _flightSearchModel.selectedOriginCountry = null;
        _flightSearchModel.selectedOriginCountryCode = null;
        _flightSearchModel.selectedDestinationCountry = null;
        _flightSearchModel.selectedDestinationCountryCode = null;
      });
    }
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

  void _saveSelectedCountries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String selectedOriginCountryCode =
        _flightSearchModel.selectedOriginCountryCode ?? '';
    String selectedDestinationCountryCode =
        _flightSearchModel.selectedDestinationCountryCode ?? '';

    prefs.setString('selectedOriginCountryCode', selectedOriginCountryCode);
    prefs.setString(
        'selectedDestinationCountryCode', selectedDestinationCountryCode);
  }

  Future<void> _getSelectedCountries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedOriginCountryCode =
        prefs.getString('selectedOriginCountryCode');
    String? savedDestinationCountryCode =
        prefs.getString('selectedDestinationCountryCode');

    setState(() {
      originCountryCode = savedOriginCountryCode ?? '';
      destinationCountryCode = savedDestinationCountryCode ?? '';
    });
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

  void _showOriginSuggestions() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_originOverlayEntry != null) {
        _originOverlayEntry!.remove();
      }
      _originOverlayEntry = _createOverlayEntry(
        _originController,
        _originFocusNode,
        _filteredOriginCountries,
        _selectOriginCountry,
      );
      Overlay.of(context).insert(_originOverlayEntry!);
    });
  }

  Future<int> getAndroidVersion() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    // Get the Android version as a string
    String androidVersionString = androidInfo.version.release;
    print("Android Version (String): $androidVersionString");
    int androidVersion = 0;
    // Convert the Android version to an integer for comparison
    try {
      androidVersion = int.parse(
          androidVersionString.split('.')[0]); // To handle cases like "14.1"
      print("Android Version (Integer): $androidVersion");

      // Example comparison
      if (androidVersion > 8) {
        print("Your Android version is above 8.");
        return androidVersion;
      } else {
        print("Your Android version is below 8.");
        return androidVersion;
      }
    } catch (e) {
      print("Failed to parse Android version: $e");
      return androidVersion;
    }
  }

  void _hideOriginSuggestions() {
    if (_originOverlayEntry != null) {
      _originOverlayEntry!.remove();
      _originOverlayEntry = null;
    }
  }

  void _showDestinationSuggestions() {
    if (_destinationOverlayEntry != null) {
      _destinationOverlayEntry!.remove();
    }
    _destinationOverlayEntry = _createOverlayEntry(
      _destinationController,
      _destinationFocusNode,
      _filteredDestinationCountries,
      _selectDestinationCountry,
    );
    Overlay.of(context).insert(_destinationOverlayEntry!);
  }

  void _hideDestinationSuggestions() {
    _destinationOverlayEntry?.remove();
    _destinationOverlayEntry = null;
  }

  OverlayEntry _createOverlayEntry(
    TextEditingController controller,
    FocusNode focusNode,
    List<Map<String, String>> suggestions,
    void Function(Map<String, String>) onSelect,
  ) {
    RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return OverlayEntry(
        builder: (context) => const SizedBox.shrink(),
      ); // Add fallback or error logging
    }

    if (focusNode.context?.findRenderObject() is! RenderBox) {
      return OverlayEntry(
        builder: (context) => const SizedBox.shrink(),
      ); // Safe fallback
    }
    RenderBox textFieldRenderBox =
        focusNode.context!.findRenderObject() as RenderBox;

    var textFieldSize = textFieldRenderBox.size;
    var textFieldOffset = textFieldRenderBox.localToGlobal(Offset.zero);

    final screenHeight = MediaQuery.of(context).size.height;

    return OverlayEntry(
      builder: (context) => Positioned(
        left: textFieldOffset.dx,
        top: textFieldOffset.dy + textFieldSize.height * 0.5,
        width: textFieldSize.width * 1,
        child: Material(
          elevation: 4.0,
          child: SizedBox(
            height: screenHeight * 0.18,
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true, // Ensures it scrolls properly
              children: suggestions.map((suggestion) {
                return ListTile(
                  title: Text(
                    '${suggestion['name']} (${suggestion['code']})',
                    style: const TextStyle(fontSize: 13.4),
                  ),
                  onTap: () {
                    controller.text =
                        '${suggestion['name']} (${suggestion['code']})';
                    onSelect(suggestion);
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
        future: majorVersion, // Use FutureBuilder to handle async data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Show a loading indicator while waiting
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            int majorVersion = snapshot.data ?? 0;

            final screenHeight = MediaQuery.of(context).size.height;
            final screenWidth = MediaQuery.of(context).size.width;

            if (majorVersion > 0 && majorVersion <= 8) {
              // Implementation for Android 8 or below

              return Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(110.0),
                  child: AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.transparent,
                    titleTextStyle: TextStyle(
                        fontSize: screenHeight * 0.03,
                        fontWeight: FontWeight.bold),
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
                            bottom: Radius.circular(22.0)),
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
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: screenWidth * 0.083,
                                  right: screenWidth * 0.05,
                                  top: screenHeight * 0.035),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Transform.translate(
                                    offset: Offset(
                                        0,
                                        screenHeight *
                                            0), // Adjust this value to move the text up or down
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                          'assets/logo.png',
                                          width: screenWidth * 0.4,
                                          height: screenWidth * 0.17,
                                        ),
                                        Container(
                                          width: screenWidth *
                                              0.63, // Set the desired width
                                          height:
                                              1.5, // Set the desired height (thickness of the divider)
                                          color: Colors
                                              .white, // Color of the divider
                                        ),
                                        SizedBox(height: screenHeight * 0.01),
                                        Text(
                                          _userName,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: screenWidth * 0.042,
                                          ),
                                        ),
                                        Text(
                                          _userId,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screenWidth * 0.037,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Transform.translate(
                                    offset: const Offset(0,
                                        0), // Adjust this value to move the icon up or down
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.account_circle,
                                        size: screenWidth * 0.16,
                                        color: Colors.white,
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
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Container for Android <= 8
                      GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15.0),
                          margin: const EdgeInsets.all(15.0),
                          height: screenHeight * 0.55,
                          width: screenWidth * 0.9,
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment
                                    .topCenter, // Align the text to the top center
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: screenHeight *
                                          0.01), // Add gap from top
                                  child: Text(
                                    'Search your Flight',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.06,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.03),

                              // From Country Autocomplete
                              Text(
                                "From:",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Autocomplete<String>(
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text.isEmpty) {
                                    return const Iterable<String>.empty();
                                  }
                                  // Filter by name or code
                                  return _filteredOriginCountries
                                      .where((country) =>
                                          country['name']!
                                              .toLowerCase()
                                              .contains(textEditingValue.text
                                                  .toLowerCase()) ||
                                          country['code']!
                                              .toLowerCase()
                                              .contains(textEditingValue.text
                                                  .toLowerCase()))
                                      .map((country) =>
                                          '${country['name']} (${country['code']})') // Show name and code together in suggestions
                                      .toList();
                                },
                                onSelected: (String selection) {
                                  // Extract the country name from the selected suggestion
                                  final selectedCountry =
                                      _filteredOriginCountries.firstWhere(
                                    (country) =>
                                        '${country['name']} (${country['code']})' ==
                                        selection,
                                  );
                                  setState(() {
                                    _flightSearchModel.selectedOriginCountry =
                                        selectedCountry['name'];
                                    _flightSearchModel
                                            .selectedOriginCountryCode =
                                        selectedCountry['code'];
                                  });
                                },
                                fieldViewBuilder: (context, controller,
                                    focusNode, onEditingComplete) {
                                  return TextField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter & Select Origin',
                                      hintStyle:
                                          TextStyle(color: Colors.white54),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    onChanged: (value) {
                                      setState(() {
                                        _filteredOriginCountries =
                                            _flightSearchModel.originCountries
                                                .where((country) =>
                                                    country['name']!
                                                        .toLowerCase()
                                                        .contains(value
                                                            .toLowerCase()) ||
                                                    country['code']!
                                                        .toLowerCase()
                                                        .contains(value
                                                            .toLowerCase()))
                                                .toList();
                                      });
                                    },
                                  );
                                },
                                optionsViewBuilder:
                                    (context, onSelected, options) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: screenWidth * 0.8,
                                          maxHeight: screenHeight * 0.2,
                                        ),
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: options.length,
                                          itemBuilder: (context, index) {
                                            final option =
                                                options.elementAt(index);
                                            return ListTile(
                                              title: Text(option,
                                                  style: const TextStyle(
                                                      color: Colors.black)),
                                              onTap: () => onSelected(option),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: screenHeight * 0.03),

                              // Destination Autocomplete
                              Text(
                                "To:",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Autocomplete<String>(
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text.isEmpty) {
                                    return const Iterable<String>.empty();
                                  }
                                  // Filter by name or code, excluding selected origin airport
                                  return _filteredDestinationCountries
                                      .where((country) =>
                                          country['name']!
                                              .toLowerCase()
                                              .contains(textEditingValue.text
                                                  .toLowerCase()) ||
                                          country['code']!
                                              .toLowerCase()
                                              .contains(textEditingValue.text
                                                  .toLowerCase()))
                                      .where((country) =>
                                          country['name'] !=
                                              _flightSearchModel
                                                  .selectedOriginCountry &&
                                          country['code'] !=
                                              _flightSearchModel
                                                  .selectedOriginCountryCode) // Exclude origin airport
                                      .map((country) =>
                                          '${country['name']} (${country['code']})') // Show name and code together in suggestions
                                      .toList();
                                },
                                onSelected: (String selection) {
                                  // Extract the country name from the selected suggestion
                                  final selectedCountry =
                                      _filteredDestinationCountries.firstWhere(
                                    (country) =>
                                        '${country['name']} (${country['code']})' ==
                                        selection,
                                  );
                                  setState(() {
                                    _flightSearchModel
                                            .selectedDestinationCountry =
                                        selectedCountry['name'];
                                    _flightSearchModel
                                            .selectedDestinationCountryCode =
                                        selectedCountry['code'];
                                  });
                                },
                                fieldViewBuilder: (context, controller,
                                    focusNode, onEditingComplete) {
                                  return TextField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter & Select Destination',
                                      hintStyle:
                                          TextStyle(color: Colors.white54),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    onChanged: (value) {
                                      setState(() {
                                        _filteredDestinationCountries =
                                            _flightSearchModel
                                                .destinationCountries
                                                .where((country) =>
                                                    country['name']!
                                                        .toLowerCase()
                                                        .contains(value
                                                            .toLowerCase()) ||
                                                    country['code']!
                                                        .toLowerCase()
                                                        .contains(value
                                                            .toLowerCase()))
                                                .where((country) =>
                                                    country['name'] !=
                                                        _flightSearchModel
                                                            .selectedOriginCountry &&
                                                    country['code'] !=
                                                        _flightSearchModel
                                                            .selectedOriginCountryCode)
                                                .toList();
                                      });
                                    },
                                  );
                                },
                                optionsViewBuilder:
                                    (context, onSelected, options) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: screenWidth * 0.8,
                                          maxHeight: screenHeight * 0.2,
                                        ),
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: options.length,
                                          itemBuilder: (context, index) {
                                            final option =
                                                options.elementAt(index);
                                            return ListTile(
                                              title: Text(option,
                                                  style: const TextStyle(
                                                      color: Colors.black)),
                                              onTap: () => onSelected(option),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: screenHeight * 0.04),

                              // Check Availability Button
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_flightSearchModel
                                                .selectedOriginCountry ==
                                            null ||
                                        _flightSearchModel
                                                .selectedDestinationCountry ==
                                            null ||
                                        _flightSearchModel
                                            .selectedOriginCountry!.isEmpty ||
                                        _flightSearchModel
                                            .selectedDestinationCountry!
                                            .isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please select both origin and destination countries'),
                                        ),
                                      );
                                    } else {
                                      // Save selected countries and navigate
                                      _saveSelectedCountries();
                                      _navigateToSelectDatePage(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9.0),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.009),
                                    elevation: 0,
                                    backgroundColor: Colors.transparent,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 192, 73, 22),
                                          Color.fromARGB(255, 192, 73, 22),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(9.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                              0.35), // Adjust shadow color and opacity
                                          blurRadius:
                                              4.0, // Adjust blur radius for the shadow size
                                          offset: Offset(2,
                                              2), // Adjust shadow direction and distance
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.02),
                                    child: Center(
                                      child: Text(
                                        'Check Availability',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenWidth *
                                              0.038, // Adjust font size as needed
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          child: FloatingActionButton(
                            onPressed: _showRatingPopup,
                            backgroundColor: Color.fromARGB(255, 209, 77, 20),
                            child: Icon(Icons.info, color: Colors.white),
                          ),
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
                      backgroundColor: Colors.transparent,
                      elevation: 1,
                      currentIndex: 0,
                      selectedItemColor:
                          const Color.fromARGB(255, 234, 248, 249),
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
                                      color:
                                          const Color.fromRGBO(2, 77, 117, 1),
                                      fontSize: screenWidth * 0.06,
                                    ),
                                  ),
                                  content: Text(
                                    "Are you sure you want to log out?",
                                    style: TextStyle(
                                      color:
                                          const Color.fromRGBO(2, 77, 117, 1),
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
                                          color: const Color.fromRGBO(
                                              2, 77, 117, 1),
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
                                          color: const Color.fromRGBO(
                                              2, 77, 117, 1),
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
                        _buildCustomBottomNavigationBarItem(
                            Icons.home, 'Home', true),
                        _buildCustomBottomNavigationBarItem(
                            Icons.logout, 'Logout', false),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return WillPopScope(
                onWillPop: () async => false,
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: Scaffold(
                    appBar: PreferredSize(
                      preferredSize: Size.fromHeight(screenHeight * 0.173),
                      child: AppBar(
                        automaticallyImplyLeading: false,
                        backgroundColor: Colors.transparent,
                        titleTextStyle: const TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
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
                                bottom: Radius.circular(22.0)),
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
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: screenWidth * 0.083,
                                      right: screenWidth * 0.05,
                                      top: screenHeight * 0.035),
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Transform.translate(
                                        offset: Offset(
                                            0,
                                            screenHeight *
                                                0), // Adjust this value to move the text up or down
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                              'assets/logo.png',
                                              width: screenWidth * 0.4,
                                              height: screenWidth * 0.17,
                                            ),
                                            Container(
                                              width: screenWidth *
                                                  0.63, // Set the desired width
                                              height:
                                                  1.5, // Set the desired height (thickness of the divider)
                                              color: Colors
                                                  .white, // Color of the divider
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.01),
                                            Text(
                                              _userName,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: screenWidth * 0.042,
                                              ),
                                            ),
                                            Text(
                                              _userId,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: screenWidth * 0.037,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: const Offset(0, -8),
                                        child: IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            Icons.account_circle,
                                            size: screenWidth * 0.16,
                                            color: Colors.white,
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
                    body: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: screenHeight * 0.02),
                                Container(
                                  padding: const EdgeInsets.all(2.0),
                                  margin: const EdgeInsets.all(15.0),
                                  height: screenHeight * 0.42,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color.fromRGBO(51, 123, 169, 1),
                                        Color.fromRGBO(2, 77, 117, 1),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    image: const DecorationImage(
                                      image: AssetImage('assets/world.png'),
                                      fit: BoxFit.scaleDown,
                                      scale:
                                          2, // Ensures the image covers the entire container
                                      opacity:
                                          0.32, // Adjust opacity to blend with the gradient
                                    ),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(height: screenHeight * 0.06),
                                      Transform.translate(
                                        offset: const Offset(0.0, -32.0),
                                        child: Text(
                                          'Search your Flight',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: screenWidth * 0.06,
                                          ),
                                        ),
                                      ),
                                      Stack(
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Transform.translate(
                                                  offset:
                                                      const Offset(0.85, -20.0),
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        left:
                                                            screenWidth * 0.05),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Title with Close Button
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                              height:
                                                                  screenHeight *
                                                                      0.05,
                                                              width:
                                                                  screenWidth *
                                                                      0.08,
                                                              child:
                                                                  Image.asset(
                                                                'assets/from.png',
                                                                width:
                                                                    screenWidth *
                                                                        0.1,
                                                                height:
                                                                    screenHeight *
                                                                        0.01,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    screenWidth *
                                                                        0.05),
                                                            Text(
                                                              'From',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize:
                                                                    screenWidth *
                                                                        0.05,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        SizedBox(
                                                            height:
                                                                screenHeight *
                                                                    0.015),

                                                        // Container for origin selection
                                                        SingleChildScrollView(
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              _searchQuery = '';
                                                              // Show the modal bottom sheet when the container is clicked
                                                              showCupertinoModalBottomSheet(
                                                                context:
                                                                    context,
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return Material(
                                                                    color: Colors
                                                                        .transparent,
                                                                    child:
                                                                        Container(
                                                                      padding: const EdgeInsets
                                                                          .fromLTRB(
                                                                          10,
                                                                          0,
                                                                          10,
                                                                          0),
                                                                      height:
                                                                          screenHeight *
                                                                              0.88,
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius:
                                                                            BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(16.0),
                                                                          topRight:
                                                                              Radius.circular(16.0),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Container(
                                                                            height:
                                                                                screenHeight * 0.005,
                                                                            width:
                                                                                screenWidth * 0.35,
                                                                            margin:
                                                                                const EdgeInsets.symmetric(vertical: 4),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: const Color.fromARGB(255, 195, 191, 191), // Light grey color for the line
                                                                              borderRadius: BorderRadius.circular(10), // Rounded corners (adjust the radius as needed)
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              height: screenHeight * 0.02),
                                                                          FutureBuilder(
                                                                            future:
                                                                                Future.delayed(Duration.zero, () {
                                                                              _searchFocusNode.requestFocus();
                                                                            }),
                                                                            builder:
                                                                                (context, snapshot) {
                                                                              return TextField(
                                                                                focusNode: _searchFocusNode, // Assign the focus node here
                                                                                cursorColor: Color.fromARGB(175, 60, 60, 60),
                                                                                onChanged: (value) {
                                                                                  setState(() {
                                                                                    _searchQuery = value.toLowerCase();
                                                                                  });
                                                                                },
                                                                                decoration: InputDecoration(
                                                                                  labelText: "Search Origin",
                                                                                  labelStyle: TextStyle(
                                                                                    color: const Color.fromARGB(255, 169, 165, 165),
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontSize: screenWidth * 0.035,
                                                                                  ),
                                                                                  border: OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(8.0),
                                                                                    borderSide: const BorderSide(
                                                                                      color: Colors.grey, // Default border color
                                                                                      width: 1.0,
                                                                                    ),
                                                                                  ),
                                                                                  focusedBorder: OutlineInputBorder(
                                                                                    // Ensures border stays gray when focused
                                                                                    borderRadius: BorderRadius.circular(8.0),
                                                                                    borderSide: const BorderSide(
                                                                                      color: Color.fromARGB(175, 60, 60, 60), // Change focus color
                                                                                      width: 1.5,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                          ),
                                                                          SizedBox(
                                                                              height: screenHeight * 0.02),
                                                                          Container(
                                                                            height:
                                                                                2,
                                                                            color:
                                                                                Colors.grey[300], // Light grey background
                                                                          ),
                                                                          // Filtered Country List
                                                                          Expanded(
                                                                            child:
                                                                                ListView(
                                                                              shrinkWrap: true,
                                                                              children: _filteredOriginCountries
                                                                                  .where((country) =>
                                                                                      country['code'] != _flightSearchModel.selectedOriginCountryCode &&
                                                                                      country['code'] != _destinationController.text && // Exclude destination country
                                                                                      (country['name']!.toLowerCase().contains(_searchQuery) || country['code']!.toLowerCase().contains(_searchQuery)))
                                                                                  .map((country) {
                                                                                return Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    ListTile(
                                                                                      onTap: () {
                                                                                        setState(() {
                                                                                          _originController.text = country['code']!;
                                                                                          _flightSearchModel.selectedOriginCountry = country['name'];
                                                                                          _flightSearchModel.selectedOriginCountryCode = country['code'];
                                                                                          _searchQuery = '';
                                                                                        });
                                                                                        Navigator.pop(context); // Close the bottom sheet after selection
                                                                                      },
                                                                                      title: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(
                                                                                            country['name']!,
                                                                                            style: const TextStyle(
                                                                                              color: Color.fromARGB(255, 0, 0, 0),
                                                                                              fontWeight: FontWeight.w400,
                                                                                              fontSize: 16, // You can adjust the font size here for the country name
                                                                                            ),
                                                                                          ),
                                                                                          Text(
                                                                                            country['code']!,
                                                                                            style: TextStyle(
                                                                                              color: Color.fromARGB(255, 0, 0, 0),
                                                                                              fontWeight: FontWeight.w700,
                                                                                              fontSize: screenWidth * .035, // Adjust the font size for the country code
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    Divider(
                                                                                      thickness: 0.8, // Make the divider thinner
                                                                                      height: 2, // Reduce space between items
                                                                                      color: Colors.grey[300],
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              }).toList(),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            child: Container(
                                                              width: screenWidth *
                                                                  0.9, // Made the box smaller
                                                              height:
                                                                  screenHeight *
                                                                      0.139,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                                color: _originController
                                                                        .text
                                                                        .isEmpty
                                                                    ? const Color
                                                                        .fromARGB(
                                                                        92,
                                                                        255,
                                                                        255,
                                                                        255) // When no country is selected
                                                                    : const Color
                                                                        .fromARGB(
                                                                        230,
                                                                        255,
                                                                        255,
                                                                        255), // When a country is selected
                                                                border:
                                                                    Border.all(
                                                                  color: _originController
                                                                          .text
                                                                          .isEmpty
                                                                      ? const Color
                                                                          .fromARGB(
                                                                          17,
                                                                          190,
                                                                          190,
                                                                          190) // When no country is selected
                                                                      : const Color
                                                                          .fromRGBO(
                                                                          255,
                                                                          255,
                                                                          255,
                                                                          0.776), // When a country is selected
                                                                  width: 1.2,
                                                                ),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.35), // Light shadow
                                                                    offset: const Offset(
                                                                        0,
                                                                        2), // Slight downward shadow
                                                                    blurRadius:
                                                                        4.0, // Soft blur effect
                                                                  ),
                                                                ],
                                                              ),
                                                              padding:
                                                                  EdgeInsets.all(
                                                                      screenWidth *
                                                                          0.02),
                                                              child: Center(
                                                                // Center align the content
                                                                child: _originController
                                                                        .text
                                                                        .isEmpty
                                                                    ? Text(
                                                                        "Select\n Origin",
                                                                        style:
                                                                            TextStyle(
                                                                          color: const Color
                                                                              .fromARGB(
                                                                              255,
                                                                              255,
                                                                              255,
                                                                              255),
                                                                          fontSize:
                                                                              screenWidth * 0.045,
                                                                          fontWeight:
                                                                              FontWeight.w300,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      )
                                                                    : SingleChildScrollView(
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Text(
                                                                              _originController.text,
                                                                              style: TextStyle(
                                                                                fontWeight: FontWeight.w700,
                                                                                fontSize: screenWidth * 0.065,
                                                                                color: const Color.fromARGB(255, 4, 88, 141),
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              _filteredOriginCountries.firstWhere(
                                                                                (country) => country['code'] == _originController.text,
                                                                                orElse: () => {
                                                                                  'name': 'Unknown'
                                                                                },
                                                                              )['name']!,
                                                                              style: TextStyle(
                                                                                color: const Color.fromARGB(255, 4, 88, 141),
                                                                                fontSize: screenWidth * 0.04,
                                                                              ),
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  width: screenWidth * 0.04),
                                              Expanded(
                                                child: Transform.translate(
                                                  offset:
                                                      const Offset(0.50, -20.0),
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        right:
                                                            screenWidth * 0.05),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Title with Close Button
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                              height:
                                                                  screenHeight *
                                                                      0.05,
                                                              width:
                                                                  screenWidth *
                                                                      0.08,
                                                              child:
                                                                  Image.asset(
                                                                'assets/to.png',
                                                                width:
                                                                    screenWidth *
                                                                        0.1,
                                                                height:
                                                                    screenHeight *
                                                                        0.01,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    screenWidth *
                                                                        0.05),
                                                            Text(
                                                              'To',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize:
                                                                    screenWidth *
                                                                        0.05,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                screenHeight *
                                                                    0.015),

                                                        SingleChildScrollView(
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              _searchQuery = '';
                                                              // Show the modal bottom sheet when the container is clicked
                                                              showCupertinoModalBottomSheet(
                                                                context:
                                                                    context,
                                                                //  isScrollControlled: true,
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return Material(
                                                                    color: Colors
                                                                        .transparent,
                                                                    child:
                                                                        Container(
                                                                      padding: const EdgeInsets
                                                                          .fromLTRB(
                                                                          10,
                                                                          0,
                                                                          10,
                                                                          0),
                                                                      height:
                                                                          screenHeight *
                                                                              0.88,
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius:
                                                                            BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(16.0),
                                                                          topRight:
                                                                              Radius.circular(16.0),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Container(
                                                                            height:
                                                                                screenHeight * 0.005,
                                                                            width:
                                                                                screenWidth * 0.35,
                                                                            margin:
                                                                                const EdgeInsets.symmetric(vertical: 4),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: const Color.fromARGB(255, 195, 191, 191), // Light grey color for the line
                                                                              borderRadius: BorderRadius.circular(10), // Rounded corners (adjust the radius as needed)
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              height: screenHeight * 0.02),
                                                                          FutureBuilder(
                                                                            future:
                                                                                Future.delayed(Duration.zero, () {
                                                                              _searchFocusNode.requestFocus();
                                                                            }),
                                                                            builder:
                                                                                (context, snapshot) {
                                                                              return TextField(
                                                                                focusNode: _searchFocusNode, // Assign the focus node here
                                                                                cursorColor: Color.fromARGB(175, 60, 60, 60),
                                                                                onChanged: (value) {
                                                                                  setState(() {
                                                                                    _searchQuery = value.toLowerCase();
                                                                                  });
                                                                                },
                                                                                decoration: InputDecoration(
                                                                                  labelText: "Search Destination",
                                                                                  labelStyle: TextStyle(
                                                                                    color: const Color.fromARGB(255, 169, 165, 165),
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontSize: screenWidth * 0.035,
                                                                                  ),
                                                                                  border: OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(8.0),
                                                                                    borderSide: const BorderSide(
                                                                                      color: Colors.grey, // Default border color
                                                                                      width: 1.0,
                                                                                    ),
                                                                                  ),
                                                                                  focusedBorder: OutlineInputBorder(
                                                                                    // Ensures border stays gray when focused
                                                                                    borderRadius: BorderRadius.circular(8.0),
                                                                                    borderSide: const BorderSide(
                                                                                      color: Color.fromARGB(175, 60, 60, 60), // Change focus color
                                                                                      width: 1.5,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                          ),
                                                                          SizedBox(
                                                                              height: screenHeight * 0.02),
                                                                          Container(
                                                                            height:
                                                                                2,
                                                                            color:
                                                                                Colors.grey[300], // Light grey background
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                ListView(
                                                                              shrinkWrap: true,
                                                                              children: _filteredDestinationCountries.where((country) => country['code'] != _flightSearchModel.selectedDestinationCountryCode && country['code'] != _originController.text && (country['name']!.toLowerCase().contains(_searchQuery) || country['code']!.toLowerCase().contains(_searchQuery))).map((country) {
                                                                                return Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    ListTile(
                                                                                      onTap: () {
                                                                                        setState(() {
                                                                                          _destinationController.text = country['code']!;
                                                                                          _flightSearchModel.selectedDestinationCountry = country['name'];
                                                                                          _flightSearchModel.selectedDestinationCountryCode = country['code'];
                                                                                          _searchQuery = '';
                                                                                        });
                                                                                        Navigator.pop(context); // Close the bottom sheet after selection
                                                                                      },
                                                                                      title: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(
                                                                                            country['name']!,
                                                                                            style: const TextStyle(
                                                                                              color: Color.fromARGB(255, 0, 0, 0),
                                                                                              fontWeight: FontWeight.w400,
                                                                                              fontSize: 16, // You can adjust the font size here for the country name
                                                                                            ),
                                                                                          ),
                                                                                          Text(
                                                                                            country['code']!,
                                                                                            style: TextStyle(
                                                                                              color: Color.fromARGB(255, 0, 0, 0),
                                                                                              fontWeight: FontWeight.w700,
                                                                                              fontSize: screenWidth * .035, // Adjust the font size for the country code
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    Divider(
                                                                                      thickness: 0.8, // Make the divider thinner
                                                                                      height: 5, // Reduce space between items
                                                                                      color: Colors.grey[300],
                                                                                    ), // This will add a line between each item
                                                                                  ],
                                                                                );
                                                                              }).toList(),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            child: Container(
                                                              width: screenWidth *
                                                                  0.9, // Adjusted for uniformity
                                                              height:
                                                                  screenHeight *
                                                                      0.139,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                                color: _destinationController
                                                                        .text
                                                                        .isEmpty
                                                                    ? const Color
                                                                        .fromARGB(
                                                                        92,
                                                                        255,
                                                                        255,
                                                                        255) // When no country is selected
                                                                    : const Color
                                                                        .fromARGB(
                                                                        230,
                                                                        255,
                                                                        255,
                                                                        255), // When a country is selected
                                                                border:
                                                                    Border.all(
                                                                  color: _destinationController
                                                                          .text
                                                                          .isEmpty
                                                                      ? const Color
                                                                          .fromARGB(
                                                                          17,
                                                                          190,
                                                                          190,
                                                                          190) // When no country is selected
                                                                      : const Color
                                                                          .fromARGB(
                                                                          230,
                                                                          255,
                                                                          255,
                                                                          255), // When a country is selected
                                                                  width: 1.0,
                                                                ),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.35), // Light shadow
                                                                    offset: const Offset(
                                                                        0,
                                                                        2), // Slight downward shadow
                                                                    blurRadius:
                                                                        4.0, // Soft blur effect
                                                                  ),
                                                                ],
                                                              ),
                                                              padding:
                                                                  EdgeInsets.all(
                                                                      screenWidth *
                                                                          0.02),
                                                              child: Center(
                                                                child: _destinationController
                                                                        .text
                                                                        .isEmpty
                                                                    ? Text(
                                                                        "Select Destination",
                                                                        style:
                                                                            TextStyle(
                                                                          color: const Color
                                                                              .fromARGB(
                                                                              255,
                                                                              255,
                                                                              255,
                                                                              255),
                                                                          fontSize:
                                                                              screenWidth * 0.045,
                                                                          fontWeight:
                                                                              FontWeight.w300,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      )
                                                                    : SingleChildScrollView(
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Text(
                                                                              _destinationController.text,
                                                                              style: TextStyle(
                                                                                fontWeight: FontWeight.w700,
                                                                                fontSize: screenWidth * 0.065,
                                                                                color: const Color.fromARGB(255, 4, 88, 141),
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              _filteredDestinationCountries.firstWhere(
                                                                                (country) => country['code'] == _destinationController.text,
                                                                                orElse: () => {
                                                                                  'name': 'Unknown'
                                                                                },
                                                                              )['name']!,
                                                                              style: TextStyle(
                                                                                color: const Color.fromARGB(255, 4, 88, 141),
                                                                                fontSize: screenWidth * 0.04,
                                                                              ),
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Transform.translate(
                                            offset: Offset(screenWidth * 0.37,
                                                screenHeight * 0.07),
                                            child: Container(
                                                width: screenWidth * 0.18,
                                                height: screenHeight * 0.05,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color.fromARGB(
                                                          255, 192, 73, 22),
                                                      Color.fromARGB(
                                                          255, 192, 73, 22),
                                                    ],
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                  ),
                                                ),
                                                child: GestureDetector(
                                                  onTap: _swapCountries,
                                                  child: Image.asset(
                                                    'assets/arrows.png',
                                                    width: screenWidth * 0.56,
                                                    height: screenHeight * 0.12,
                                                  ),
                                                )),
                                          ),
                                        ],
                                      ),
                                      if (_errorMessage != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            _errorMessage!,
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: screenWidth * 0.04,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (_originController.text.isEmpty ||
                                              _destinationController
                                                  .text.isEmpty) {
                                            setState(() {
                                              _errorMessage =
                                                  "Please enter both Origin and Destination";
                                            });
                                          } else {
                                            setState(() {
                                              _errorMessage = null;
                                            });
                                            _saveSelectedCountries();
                                            _navigateToSelectDatePage(context);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(9.0),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 28.0),
                                          elevation: 0,
                                          backgroundColor: Colors.transparent,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color.fromARGB(
                                                    255, 209, 77, 20),
                                                Color.fromARGB(
                                                    255, 192, 73, 22),
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(9.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                    0.35), // Adjust shadow color and opacity
                                                blurRadius:
                                                    4.0, // Adjust blur radius for the shadow size
                                                offset: Offset(2,
                                                    2), // Adjust shadow direction and distance
                                              ),
                                            ],
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: screenHeight * 0.015),
                                          child: Center(
                                            child: Text(
                                              'Check Availability',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: screenWidth * 0.038,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.12),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: EdgeInsets.all(screenWidth * 0.05),
                                    child: FloatingActionButton(
                                      onPressed: _showRatingPopup,
                                      backgroundColor:
                                          Color.fromARGB(255, 209, 77, 20),
                                      child:
                                          Icon(Icons.info, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    bottomNavigationBar: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22.0)),
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
                          selectedItemColor:
                              const Color.fromARGB(255, 234, 248, 249),
                          unselectedItemColor: Colors.white,
                          onTap: (index) async {
                            switch (index) {
                              case 0:
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const HistoryPage(),
                                    transitionDuration:
                                        const Duration(seconds: 0),
                                  ),
                                );
                                break;
                              case 1:
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const HomePage(
                                      selectedDate: '',
                                    ),
                                    transitionDuration: const Duration(
                                        seconds: 0), // No animation
                                  ),
                                );
                                break;
                              case 2: // My Tickets
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const MyTickets(),
                                    transitionDuration: const Duration(
                                        seconds: 0), // No animation
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
                                          color: const Color.fromRGBO(
                                              2, 77, 117, 1),
                                          fontSize: screenWidth * 0.06,
                                        ),
                                      ),
                                      content: Text(
                                        "Are you sure you want to log out?",
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
                                                .pop(false); // User chose "No"
                                          },
                                          child: Text(
                                            "No",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: const Color.fromRGBO(
                                                  2, 77, 117, 1),
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
                                              color: const Color.fromRGBO(
                                                  2, 77, 117, 1),
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
                            _buildCustomBottomNavigationBarItem(
                                Icons.home, 'Home', true),
                            _buildCustomBottomNavigationBarItem(
                                Icons.airplane_ticket_outlined,
                                'My Tickets',
                                false),
                            _buildCustomBottomNavigationBarItem(
                                Icons.logout, 'Logout', false),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          }
        });
  }

  void _showRatingPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        int selectedRating = 0;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.025),
              ),
              contentPadding: EdgeInsets.fromLTRB(screenWidth * 0.06,
                  screenHeight * 0.02, screenWidth * 0.06, screenHeight * 0.02),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40.0, // width of the circle
                    height: 40.0, // height of the circle
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                          255, 212, 212, 248), // background color of the circle
                      shape: BoxShape.circle, // makes the container circular
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white, // color of the "X"
                        size: 24.0, // size of the "X"
                      ),
                      onPressed: () {
                        Navigator.pop(context); // This closes the popup
                      },
                    ),
                  ),
                  Image.asset(
                    'assets/star.png',
                    width: screenWidth * 0.56,
                    height: screenHeight * 0.12,
                  ),
                  Text(
                    "Rate Flista App",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: screenHeight * 0.025,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    "Support us by providing your feedback",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: screenHeight * 0.02,
                      fontWeight: FontWeight.w300,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    "App Version - 1.2.3",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenHeight * 0.02,
                      color: const Color.fromARGB(136, 128, 126, 126),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Need help? ",
                          style: TextStyle(
                            fontSize: screenHeight * 0.02,
                            color: const Color.fromARGB(136, 128, 126,
                                126), // You can change this to the color you prefer
                            fontWeight:
                                FontWeight.w800, // Optional: make it bold
                          ),
                        ),
                        TextSpan(
                          text: "Contact IT Service Desk",
                          style: TextStyle(
                            fontSize: screenHeight * 0.02,
                            color: const Color.fromARGB(136, 128, 126, 126),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "(Ext: ",
                          style: TextStyle(
                            fontSize: screenHeight * 0.02,
                            color: const Color.fromARGB(136, 128, 126, 126),
                          ),
                        ),
                        TextSpan(
                          text: "3000",
                          style: TextStyle(
                            fontSize: screenHeight * 0.02,
                            color: const Color.fromARGB(136, 128, 126,
                                126), // You can change this to the color you prefer
                            fontWeight:
                                FontWeight.w800, // Optional: make it bold
                          ),
                        ),
                        TextSpan(
                          text: ") | 24×7 Support",
                          style: TextStyle(
                            fontSize: screenHeight * 0.02,
                            color: const Color.fromARGB(136, 128, 126, 126),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Stars Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < selectedRating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: index < selectedRating
                                  ? Colors.orange
                                  : Colors.grey,
                              size: screenWidth * 0.08,
                            ),
                            onPressed: () {
                              setState(() {
                                selectedRating = index + 1; // Update rating
                              });
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                  Image.asset(
                    'assets/itsystems.png',
                    width: screenWidth * 0.56,
                    height: screenHeight * 0.12,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
