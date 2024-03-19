import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vpay/alluser.dart';
import 'package:vpay/auth_service.dart';
import 'package:vpay/createuser.dart';
import 'package:vpay/deleteuser.dart';
import 'package:vpay/voiceActivate.dart';
import 'makePayment.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize Firebase Authentication
  FirebaseAuth.instance;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VPay',
      theme: ThemeData(
        primarySwatch: const MaterialColor(
          0xFFEABC17,
          <int, Color>{
            50: Color(0xFFEABC17),
            100: Color(0xFFEABC17),
            200: Color(0xFFEABC17),
            300: Color(0xFFEABC17),
            400: Color(0xFFEABC17),
            500: Color(0xFFEABC17),
            600: Color(0xFFEABC17),
            700: Color(0xFFEABC17),
            800: Color(0xFFEABC17),
            900: Color(0xFFEABC17),
          },
        ),
      ),

      // Routing
      initialRoute: '/',
      routes: {
        '/': (context) => SignUpPage(),
        '/home': (context) => HomePage(),
        "/users": (context) => const AllUser(),
        '/createUser': (context) => CreateUser(),
        '/deleteUser': (context) => DeleteUser(),
      },
    );
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  // final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _availableAmountController =
      TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _registerUser() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    final username = _usernameController.text;
    final availableAmount = double.parse(_availableAmountController.text);

    final response = await http.post(
      Uri.parse('http://localhost:5000/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'available_amount': availableAmount,
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      _usernameController.clear();
      _availableAmountController.clear();
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // User signed up successfully
      print('User signed up: ${userCredential.user!.uid}');
      // Navigate to the home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'weak-password') {
          _errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          _errorMessage = 'The account already exists for that email.';
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void _signInUser() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // User signed in successfully
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _errorMessage = 'No user found for that email. Please sign up first.';
        } else if (e.code == 'wrong-password') {
          _errorMessage = 'Wrong password provided for that user.';
        }
      });
    } catch (e) {
      print(e); // Log other unexpected errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          // width: 500,
          height: 800,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: const Color.fromARGB(255, 201, 205, 147),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 80, bottom: 120),
                child: SizedBox(
                  child: Image.asset(
                    'assets/images/logob.png',
                    fit: BoxFit.contain,
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1),
                child: TextField(
                  controller: _emailController,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Enter Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Enter Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1),
                child: TextField(
                  controller: _usernameController,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1),
                child: TextField(
                  controller: _availableAmountController,
                  obscureText: true,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Available Amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 20),
              // const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _signInUser,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      minimumSize: const Size(150, 30),
                      backgroundColor: const Color.fromARGB(255, 255, 200, 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'Alata',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16.0),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _registerUser,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      minimumSize: const Size(150, 30),
                      backgroundColor: const Color.fromARGB(255, 255, 200, 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'Alata',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16.0),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFF121212),
        leading: IconButton(
          icon: const Icon(Icons.menu), // Hamburger menu icon
          color: Color.fromARGB(255, 255, 255, 255),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
            // Handle menu button press
          },
        ),
        title: const Row(
          children: [
            Text(
              'V',
              style: TextStyle(
                color: Color(0xFFEBBC17),
                fontSize: 32, // Change the color of the "V" text here
              ),
            ),
            Text(
              ' Pay',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32, // Change the color of the "Pay" text here
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFEBBC17),
              ),
              child: Text(
                'Account Holder',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_box, color: Color(0xFFEBBC17)),
              title: const Text('Add Account'),
              onTap: () {
                Navigator.pushNamed(context, '/createUser');
                // Handle home menu item tap here
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Account'),
              onTap: () {
                Navigator.pushNamed(context, '/deleteUser');
                // Handle home menu item tap here
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 1397,
            height: 930,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color(0xFF121212),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    Column(
                      children: [
                        // CARD SLIDER
                        SizedBox(
                          height: 250,
                          child: PageView(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 25),
                                child: Container(
                                  width: 310,
                                  height: 198,
                                  decoration: ShapeDecoration(
                                    image: const DecorationImage(
                                      image:
                                          AssetImage("assets/images/img_1.png"),
                                      fit: BoxFit.contain,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    shadows: const [
                                      BoxShadow(
                                        color: Color(0xFFEBBC17),
                                        blurRadius: 7,
                                        offset: Offset(2, 2),
                                        spreadRadius: 0,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 25),
                                child: Container(
                                  width: 318,
                                  height: 198,
                                  decoration: ShapeDecoration(
                                    image: const DecorationImage(
                                      image:
                                          AssetImage("assets/images/img_1.png"),
                                      fit: BoxFit.cover,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    shadows: const [
                                      BoxShadow(
                                        color: Color(0xFFEBBC17),
                                        blurRadius: 8,
                                        offset: Offset(2, 2),
                                        spreadRadius: 0,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 25),
                                child: Container(
                                  width: 318,
                                  height: 198,
                                  decoration: ShapeDecoration(
                                    image: const DecorationImage(
                                      image:
                                          AssetImage("assets/images/img_1.png"),
                                      fit: BoxFit.cover,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    shadows: const [
                                      BoxShadow(
                                        color: Color(0xFFEBBC17),
                                        blurRadius: 8,
                                        offset: Offset(2, 2),
                                        spreadRadius: 0,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              // Add more cards here
                            ],
                          ),
                        ),
                        // SLIDER BULLETS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFEABC17),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                            // Add more bullets for additional cards
                          ],
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Positioned(
                          left: 44,
                          top: 315,
                          child: SizedBox(
                            width: 302,
                            height: 54,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  child: Container(
                                    width: 54,
                                    height: 54,
                                    decoration: const ShapeDecoration(
                                      color: Color(0xFFD9D9D9),
                                      shape: OvalBorder(),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 62,
                                  top: 0,
                                  child: Container(
                                    width: 54,
                                    height: 54,
                                    decoration: const ShapeDecoration(
                                      color: Color(0xFFD9D9D9),
                                      shape: OvalBorder(),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 124,
                                  top: 0,
                                  child: Container(
                                    width: 54,
                                    height: 54,
                                    decoration: const ShapeDecoration(
                                      color: Color(0xFFD9D9D9),
                                      shape: OvalBorder(),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 186,
                                  top: 0,
                                  child: Container(
                                    width: 54,
                                    height: 54,
                                    decoration: const ShapeDecoration(
                                      color: Color(0xFFD9D9D9),
                                      shape: OvalBorder(),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 248,
                                  top: 0,
                                  child: Container(
                                    width: 54,
                                    height: 54,
                                    decoration: const ShapeDecoration(
                                      color: Color(0xFFD9D9D9),
                                      shape: OvalBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // const SizedBox(height: 25),

                    // CATEGORIES
                    const Positioned(
                      // left: 20,
                      top: 380,
                      child: SizedBox(
                        width: 165,
                        height: 32,
                        child: Text(
                          'Categories',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Alata',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Positioned(
                          left: 43,
                          top: 410,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MakePayment()),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      primary: Colors.transparent,
                                    ),
                                    child: SizedBox(
                                      width: 58,
                                      height: 87,
                                      child: Stack(
                                        children: [
                                          //Button Shape
                                          Container(
                                            width: 58,
                                            height: 58,
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFFEABC17),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Transform.scale(
                                              scale:
                                                  0.7, // Adjust the scale factor according to your desired size
                                              child: Image.asset(
                                                'assets/images/contact.png',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),

                                          //Button Title
                                          const Positioned(
                                            left: 6,
                                            top: 63,
                                            child: SizedBox(
                                              width: 47,
                                              height: 24,
                                              child: Text(
                                                'Pay \nContacts',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontFamily: 'Alata',
                                                  fontWeight: FontWeight.w400,
                                                  height: 1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Add your button click logic here
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      primary: Colors.transparent,
                                    ),
                                    child: SizedBox(
                                      width: 58,
                                      height: 87,
                                      child: Stack(
                                        children: [
                                          //Button Shape
                                          Container(
                                            width: 58,
                                            height: 58,
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFFEABC17),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Transform.scale(
                                              scale:
                                                  0.8, // Adjust the scale factor according to your desired size
                                              child: Image.asset(
                                                'assets/images/electricity-bill.png',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),

                                          //Button Title
                                          const Positioned(
                                            left: 6,
                                            top: 63,
                                            child: SizedBox(
                                              width: 47,
                                              height: 24,
                                              child: Text(
                                                'Electricity',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontFamily: 'Alata',
                                                  fontWeight: FontWeight.w400,
                                                  height: 1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Add your button click logic here
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      primary: Colors.transparent,
                                    ),
                                    child: SizedBox(
                                      width: 58,
                                      height: 87,
                                      child: Stack(
                                        children: [
                                          //Button Shape
                                          Container(
                                            width: 58,
                                            height: 58,
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFFEABC17),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Transform.scale(
                                              scale:
                                                  0.6, // Adjust the scale factor according to your desired size
                                              child: Image.asset(
                                                'assets/images/broadband.png',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                          //Button Title
                                          const Positioned(
                                            left: 6,
                                            top: 63,
                                            child: SizedBox(
                                              width: 47,
                                              height: 24,
                                              child: Text(
                                                'Broadband',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontFamily: 'Alata',
                                                  fontWeight: FontWeight.w400,
                                                  height: 1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Add your button click logic here
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      primary: Colors.transparent,
                                    ),
                                    child: SizedBox(
                                      width: 58,
                                      height: 87,
                                      child: Stack(
                                        children: [
                                          //Button Shape
                                          Container(
                                            width: 58,
                                            height: 58,
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFFEABC17),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Transform.scale(
                                              scale:
                                                  0.7, // Adjust the scale factor according to your desired size
                                              child: Image.asset(
                                                'assets/images/smartphone-call.png',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                          //Button Title
                                          const Positioned(
                                            left: 6,
                                            top: 63,
                                            child: SizedBox(
                                              width: 47,
                                              height: 24,
                                              child: Text(
                                                'Mobile \n Recharge',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontFamily: 'Alata',
                                                  fontWeight: FontWeight.w400,
                                                  height: 1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // MAIN BUTTON
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Positioned(
                          left: 55,
                          top: 510,
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  primary: const Color(0xFFEABC17),
                                ),
                                child: SizedBox(
                                  width: 110,
                                  height: 110,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: Container(
                                          width: 110,
                                          height: 110,
                                          decoration: ShapeDecoration(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 21,
                                        top: 21,
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          decoration: ShapeDecoration(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Transform.scale(
                                            scale:
                                                0.9, // Adjust the scale factor according to your desired size
                                            child: Image.asset(
                                              'assets/images/balance.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 50),
                              ElevatedButton(
                                onPressed: () {
                                  // Add your onPressed logic here
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  primary: const Color(0xFFEABC17),
                                ),
                                child: SizedBox(
                                  width: 110,
                                  height: 110,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: Container(
                                          width: 110,
                                          height: 110,
                                          decoration: ShapeDecoration(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 21,
                                        top: 21,
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFFEABC17),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Transform.scale(
                                            scale:
                                                0.9, // Adjust the scale factor according to your desired size
                                            child: Image.asset(
                                              'assets/images/scan.png',
                                              fit: BoxFit.contain,
                                            ),
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
                      ],
                    ),

                    // Main Button Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Positioned(
                          left: 65,
                          top: 625,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                width: 100,
                                height: 15,
                                decoration: ShapeDecoration(
                                  color: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Check Balance',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontFamily: 'Alata',
                                      fontWeight: FontWeight.w400,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 55),
                              Container(
                                width: 100,
                                height: 15,
                                decoration: ShapeDecoration(
                                  color: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Scan QR',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontFamily: 'Alata',
                                      fontWeight: FontWeight.w400,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    // Mic  Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Positioned(
                          left: 48,
                          top: 650,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MakePaymentPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              primary: Colors.transparent,
                            ),
                            child: SizedBox(
                              width: 280,
                              height: 60,
                              child: Stack(
                                children: [
                                  //Button Shape
                                  Container(
                                    width: 280,
                                    height: 60,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFEABC17),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                    child: Transform.scale(
                                      scale:
                                          0.7, // Adjust the scale factor according to your desired size
                                      child: Image.asset(
                                        'assets/images/mic.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  //Button Title
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
