import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import './services/api_service.dart';

void main() {
  // Add these lines before runApp()
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyLoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 56, 56, 56),
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/logo.png',
              height: screenHeight * 0.3,
              width: screenWidth * 0.5,
              fit: BoxFit.contain,
            ),
          ),

          /// SriLankan Logo at the Bottom
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/Srilankan-white.png',
                height: 30,
                width: 150,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({Key? key}) : super(key: key);

  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  //late String selectedDate = '';//commented by Chamila
  String selectedDate = '';
  late PageController _pageController;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final APIService _apiService = APIService();
  String? _errorMessage;
  String? _loginSuccessMessage;
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadCredentials();
    _attemptAutoLogin();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _attemptAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    final savedPassword = prefs.getString('password');

    if (savedUsername != null && savedPassword != null) {
      setState(() {
        _isLoading = true; // Show a loading indicator
      });

      try {
        final response = await _apiService.login(savedUsername, savedPassword);

        if (response['RESPONSE_CODE'] == '1') {
          final displayName =
              response['DISPLAYNAME'] ?? _extractUserName(response['PATH']);
          final userId = response['USERID'] ?? '';

          prefs.setString('displayName', displayName);
          prefs.setString('userId', userId);

          setState(() {
            _errorMessage = null;
            _loginSuccessMessage = 'Login successful';
          });

                   _navigateToHomePage(context, selectedDate);

        } else {
          setState(() {
            _errorMessage = 'Auto-login failed. Please log in manually.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Auto-login error. Please try again later.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString('username') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
    });
  }

  Future<void> _saveCredentials(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
  }

  Future<void> _saveUserName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', name);
  }

  String _extractUserName(String path) {
    final regex = RegExp(r'CN=([^,]+)');
    final match = regex.firstMatch(path);
    return match != null ? match.group(1) ?? '' : '';
  }

  // Future<void> _login() async {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   final username = _usernameController.text;
  //   final password = _passwordController.text;

  //   try {
  //     final response = await _apiService.login(username, password);
  //     if (response['RESPONSE_CODE'] == '1') {
  //       setState(() {
  //         _errorMessage = null;
  //         _loginSuccessMessage = 'Login successful';
  //       });

  //       final displayName =
  //           response['DISPLAYNAME'] ?? _extractUserName(response['PATH']);
  //       final userId =
  //           response['USERID'] ?? ''; // Assuming USERID might be null

  //       SharedPreferences prefs = await SharedPreferences.getInstance();
  //       prefs.setString('displayName', displayName);
  //       prefs.setString('userId', userId);

       

  //       // Print username and password to console
  //       print('Username: $username');
  //       print('Password: $password');

  //       _usernameController.clear();
  //       _passwordController.clear();

  //       _navigateToHomePage(context, selectedDate);
  //     } else {
  //       setState(() {
  //         _errorMessage = 'Login unsuccessful. Please check your credentials.';
  //         _loginSuccessMessage = null;
  //       });

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Center(
  //               child: Text(
  //                   'Login unsuccessful. Please check your credentials.',
  //                   style: TextStyle(fontWeight: FontWeight.bold))),
  //           duration: Duration(seconds: 2),
  //           behavior: SnackBarBehavior.floating,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _errorMessage = 'An error occurred. Please try again later.';
  //       _loginSuccessMessage = null;
  //     });

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content:
  //             Center(child: Text('An error occurred. Please try again later.')),
  //         duration: Duration(seconds: 2),
  //         behavior: SnackBarBehavior.floating,
  //       ),
  //     );
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  Future<void> _login() async {
  setState(() => _isLoading = true);

  final username = _usernameController.text;
  final password = _passwordController.text;

  try {
    final response = await _apiService.login(username, password);

    if (response['RESPONSE_CODE'] == '1') {
      // ✅ SUCCESS: go straight to Home, replacing this page
      final displayName =
          response['DISPLAYNAME'] ?? _extractUserName(response['PATH']);
      final userId = response['USERID'] ?? '';

      final prefs = await SharedPreferences.getInstance();
      await prefs
        ..setString('displayName', displayName)
        ..setString('userId', userId);
 ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(
                child: Text('Login successful',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _saveCredentials(username, password);
_isLoading=false;
        // Print username and password to console
        print('Username: $username');
        print('Password: $password');

        _usernameController.clear();
        _passwordController.clear();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePage(selectedDate: selectedDate),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Login unsuccessful. Please check your credentials.';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Login unsuccessful. Please check your credentials.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'An error occurred. Please try again later.';
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('An error occurred. Please try again later.', textAlign: TextAlign.center),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}


  void _navigateToHomePage(BuildContext context, String selectedDate) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => HomePage(selectedDate: selectedDate)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double logoHeight;
    double textFieldPadding;
    double buttonMargin;
    double buttonHeight;
    double textFieldHeight;
    double textFieldFontSize;
    double buttonFontSize;

    if (screenWidth >= 768) {
      // iPad Air (5th Gen) and iPad (10th Gen) and iPad Pro (11-inch) and iPad Pro (12-inch)
      logoHeight = screenHeight * 0.12;
      textFieldPadding = screenWidth * 0.055;
      buttonMargin = screenWidth * 0.045;
      buttonHeight = screenHeight * 0.075;
      textFieldHeight = screenHeight * 0.001;
      textFieldFontSize = screenWidth * 0.025;
      buttonFontSize = screenWidth * 0.025;
    } else if (screenWidth <= 768 && screenWidth > 600) {
      // iPad mini (6th Gen)
      logoHeight = screenHeight * 0.16;
      textFieldPadding = screenWidth * 0.06;
      buttonMargin = screenWidth * 0.05;
      buttonHeight = screenHeight * 0.08;
      textFieldHeight = screenHeight * 0.001;
      textFieldFontSize = screenWidth * 0.025;
      buttonFontSize = screenWidth * 0.03;
    } else if (screenWidth >= 430) {
      // iPhone 15 Plus and 15 Pro Max
      logoHeight = screenHeight * 0.14;
      textFieldPadding = screenWidth * 0.055;
      buttonMargin = screenWidth * 0.045;
      buttonHeight = screenHeight * 0.08;
      textFieldHeight = screenHeight * 0.001;
      textFieldFontSize = screenWidth * 0.04;
      buttonFontSize = screenWidth * 0.04;
    } else if (screenWidth >= 393) {
      // iPhone 15
      logoHeight = screenHeight * 0.14;
      textFieldPadding = screenWidth * 0.06;
      buttonMargin = screenWidth * 0.05;
      buttonHeight = screenHeight * 0.08;
      textFieldHeight = screenHeight * 0.001;
      textFieldFontSize = screenWidth * 0.04;
      buttonFontSize = screenWidth * 0.04;
    } else if (screenWidth >= 375) {
      // Small devices like iPhone SE
      logoHeight = screenHeight * 0.12;
      textFieldPadding = screenWidth * 0.05;
      buttonMargin = screenWidth * 0.04;
      buttonHeight = screenHeight * 0.08;
      textFieldHeight = screenHeight * 0.02;
      textFieldFontSize = screenWidth * 0.035;
      buttonFontSize = screenWidth * 0.04;
    } else if (screenWidth <= 600 && screenWidth > 400) {
      // Customization for medium-sized Android screens (Pixel 7 Pro API 29)
      logoHeight = screenHeight * 0.16;
      textFieldPadding = screenWidth * 0.06;
      buttonMargin = screenWidth * 0.05;
      buttonHeight = screenHeight * 0.08;
      textFieldHeight = screenHeight * 0.001;
      textFieldFontSize = screenWidth * 0.04;
      buttonFontSize = screenWidth * 0.04;
    } else {
      // iPhone or similar sized devices
      logoHeight = screenHeight * 0.2;
      textFieldPadding = screenWidth * 0.06;
      buttonMargin = screenWidth * 0.05;
      buttonHeight = screenHeight * 0.08;
      textFieldHeight = screenHeight * 0.08;
      textFieldFontSize = screenWidth * 0.04;
      buttonFontSize = screenWidth * 0.04;
    }
    if (_isLoading) {
  return Scaffold(
    body: Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/blur.png',
            fit: BoxFit.cover,
          ),
        ),
        const Center(
          child: CircularProgressIndicator(),
        ),
      ],
    ),
  );
}

    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Allow resizing when the keyboard appears
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            // Full-screen background image
            Positioned.fill(
              child: Image.asset(
                'assets/flistalogin.png',
                fit: BoxFit.cover,
              ),
            ),

            // Content (keeps the gradient if needed)
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.4),
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.11),
                    child: Column(
                      children: <Widget>[
                        // Logo
                        Transform.translate(
                          offset: Offset(0.0, screenHeight * 0.08),
                          child: Image.asset(
                            'assets/logo.png',
                            height: logoHeight,
                            width: screenWidth * 0.45,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.08),

                        // Staff ID TextField
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: textFieldPadding,
                              vertical: textFieldHeight * 0.1),
                          margin: EdgeInsets.all(buttonMargin * 0.5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.8)),
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.04),
                          ),
                          child: TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'User ID',
                              labelStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: textFieldFontSize,
                              ),
                              prefixIcon:
                                  const Icon(Icons.person, color: Colors.white),
                              border: InputBorder.none,
                            ),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: textFieldFontSize,
                              color: Colors
                                  .white, // This makes the text color white
                            ),
                          ),
                        ),

// Password TextField
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: textFieldPadding,
                              vertical: textFieldHeight * 0.1),
                          margin: EdgeInsets.all(buttonMargin * 0.5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.8)),
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.04),
                          ),
                          child: TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: textFieldFontSize,
                              ),
                              prefixIcon:
                                  const Icon(Icons.lock, color: Colors.white),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white,
                                ),
                                onPressed: _togglePasswordVisibility,
                              ),
                              border: InputBorder.none,
                            ),
                            obscureText: _obscureText,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: textFieldFontSize,
                              color: Colors
                                  .white, // Imasha and Ayani are the bestest
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.01),

                        // Login Button
                        Container(
                          width: double.infinity,
                          height: buttonHeight * 0.85,
                          margin: EdgeInsets.symmetric(
                              horizontal: buttonMargin * 0.5),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.03),
                          ),
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 235, 98, 39),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.04),
                              ),
                              elevation: 5,
                              shadowColor: Colors.black,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: buttonFontSize * 1.2,
                                    ),
                                  ),
                          ),
                        ),

                        if (_errorMessage != null)
                          Padding(
                            padding: EdgeInsets.only(top: screenHeight * 0.02),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: textFieldFontSize,
                              ),
                            ),
                          ),

                        // Bottom Logo
                        Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.04),
                          child: Image.asset(
                            'assets/Srilankan-white.png',
                            height: screenHeight * 0.03,
                            width: screenWidth * 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

