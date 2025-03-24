import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flista_new/mytickets.dart';
import 'package:flista_new/history.dart';
import 'package:flista_new/home.dart';

class Yaana extends StatefulWidget {
  const Yaana({super.key});

  @override
  State<Yaana> createState() => _YaanaState();
}

class _YaanaState extends State<Yaana> {
  late WebViewController _webViewController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
            setState(() => isLoading = true);
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            setState(() => isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Error loading page: ${error.description}');
            setState(() => isLoading = false);
          },
        ),
      );

    _loadChatbot();
  }

  void _loadChatbot() async {
    setState(() => isLoading = true);
    await _webViewController.loadRequest(
      Uri.parse('https://ulmobservicestest.srilankan.com/crewweb/yana.html'),
    );
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/homebgnew.png"),
          fit: BoxFit.fitWidth,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.1),
          child: _buildAppBar(context),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _webViewController),
            if (isLoading)
              const Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return AppBar(
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
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(22.0)),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(22.0),
                ),
                child: Image(
                  image:
                      AssetImage('assets/istockphoto-155362201-612x612 1.png'),
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
                        'Yaana',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.055,
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
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return ClipRRect(
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
          currentIndex: 3,
          selectedItemColor: const Color.fromARGB(255, 234, 248, 249),
          unselectedItemColor: Colors.white,
          onTap: (index) {
            _navigateToPage(context, index);
          },
          items: [
            _buildBottomNavItem(Icons.history, 'History', false),
            _buildBottomNavItem(Icons.home, 'Home', false),
            _buildBottomNavItem(
                Icons.airplane_ticket_outlined, 'My Tickets', false),
            _buildBottomNavItem(Icons.person, 'Yaana', true),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HistoryPage(),
            transitionDuration: Duration(seconds: 0), // No animation
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomePage(selectedDate: ''),
            transitionDuration: Duration(seconds: 0), // No animation
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MyTickets(),
            transitionDuration: Duration(seconds: 0), // No animation
          ),
        );
        break;
      case 3:
        // Stay on the same page, do nothing
        break;
    }
  }

  BottomNavigationBarItem _buildBottomNavItem(
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
                  child: Icon(icon, color: const Color.fromRGBO(2, 77, 117, 1)),
                )
              : Icon(icon),
        ],
      ),
      label: label,
    );
  }
}
