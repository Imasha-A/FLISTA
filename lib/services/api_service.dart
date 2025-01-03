import 'dart:convert';
import 'package:flista_new/models/ticketInformationmodel.dart';
import 'package:http/http.dart' as http;
import '../models/flightloadmodel.dart';
import 'dart:core';
import '../models/staffmodel.dart';

class APIService {
  static const String baseUrl =
      'https://ulmobservices.srilankan.com/ULRESTAPP/api';

  static const String baseUrl2 =
      'https://ulmobservices.srilankan.com/ULMOBTEAMSERVICES/api';

  // Function to format the origin country code
  String formatOriginCountryCode(String originCountryCode) {
    return originCountryCode
        .trim(); // Remove leading and trailing spaces from the code
  }

  // Function to format the destination country code
  String formatDestinationCountryCode(String destinationCountryCode) {
    return destinationCountryCode
        .trim(); // Remove leading and trailing spaces from the code
  }

  // Fetch airport list
  Future<List<Map<String, String>>> fetchAirportList() async {
    final url = Uri.parse(
        'https://ulmobservicesstg.srilankan.com/ULMOBTEAMSERVICES/api/FLIGHTINFO/GET_AIRPORT_LIST?specialFlag=ALL');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data
          .map((item) => {
                'name': item['AIRPORT_NAME'] as String,
                'code': item['AIRPORT_CODE'] as String,
              })
          .toList();
    } else {
      throw Exception('Failed to load airport list');
    }
  }

  // Add login method to main.dart
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(
          'https://ulmobservices.srilankan.com/ULMOBTEAMSERVICES/api/Authentication/ADAuthenticateWithoutApsec'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'USERNAME': username,
        'PASSWORD': password,
        'APPSECAPPID': 'NONE',
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)[0];
      final path = data['PATH'];
      final userName = path.split('CN=')[1].split(',')[0];
      data['USER_NAME'] =
          userName; // Add the extracted name to the response data
      return data;
    } else {
      throw Exception('Failed to authenticate');
    }
  }

  // Modified getFlightInfo method to use formatted country codes
  Future<List<dynamic>> getFlightInfo(String selectedDate,
      String originCountryCode, String destinationCountryCode) async {
    // Convert the selected date to the format required by the API
    String formattedDate = _formatDate(selectedDate);
    // Format the origin and destination country codes
    String formattedOriginCountryCode =
        formatOriginCountryCode(originCountryCode);
    String formattedDestinationCountryCode =
        formatDestinationCountryCode(destinationCountryCode);

    final response = await http.get(
      Uri.parse(
          '$baseUrl/FLIGHTINFO?FlightDate=$formattedDate&BoardPoint=$formattedOriginCountryCode&offpoint=$formattedDestinationCountryCode'),
    );

    // Print the response before decoding it
    print('\n\nResponse body: ${response.body}');

    return json.decode(response.body);
  }

  // Function to format the selected date to the required format
  String _formatDate(String selectedDate) {
    // Split the date by spaces and get the day, month, and year
    List<String> parts = selectedDate.split(' ');
    String day = parts[0];
    String month = parts[1];
    String year =
        parts[2].substring(2); // Extract last two characters of the year

    // Convert the month to its numerical representation
    String formattedMonth = _getMonthNumber(month);

    // Pad the day with leading zeros if necessary
    if (day.length == 1) {
      day = '0$day';
    }

    // Combine the day, month, and year in the required format
    return '$day$formattedMonth$year';
  }

  // Helper function to get the numerical representation of the month
  String _getMonthNumber(String month) {
    switch (month) {
      case 'January':
        return '01';
      case 'February':
        return '02';
      case 'March':
        return '03';
      case 'April':
        return '04';
      case 'May':
        return '05';
      case 'June':
        return '06';
      case 'July':
        return '07';
      case 'August':
        return '08';
      case 'September':
        return '09';
      case 'October':
        return '10';
      case 'November':
        return '11';
      case 'December':
        return '12';
      default:
        return '';
    }
  }

  // Make the _formatDate method public
  String formatDate(String selectedDate) {
    return _formatDate(selectedDate);
  }

  // Make the _formatLongDate method public
  String formatLongDate(String selectedDate) {
    return _formatLongDate(selectedDate);
  }

  // Function to format the selected date to the required longDate format
  String _formatLongDate(String selectedDate) {
    // Split the date by spaces and get the day, month, and year
    List<String> parts = selectedDate.split(' ');
    String day = parts[0];
    String month = parts[1];
    String year = parts[2]; // Full year

    // Convert the month to its numerical representation
    String formattedMonth = _getMonthNumber(month);

    // Pad the day with leading zeros if necessary
    if (day.length == 1) {
      day = '0$day';
    }

    // Combine the day, month, and year in the required format
    return '$year$formattedMonth$day';
  }

  Future<List<FlightLoadModel>> fetchFlightLoadInfo(
      String selectedDate,
      String formattedDate,
      String formattedLongDate,
      String originCountryCode,
      String destinationCountryCode,
      String selectedUL) async {
    String formattedOriginCountryCode =
        formatOriginCountryCode(originCountryCode);
    String formattedDestinationCountryCode =
        formatDestinationCountryCode(destinationCountryCode);

    print('\n\nFormatted Date: $formattedDate');
    print('Formatted Long Date: $formattedLongDate');
    print('Formatted Origin Country Code: $formattedOriginCountryCode');
    print(
        'Formatted Destination Country Code: $formattedDestinationCountryCode');
    print('Selected UL: $selectedUL');

    final response = await http.get(
      Uri.parse(
          '$baseUrl/FLIGHTINFO/ALL?FlightDate=$formattedDate&BoardPoint=$formattedOriginCountryCode&offpoint=$formattedDestinationCountryCode&FlightNo=$selectedUL&longDate=$formattedLongDate'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<FlightLoadModel> flightLoadModels =
          data.map((item) => FlightLoadModel.fromJson(item)).toList();

      // Print the fetched data
      print('Fetched Flight Load Models: $flightLoadModels');

      return flightLoadModels;
    } else {
      throw Exception('Failed to load flight information');
    }
  }

  Future<List<StaffMember>> viewStaffMembers(
      String selectedDate, String originCountryCode, String flightNo) async {
    // Format selected date into the required format (YYYYMMDD)
    String flightDate = formatLongDate(selectedDate);

    // Format origin and destination country codes
    String boardPoint =
        formatOriginCountryCode(originCountryCode).toUpperCase();

    final response = await http.get(
      Uri.parse(
          '$baseUrl2/FLIGHTINFO/STAFFALLV2?FlightDate=$flightDate&BoardPoint=$boardPoint&FlightNo=$flightNo'),
    );

    // Check if the response status code indicates success
    if (response.statusCode == 200) {
      // If successful, parse the response body as a List<dynamic>
      List<dynamic> data = json.decode(response.body);

      // Map the dynamic list to a list of StaffMember objects
      List<StaffMember> staffMembers =
          data.map((item) => StaffMember.fromJson(item)).toList();

      return staffMembers;
    } else {
      // If the request was not successful, throw an error or return an empty list
      throw Exception('Failed to load staff members');
    }
  }
//take pnr from viewStaffMembers and send to viewTicketInformation when popup is created.
  Future<TicketInformation> viewTicketInformation(String pnr) async {
  // Set up the API endpoint
  final url = Uri.parse(
      'https://ulmobservices.srilankan.com/AmadeusLiveServices/api/AmadeusServices/GetPNRDetailsFlista');

  // Set up the request headers and body
  final headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
  };
  final body = 'PNRNo=$pnr';

  // Send the POST request
  final response = await http.post(
    url,
    headers: headers,
    body: body,
  );

  // Check if the response status code indicates success
  if (response.statusCode == 200) {
    // Parse the response body to a JSON object
    final data = json.decode(response.body);

    // Convert the JSON object to a TicketInformation instance
    return TicketInformation.fromJson(data);
  } else {
    // If the request was not successful, throw an error
    throw Exception('Failed to load ticket information');
  }
}


  Future<Map<String, dynamic>> viewCheckInStatus(String flightDate,
      String boardPoint, String flightNo, String staffID) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/FLIGHTINFO/CHECKINS?FlightDate=$flightDate&BoardPoint=$boardPoint&FlightNo=$flightNo&staffID=$staffID'),
    );
    return json.decode(response.body);
  }
}


