import 'dart:convert';
import 'package:flista_new/models/flightmodel.dart';
import 'package:flista_new/models/staffpnrmodal.dart';
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
        'https://ulmobservices.srilankan.com/ULMOBTEAMSERVICES/api/FLIGHTINFO/GET_AIRPORT_LIST?specialFlag=ALL');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data
          .map((item) => {
                'name': item['AIRPORT_NAME'] as String,
                'code': item['AIRPORT_CODE'] as String,
                'city': item['CITY_NAME'] as String,
                'country': item['COUNTRY_NAME'] as String,
              })
          .toList();
    } else {
      throw Exception('Failed to load airport list');
    }
  }

  Future<List<StaffPNRModal>> viewStaffPNR(String StaffID) async {
    final url = Uri.parse(
        'https://ulmobservices.srilankan.com/ULMOBTEAMSERVICES/api/StaffTravelGateway/GetStaffTicketDetails');

    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final body = 'StaffID=$StaffID';

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Directly map the response to StaffPNRModal list
      if (data != null && data is List) {
        return data.map((item) => StaffPNRModal.fromJson(item)).toList();
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception(
          'Failed to load ticket information: ${response.reasonPhrase}');
    }
  }

  Future<void> submitRating(String userId, int rating, String comment) async {
    final Uri url = Uri.parse(
        'https://ulmobservices.srilankan.com/ULMOBTEAMSERVICES/api/FLIGHTINFO/RateFlistaApp_New');

    // Properly URL-encode the parameters
    final Map<String, String> body = {
      'StaffID': userId,
      'Rating': rating.toString(),
      'Comments': comment,
    };

    print(body);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body, // http package automatically encodes it as form-urlencoded
        encoding: Encoding.getByName('utf-8'),
      );

      if (response.statusCode == 200) {
        print('Rating submitted successfully');
      } else {
        print(
            'Failed to submit rating: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error submitting rating: $e');
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

  String _formatDate(String selectedDate) {
    List<String> parts = selectedDate.split(' ');
    String day = parts[0];
    String month = parts[1];
    String year = parts[2].substring(2);

    String formattedMonth = _getMonthNumber(month);

    if (day.length == 1) {
      day = '0$day';
    }

    return '$day$formattedMonth$year';
  }

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
    print(
        '$baseUrl/FLIGHTINFO/ALL?FlightDate=$formattedDate&BoardPoint=$formattedOriginCountryCode&offpoint=$formattedDestinationCountryCode&FlightNo=$selectedUL&longDate=$formattedLongDate');

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

    print('$baseUrl2/FLIGHTINFO/STAFFALLV2?FlightDate=$flightDate&BoardPoint=$boardPoint&FlightNo=$flightNo'
);
    print('\n\nResponse body: ${response.body}');

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

  Future<List<TicketInformation>> viewTicketInformation(String pnr) async {
    print('Starting viewTicketInformation with PNR: $pnr');

    final url = Uri.parse(
        'https://ulmobservices.srilankan.com/ULMOBTEAMSERVICES/api/AmadeusServices/GetPNRDetailsFlista');
    print('URL: $url');

    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final body = 'PNRNo=$pnr';

    print('Sending POST request...');
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    print('Response received. Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Decoded JSON: $data');

      // Ensure PassengerInformation is always a list
      List<dynamic> passengerInfo = (data['PassengerInformation'] != null &&
              data['PassengerInformation'] is List)
          ? data['PassengerInformation']
          : [];

      print('Passenger Information count: ${passengerInfo.length}');

      List<TicketInformation> tickets = passengerInfo.map((info) {
        print('Mapping passenger info: $info');
        return TicketInformation.fromJson(info);
      }).toList();

      print('Successfully mapped to TicketInformation list.');
      return tickets;
    } else {
      print('Error: Failed to load ticket information');
      throw Exception(
          'Failed to load ticket information: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<FlightInformation>> viewFlightInformation(String pnr) async {
    print('Starting viewFlightInformation with PNR: $pnr');

    final url = Uri.parse(
        'https://ulmobservices.srilankan.com/ULMOBTEAMSERVICES/api/AmadeusServices/GetPNRDetailsFlista');
    print('URL: $url');

    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final body = 'PNRNo=$pnr';

    try {
      print('Sending POST request...');
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print('Response received. Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Decoded JSON: $data');

        // Ensure FlightInformation is always a list
        List<dynamic> flights = (data['FlightInformation'] != null &&
                data['FlightInformation'] is List)
            ? data['FlightInformation']
            : [];

        print('Flight Information count: ${flights.length}');

        List<FlightInformation> flightList = flights.map((flight) {
          print('Mapping flight info: $flight');
          return FlightInformation.fromJson(flight);
        }).toList();

        print('Successfully mapped to FlightInformation list.');
        return flightList;
      } else {
        print('Error: Failed to load flight information');
        throw Exception(
            'Failed to load flight information: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Exception: $error');
      throw Exception(
          'Error occurred while fetching flight information: $error');
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

  static Future<List<Map<String, dynamic>>> getOriginsAndDestinations() async {
    const String url =
        'https://ulmobservices.srilankan.com/ULMOBTEAMSERVICES/api/CargoMobileAppCorp/GetOriginsAndDestinations';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Decode the JSON response
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  Future<Map<String, dynamic>> sendLocationData(
      double latitude, double longitude, String id, boardPoint, String offPoint, String uniqueCustomerID, String surname, 
      String flightNum, String departureDate, String paxType, String prodIdentificationRefCode, String prodIdentificationPrimeID, 
      String requestTime, double accuracy, String givenName, String gender, String Title) async {

  
    final url = Uri.parse(""); // ADD API

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": id,
          "latitude": latitude,
          "longitude": longitude,
          "accuracy": accuracy,
          "requestTime": requestTime,
          "surname": surname,
          "paxType": paxType,
          "uniqueCustomerID": uniqueCustomerID,
          "flightNum": flightNum,
          "departureDate": departureDate,
          "prodIdentificationRefCode": prodIdentificationRefCode,
          "prodIdentificationPrimeID": prodIdentificationPrimeID,
          "boardPoint": boardPoint,
          "offPoint": offPoint,
          "givenName": givenName,
          "gender": gender,
          "Title": Title,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
        "ResponseCode": data['ResponseCode'] ?? "fail",
        "ResponseMessage": data['ResponseMessage'] ?? "Unknown error occurred."
      };
      } else {
        return {
          "ResponseCode": "fail",
          "ResponseMessage": "Failed to connect to server."
        };
      }
    } catch (e) {
       return {
        "ResponseCode": "fail",
        "ResponseMessage": "Network error: $e"
      }; // Handle exceptions
    }
  }


  Future<StaffMember?> getStaffMember(String flightDate, String boardPoint, String flightNo, String ticketNumber) async {
    final url = Uri.parse(
        '$baseUrl2/FLIGHTINFO/STAFFALLV2?FlightDate=$flightDate&BoardPoint=$boardPoint&FlightNo=$flightNo');

        print("Fetching staff member from URL: $url");

    try {
      final response = await http.get(url);
      print("Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print("Decoded API Data: $data");

        var matchingEntry = data.firstWhere(
          (item) => item['TicketNumber'] == ticketNumber,
          orElse: () => null,
        );

        if (matchingEntry != null) {
          print(" Matching Entry Found: $matchingEntry");
          return StaffMember.fromJson(matchingEntry);
        } else {
          print(" No matching entry for ticket: $ticketNumber");
          return null; // No match found for the ticket number
        }
      } else if (response.statusCode == 500) {
        print("Server Error (500) - Likely no staff data for this flight.");
        return null;  // Prevents app crash
      } else {
        throw Exception('Failed to fetch staff list: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error fetching staff member: $error');
      return null;
    }
  }
}
