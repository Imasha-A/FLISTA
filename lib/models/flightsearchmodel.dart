class FlightSearchModel {
  List<Map<String, String>> _originCountries;
  List<Map<String, String>> _destinationCountries;
  String? _selectedOriginCountry;
  String? _selectedOriginCountryCode;
  String? _selectedDestinationCountry;
  String? _selectedDestinationCountryCode;

  FlightSearchModel({
    required List<Map<String, String>> originCountries,
    required List<Map<String, String>> destinationCountries,
    String? selectedOriginCountry,
    String? selectedOriginCountryCode,
    String? selectedDestinationCountry,
    String? selectedDestinationCountryCode,
  })  : _originCountries = originCountries,
        _destinationCountries = destinationCountries,
        _selectedOriginCountry = selectedOriginCountry,
        _selectedOriginCountryCode = selectedOriginCountryCode,
        _selectedDestinationCountry = selectedDestinationCountry,
        _selectedDestinationCountryCode = selectedDestinationCountryCode;

  List<Map<String, String>> get originCountries => _originCountries;
  set originCountries(List<Map<String, String>> value) {
    _originCountries = value;
  }

  List<Map<String, String>> get destinationCountries => _destinationCountries;
  set destinationCountries(List<Map<String, String>> value) {
    _destinationCountries = value;
  }

  String? get selectedOriginCountry => _selectedOriginCountry;
  set selectedOriginCountry(String? value) {
    _selectedOriginCountry = value;
  }

  String? get selectedOriginCountryCode => _selectedOriginCountryCode;
  set selectedOriginCountryCode(String? value) {
    _selectedOriginCountryCode = value;
  }

  String? get selectedDestinationCountry => _selectedDestinationCountry;
  set selectedDestinationCountry(String? value) {
    _selectedDestinationCountry = value;
  }

  String? get selectedDestinationCountryCode => _selectedDestinationCountryCode;
  set selectedDestinationCountryCode(String? value) {
    _selectedDestinationCountryCode = value;
  }
}
