import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:ndteg/main.dart';
import 'principal2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../widgets/widgets.dart';

const String google_api_key = "AIzaSyA2Skn4Y8r7R3Yi7rpvJNarP-FnnX8CrAg";

class DirectionsRepository {
  static const _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';
  final _httpClient = http.Client();
}

class ItineraryPage extends StatefulWidget {
  final LatLng position;
  final Divine item;

  const ItineraryPage({Key? key, required this.item, required this.position})
      : super(key: key);

  @override
  State<ItineraryPage> createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  final Completer<GoogleMapController> _controller = Completer();

  List<LatLng> polylineCoordinates = [];

  void getPolypoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(widget.position.latitude, widget.position.longitude),
      PointLatLng(
          widget.item.position.latitude, widget.item.position.longitude),
    );
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) =>
            polylineCoordinates.add(LatLng(point.latitude, point.longitude)),
      );
      setState(() {});
    }
  }

  @override
  void initState() {
    //getCurrentLocation1();
    getPolypoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: mainColor,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh_rounded)),
        ],
        title: Text(
          widget.item.name,
          style: const TextStyle(
              color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
        ),
      ),
      body: GoogleMap(
        // onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: widget.position,
          zoom: 15.5,
        ),
        polylines: {
          Polyline(
            polylineId: const PolylineId("route"),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 6,
          ),
        }, //markers: _markers,
        markers: {
          // Marker(
          //   markerId: MarkerId("currentLocation"),
          //   position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          // ),
          Marker(
            markerId: const MarkerId("source"),
            position: widget.position,
            icon: BitmapDescriptor.defaultMarker,
          ),
          Marker(
            markerId: const MarkerId("destination"),
            position: widget.item.position,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
          ),
        },
      ),
    );
  }
}
