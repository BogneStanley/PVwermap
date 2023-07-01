import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ndteg/main.dart';
import '../firebase_options.dart';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';

import 'itineraryPage.dart';

//Created this class for storage of different areas with their respective postions.
class Divine {
  final String name;
  final LatLng position;
  final int id;
  final double level;
  final int numberOfUser;
  final int total;
  final String ville;

  Divine({
    required this.name,
    required this.position,
    required this.id,
    required this.level,
    required this.numberOfUser,
    required this.total,
    required this.ville,
  }); //Constructor of the class
}

class AreaListWidget extends StatefulWidget {
  const AreaListWidget({super.key, required this.position});
  final Position position;

  @override
  _AreaListWidgetState createState() => _AreaListWidgetState();
}

class DirectionsRepository {
  static const _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';
  final _httpClient = http.Client();
}

class _AreaListWidgetState extends State<AreaListWidget> {
  //Function to get user's location
  Position? userLocation;
  late Uint8List mapIcon;
  getPosition() async {
    Position userLocation1 = widget.position;
    setState(() {
      userLocation = userLocation1;
    });
  }

  Future<Position> _getCurrentLocation() async {
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

  //This is to convert the user's position which is of type 'Position' to that of a type 'LatLng' since we'll be using GoogleMaps API
  LatLng get userLocation1 =>
      LatLng(userLocation?.latitude ?? 0.0, userLocation?.longitude ?? 0.0);

  //Here we create 5 objects of the class Divine and instantiate them. We parsed in the positions as LatLng types. The 'const' keyword is to improve efficiency
  // Divine soneco =
  //     Divine("SONECO OMNISPORT", const LatLng(3.8867360, 11.5371097));
  // Divine poste = Divine("Poste Centrale", const LatLng(3.8607609, 11.5204052));
  // Divine chateau =
  //     Divine("Chateau Ngoa Ekele", const LatLng(3.856627, 11.503873));
  // Divine vogt = Divine("Prepa Vogt", const LatLng(3.8414472, 11.4996355));
  // Divine damas = Divine("Rond Point Damas", const LatLng(3.816084, 11.489263));

  //We create an object mapController from Googlemap, this will help us for the control of our map
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  // final Set<Polyline> _polylines = {};
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? googleMapController;
  @override
  void initState() {
    super.initState();
    initialLoading();
  }

  Future<void> onMapCreated(GoogleMapController controller) async {
    googleMapController = controller;
    List mapStyle = [
      {
        "featureType": "poi",
        "stylers": [
          {"visibility": "off"}
        ]
      }
    ];
    await googleMapController?.setMapStyle(jsonEncode(mapStyle));

    googleMapController!
        .animateCamera(CameraUpdate.newLatLngZoom(userLocation1, 12.0));
  }

  Future initialLoading() async {
    mapIcon = await getBytesFromAsset("assets/eclat.png", 85);
    await getPosition();
  }

  @override
  Widget build(BuildContext context) {
    //Here we create a list that contains the 5 Divine's object we created. Later on we'll iterate over this list to print each element
    // final List<Divine> items = [soneco, poste, chateau, vogt, damas];
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: mainColor,
          // actions: [
          //   IconButton(
          //       onPressed: () {}, icon: const Icon(Icons.refresh_rounded)),
          // ],
          title: Text(
            "PVwermap",
            style: GoogleFonts.poppins(
              fontSize: 24,
            ),
            // style: TextStyle(
            //   color: Colors.white,
            //   fontSize: 27,
            //   fontWeight: FontWeight.bold,

            // ),
          ),
        ),
        // drawer: Drawer(
        //   child: ListView(
        //     padding: const EdgeInsets.symmetric(vertical: 50),
        //     children: const <Widget>[],
        //   ),
        // ),
        body: StreamBuilder(
            stream: getFire(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print("=====================================================");

                //fb == firebase
                List fbDate = (snapshot.data?.snapshot.value ?? []) as List;
                List<Divine> filterFbData = [];
                for (var element in fbDate) {
                  if (!(element == null)) {
                    filterFbData.add(Divine(
                      name: element["name"],
                      position: LatLng(element["lat"], element["lon"]),
                      id: element["id"],
                      level: double.parse(element["level"].toString()),
                      numberOfUser: element["number_of_user"],
                      total: element["total"],
                      ville: element["ville"],
                    ));
                  }
                  ;
                }
                print(filterFbData);
                return DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      Material(
                        child: Container(
                          height: 80,
                          color: Colors.white,
                          child: TabBar(
                            isScrollable: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 20),
                            unselectedLabelColor: mainColor.withOpacity(1),
                            indicatorSize: TabBarIndicatorSize.label,
                            indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: mainColor),
                            tabs: [
                              Tab(
                                child: Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border:
                                        Border.all(color: mainColor, width: 1),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "MAP VIEW",
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ),
                                ),
                              ),
                              Tab(
                                child: Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border:
                                        Border.all(color: mainColor, width: 1),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "LIST VIEW",
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            GoogleMap(
                              onMapCreated: onMapCreated,
                              initialCameraPosition: CameraPosition(
                                target: userLocation1,
                                zoom: 11,
                              ),
                              markers: {
                                Marker(
                                  markerId: const MarkerId("source"),
                                  position: userLocation1,
                                  icon: BitmapDescriptor.defaultMarker,
                                ),
                                ...filterFbData
                                    .map(
                                      (e) => Marker(
                                        markerId: MarkerId(e.name),
                                        position: e.position,
                                        icon:
                                            BitmapDescriptor.fromBytes(mapIcon),
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) {
                                              return Card(
                                                elevation: 0,
                                                margin: const EdgeInsets.all(0),
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    topRight:
                                                        Radius.circular(20),
                                                  ),
                                                ),
                                                clipBehavior: Clip.hardEdge,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    topRight:
                                                        Radius.circular(20),
                                                  ),
                                                  clipBehavior: Clip.hardEdge,
                                                  child: Container(
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(
                                                          height: 60,
                                                        ),
                                                        Text.rich(
                                                          TextSpan(
                                                            text: '${e.name}  ',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 60,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            Container(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const Text(
                                                                    "Totals",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18),
                                                                  ),
                                                                  Text(
                                                                    e.total
                                                                        .toString(),
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          35,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            Container(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const Text(
                                                                    "Utiliisées",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18),
                                                                  ),
                                                                  Text(
                                                                    e.numberOfUser
                                                                        .toString(),
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontSize:
                                                                          35,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            Container(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const Text(
                                                                    "Disponible",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18),
                                                                  ),
                                                                  Text(
                                                                    (e.total -
                                                                            e.numberOfUser)
                                                                        .toString(),
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .green,
                                                                      fontSize:
                                                                          35,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                horizontal: 20,
                                                                vertical: 20,
                                                              ),
                                                              child: Text(
                                                                "Ville : ${e.ville}",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Stack(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(20),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                                child:
                                                                    Container(
                                                                  width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                                  height: 70,
                                                                  color: Colors
                                                                      .grey,
                                                                  child:
                                                                      Container(
                                                                    height: 70,
                                                                    width: 100,
                                                                    color: Colors
                                                                        .green,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Center(
                                                              child: Text(
                                                                e.level.toString() +
                                                                    '%',
                                                                textScaleFactor:
                                                                    1.3,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    )
                                    .toList(),
                              },
                            ),
                            ListView.builder(
                              itemCount: filterFbData.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ItineraryPage(
                                            item: filterFbData[index],
                                            position: userLocation1),
                                      ),
                                    );
                                  },
                                  title: Text(filterFbData[index].name),
                                  subtitle: FutureBuilder(
                                      future: _getCurrentLocation(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          double? distance =
                                              snapshot.data != null
                                                  ? calculateDistance(
                                                      snapshot.data?.latitude,
                                                      snapshot.data?.longitude,
                                                      filterFbData[index]
                                                          .position
                                                          .latitude,
                                                      filterFbData[index]
                                                          .position
                                                          .longitude,
                                                    )
                                                  : null;
                                          return Text(
                                              'Distance: ${distance?.toStringAsFixed(3)} Km');
                                        } else {
                                          return const Text('Distance: ... Km');
                                        }
                                      }),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return Container();
              } else {
                print('${snapshot.data}test');
                return const Center(
                  child: CircularProgressIndicator(
                    color: const Color(0xFFee7b64),
                  ),
                );
              }
            }));
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Stream<DatabaseEvent> getFire() async* {
    FirebaseApp firebaseApp = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseDatabase database = FirebaseDatabase.instanceFor(
        app: firebaseApp,
        databaseURL: "https://harmonie-dd48c-default-rtdb.firebaseio.com/");
    DatabaseReference ref = database.ref("rechargePost");
    yield* ref.onValue;
  }
}

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return (12742 * asin(sqrt(a)));
}
