import 'package:flutter/material.dart';
import 'package:ndteg/main.dart';
import 'package:ndteg/pages/onboarding.dart';
import 'principal2.dart';
import '../widgets/widgets.dart';
import 'dart:async';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    //This is to define the number of seconds for this first page befor opening the next page.
    Timer(const Duration(seconds: 4), () {
      // I defined 4 seconds. You can modify
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                    height:
                        40), //This widget defines a free space. Used to space between other widgets.
                Image.asset(
                    "assets/image11.png"), //The image used for the welcome page, you can upload yours in assets/
                const SizedBox(height: 60),
                Text(
                  "PVwermap",
                  style: TextStyle(
                      fontSize: 40, //The title used with it styles
                      fontWeight: FontWeight.bold,
                      color: mainColor),
                ),
                const SizedBox(height: 50),
                // const Text(
                //   "This is a test app", //the subtitle
                //   style: TextStyle(
                //       fontSize: 16,
                //       fontWeight: FontWeight.bold,
                //       color: Color(0xFFee7b64),
                //       fontStyle: FontStyle.italic),
                // ),

                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//This is the home page, you can create another file and place this part of the code inside. To seperate things
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 100),
              Expanded(
                  child: Image.asset(
                      "assets/image11.png")), //Still used the same image
              const SizedBox(height: 60),
              // const Text.rich(TextSpan(
              //     text: "This is a test app",
              //     style: TextStyle(
              //         color: Color(0xFFee7b64),
              //         fontSize: 16,
              //         fontWeight: FontWeight.bold))),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 26, 29, 37),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  child: const Text(
                    "GO",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: () {
                    //nextScreen(context, const Principal());
                    // nextScreen(context,
                    //     const AreaListWidget());
                    nextScreenReplace(context, Onboarding());
                    //// The onPressed property such that when the user presses on "GO", it opens the class named AreaListWidget found in the principal2.dart file.
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
