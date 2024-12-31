/*
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
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';
import 'user_model.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  DateTime? _selectedDate;
  String? _selectedGender;
  final TextEditingController _occupationController = TextEditingController();
  final PageController _pageController = PageController();

  final List<String> genders = ['Male', 'Female', 'Other', 'Prefer not to say'];
  final List<String> occupations = [
    'Student',
    'Mental Health Counselor',
    'Content Creator',
    'Academician',
    'Engineer',
    'Teacher',
    'Doctor',
    'Police',
    'Soldier',
    'Freelance',
    'Not Working',
    'Sign Language Interpreter',
    'Language Interpretation',
    'Speech and language therapist',
    'Psychotherapist',
    'Audiologist',
    'Child care worker',
    'Social worker',
    'Social-worker-deaf',
    'Other'
  ];
  bool _showOtherOccupation = false;
  String? _selectedOccupation;
  @override
  void dispose() {
    _pageController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        // Make date picker responsive
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor:
                MediaQuery.of(context).size.width < 360 ? 0.8 : 1.0,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        // Check if email exists
        final userData = UserModel(
          uid: user.uid,
          email: user.email!, // Add this line
          birthDate: _selectedDate!,
          gender: _selectedGender!,
          occupation: _occupationController.text,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userData.toMap());

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('showOnboarding', false);

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      } else {
        throw Exception('User email not found');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    }
  }

  /*
  Widget _buildWelcomePage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final maxWidth = constraints.maxWidth;
        final isSmallScreen = maxWidth < 360;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: maxWidth * 0.05,
              vertical: maxHeight * 0.02,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: maxHeight * 0.05),
                Image.asset(
                  'assets/onboarding1.png',
                  height: maxHeight * 0.3,
                  width: maxWidth * 0.8,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: maxHeight * 0.05),
                Text(
                  'Welcome to Sign Speak App',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: maxHeight * 0.02),
                Text(
                  'Discover bidirectional communication',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
   */
  Widget _buildWelcomePage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final maxWidth = constraints.maxWidth;
        final isSmallScreen = maxWidth < 360;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: maxWidth * 0.05,
              vertical: maxHeight * 0.02,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: maxHeight * 0.15), // Increased space from top
                Image.asset(
                  'assets/onboarding1.png',
                  height: maxHeight * 0.4, // Increased image size
                  width: maxWidth * 0.9, // Increased image width
                  fit: BoxFit.contain,
                ),
                SizedBox(height: maxHeight * 0.08), // Increased spacing
                Text(
                  'Welcome to Sign Speak App',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 24 : 28, // Increased font size
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: maxHeight * 0.03), // Increased spacing
                Text(
                  'Discover bidirectional communication',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18, // Increased font size
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBirthDatePage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final maxWidth = constraints.maxWidth;
        final isSmallScreen = maxWidth < 360;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: maxWidth * 0.05,
              vertical: maxHeight * 0.02,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: maxHeight * 0.1),
                Text(
                  'When were you born?',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: maxHeight * 0.05),
                SizedBox(
                  width: maxWidth * 0.7,
                  height: maxHeight * 0.06,
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _selectedDate == null
                          ? 'Select Birth Date'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: Colors.white, // Add this line
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenderPage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final maxWidth = constraints.maxWidth;
        final isSmallScreen = maxWidth < 360;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: maxWidth * 0.05,
              vertical: maxHeight * 0.02,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: maxHeight * 0.1),
                Text(
                  'What\'s your gender?',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: maxHeight * 0.05),
                ...genders.map((gender) => Padding(
                      padding: EdgeInsets.symmetric(vertical: maxHeight * 0.01),
                      child: SizedBox(
                          width: maxWidth * 0.7,
                          height: maxHeight * 0.06,
                          child: ElevatedButton(
                            onPressed: () =>
                                setState(() => _selectedGender = gender),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedGender == gender
                                  ? Colors.blue
                                  : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              foregroundColor: Colors.white, // Add this line
                            ),
                            child: Text(
                              gender,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                color: Colors.white, // Add this line
                              ),
                            ),
                          )),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOccupationPage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final maxWidth = constraints.maxWidth;
        final isSmallScreen = maxWidth < 360;

        return Column(
          // Changed to Column to better control the layout
          children: [
            // Title section
            SizedBox(height: maxHeight * 0.05),
            Text(
              'What\'s your occupation?',
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: maxHeight * 0.03),

            // Scrollable list of occupations
            Expanded(
              // Make the list take remaining space
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: maxWidth * 0.05,
                    vertical: maxHeight * 0.02,
                  ),
                  child: Column(
                    children: occupations
                        .map((occupation) => Padding(
                              padding:
                                  EdgeInsets.only(bottom: maxHeight * 0.01),
                              child: SizedBox(
                                width:
                                    double.infinity, // Make buttons full width
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedOccupation = occupation;
                                      if (occupation == 'Other') {
                                        _showOtherOccupation = true;
                                        _occupationController.clear();
                                      } else {
                                        _showOtherOccupation = false;
                                        _occupationController.text = occupation;
                                      }
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _selectedOccupation == occupation
                                            ? Colors.blue
                                            : Colors.grey,
                                    padding: EdgeInsets.symmetric(
                                      vertical: maxHeight * 0.02,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    occupation,
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),

            // "Other" occupation text field if selected
            if (_showOtherOccupation)
              Padding(
                padding: EdgeInsets.all(maxWidth * 0.05),
                child: TextField(
                  controller: _occupationController,
                  style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  decoration: const InputDecoration(
                    labelText: 'Enter your occupation',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // Update the _canProceed method to handle the new occupation selection
  bool _canProceed() {
    switch (_currentPage) {
      case 1:
        return _selectedDate != null;
      case 2:
        return _selectedGender != null;
      case 3:
        if (_showOtherOccupation) {
          return _occupationController.text.isNotEmpty;
        }
        return _selectedOccupation != null;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxHeight = constraints.maxHeight;
            final maxWidth = constraints.maxWidth;
            final isSmallScreen = maxWidth < 360;

            return Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    children: [
                      _buildWelcomePage(),
                      _buildBirthDatePage(),
                      _buildGenderPage(),
                      _buildOccupationPage(),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: maxWidth * 0.05,
                    vertical: maxHeight * 0.02,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            'Back',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              color: Colors.white, // Added white color
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      ElevatedButton(
                        onPressed: !_canProceed()
                            ? null
                            : () {
                                if (_currentPage < 3) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                } else {
                                  _saveUserData();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: maxWidth * 0.08,
                            vertical: maxHeight * 0.015,
                          ),
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        ),
                        child: Text(
                          _currentPage < 3 ? 'Next' : 'Finish',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.white, // Added white color
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
