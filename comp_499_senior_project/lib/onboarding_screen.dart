import 'package:flutter/material.dart';
import 'package:onboarding/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart'; // Replace with your actual HomePage import

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late int index;
  late Material materialButton;

  @override
  void initState() {
    super.initState();
    index = 0;
    materialButton = _skipButton();
  }

  Material _skipButton() {
    return Material(
      borderRadius: BorderRadius.circular(20.0),
      color: Colors.blue,
      child: InkWell(
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('showOnboarding', false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
        child: const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            'Skip',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Material _startButton() {
    return Material(
      borderRadius: BorderRadius.circular(20.0),
      color: Colors.green,
      child: InkWell(
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('showOnboarding', false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
        child: const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            'Start',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  List<PageModel> _buildOnboardingPages(BuildContext context) {
    return [
      PageModel(
        widget: SafeArea(
          child: Column(
            children: [
              // Flexible Image Section
              Expanded(
                flex: 3,
                child: Center(
                  child: Image.asset(
                    'assets/onboarding1.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Text Section
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome to Sign Speak App',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.08,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Discover bidirectional communication ',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.045,
                          color: Colors.grey[700],
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
    ];
  }

  @override
  Widget build(BuildContext context) {
    final onboardingPagesList = _buildOnboardingPages(context);

    return Scaffold(
      body: Onboarding(
        pages: onboardingPagesList,
        onPageChange: (int pageIndex) {
          setState(() {
            index = pageIndex;
            materialButton = pageIndex == onboardingPagesList.length - 1
                ? _startButton()
                : _skipButton();
          });
        },
        startPageIndex: 0,
        footerBuilder: (context, dragDistance, pagesLength, setIndex) {
          return Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomIndicator(
                  netDragPercent: dragDistance,
                  pagesLength: pagesLength,
                  indicator: Indicator(
                    activeIndicator: ActiveIndicator(color: Colors.blue),
                    closedIndicator: ClosedIndicator(color: Colors.grey),
                    indicatorDesign: IndicatorDesign.polygon(
                      polygonDesign: PolygonDesign(
                        polygon: DesignType.polygon_circle,
                      ),
                    ),
                  ),
                ),
                materialButton,
              ],
            ),
          );
        },
      ),
    );
  }
}
