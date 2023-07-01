import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ndteg/main.dart';
import 'package:ndteg/pages/principal2.dart';
import 'dart:ui' as ui;

import 'dart:async';
import 'package:geolocator/geolocator.dart';

import '../widgets/widgets.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  PageController pageController = PageController();
  double pageIndex = 0.0;
  List imagesPath = [
    {
      "img": "omb1.jpg",
      "title": "Titre",
      "description": "Description",
    },
    {
      "img": "omb2.jpg",
      "title": "Titre",
      "description": "Description",
    },
    {
      "img": "omb3.jpg",
      "title": "Titre",
      "description": "Description",
    },
    {
      "img": "omb4.jpg",
      "title": "Titre",
      "description": "Description",
    },
  ];
  Future loadImage() async {
    for (var i = 0; i < imagesPath.length - 1; i++) {
      await ombImg.load(imagesPath[i]["img"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        body: Stack(
          children: [
            PageView.builder(
              controller: pageController,
              itemCount: imagesPath.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return FutureBuilder(
                    future: loadImage(),
                    builder: (context, snapshot) {
                      return FutureBuilder(
                          future: ombImg.load(imagesPath[index]["img"]),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              snapshot.data;
                              ui.Image image = snapshot.data!;
                              return Stack(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    child: RawImage(
                                      image: image,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    bottom:
                                        MediaQuery.of(context).size.height / 2,
                                    child: IntrinsicHeight(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              imagesPath[index]["title"],
                                              style: const TextStyle(
                                                fontSize: 34,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              imagesPath[index]["description"],
                                              style: const TextStyle(
                                                fontSize: 21,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          });
                    });
              },
            ),
            Positioned(
              top: kToolbarHeight,
              left: 10,
              child: Image.asset(
                "assets/logo/500x500.png",
                width: 80,
              ),
            ),
            Positioned(
              bottom: 40,
              left: (MediaQuery.of(context).size.width / 2) - 50,
              child: Row(
                children: [
                  dotSlider(isActive: pageIndex == 0.0),
                  dotSlider(isActive: pageIndex == 1.0),
                  dotSlider(isActive: pageIndex == 2.0),
                  dotSlider(isActive: pageIndex == 3.0),
                ],
              ),
            ),
            Positioned(
              top: kToolbarHeight,
              right: 20,
              child: Card(
                color: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onTap: () async {
                    if (pageController.page == (imagesPath.length - 1)) {
                      Position position = await getCurrentLocation();
                      nextScreenReplace(
                          context,
                          AreaListWidget(
                            position: position,
                          ));
                    }

                    await pageController.nextPage(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut);
                    setState(() {
                      pageIndex = pageController.page ?? 0;
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: const Text(
                          "Skip",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Icon(
                        Icons.double_arrow_sharp,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Position> getCurrentLocation() async {
  LocationPermission permission;
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error("Location permissions are denied");
    }
  }
  var position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  return position;
}

Widget dotSlider({bool isActive = false}) {
  return Card(
    color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
    clipBehavior: Clip.hardEdge,
    child: Container(
      width: 15,
      height: 15,
    ),
  );
}
