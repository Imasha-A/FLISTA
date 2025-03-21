import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flista_new/mytickets.dart';
import 'package:flista_new/history.dart';
import 'package:flista_new/home.dart';

class ChatbotScreen extends StatelessWidget {
  final WebViewController webViewController;

  const ChatbotScreen({super.key, required this.webViewController});

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: webViewController);
  }
}

class Yaana extends StatefulWidget {
  const Yaana({super.key});

  @override
  State<Yaana> createState() => _YaanaState();

  static final WebViewController _webViewController = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(Colors.transparent)
    ..setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (String url) {
          debugPrint('Page started loading: $url');
          _YaanaState.isLoading = true;
        },
        onPageFinished: (String url) {
          debugPrint('Page finished loading: $url');
          _YaanaState.isLoading = false;
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('Error loading page: ${error.description}');
        },
      ),
    );

  static bool _isLoaded = false;
}

class _YaanaState extends State<Yaana> {
  static bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (!Yaana._isLoaded) {
      setState(() => isLoading = true);
      Yaana._webViewController
          .loadRequest(
            Uri.parse(
                'https://ulmobservicestest.srilankan.com/crewweb/yana.html'),
          )
          .then((_) => setState(() => isLoading = false));
      Yaana._isLoaded = true;
    }
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
            ChatbotScreen(webViewController: Yaana._webViewController),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
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
        child: Center(
          child: Text(
            'Yaana',
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.055,
              fontWeight: FontWeight.bold,
            ),
          ),
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
        Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (_, __, ___) => const HistoryPage(),
                transitionDuration: Duration.zero));
        break;
      case 1:
        Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (_, __, ___) => const HomePage(selectedDate: ''),
                transitionDuration: Duration.zero));
        break;
      case 2:
        Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (_, __, ___) => const MyTickets(),
                transitionDuration: Duration.zero));
        break;
      case 3:
        Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (_, __, ___) => const Yaana(),
                transitionDuration: Duration.zero));
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
