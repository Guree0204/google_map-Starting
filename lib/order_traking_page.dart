import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_mao/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  /*static const LatLng sourceLocation = LatLng(47.91819711724435, 106.9489378122824);  //jukow
  static const LatLng destination = LatLng(47.91614785651043, 106.97192431228227);  //Ofitser*/
  static const LatLng sourceLocation = LatLng(37.33500926, -122.03272188);
  static const LatLng destination = LatLng(37.33429383, -122.06600055);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  void getCurrentLocation () async{
    Location location = Location();


    location.getLocation().then(
      (location) {
        currentLocation = location;
      },
    );

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = newLoc;

        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 14,
              target: LatLng(
                newLoc.latitude!,
                newLoc.longitude!,
              )),
            
          ),
        );

        setState(() {}); 
      },
    );
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    google_api_key,
    PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
    PointLatLng(destination.latitude, destination.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude)
        ),
      );
      setState(() {
      });
    }
  }

  // void setCustomMarkerIcon(){
  //   BitmapDescriptor.fromAssetImage(configuration, assetName)
  // }

  @override
  void initState() {
    getCurrentLocation();
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Map test",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: currentLocation == null
        ? const Center(child: Text("Loading..."))
        : GoogleMap(
          initialCameraPosition: CameraPosition(
            target: sourceLocation, 
            zoom: 15,
          ),
          polylines: {
            Polyline(
              polylineId: PolylineId("route"),
              points: polylineCoordinates,
              color: primaryColor,
              width: 6,
            ),
          }, 
          markers: {
            const Marker(markerId: MarkerId("source"),
            //icon: currentLocationIcon,
            position: sourceLocation,
            ),
            const Marker(markerId: MarkerId("destination"),
            position: destination,
            )
          },
          onMapCreated: (mapController) {
            _controller.complete(mapController);
          },
        ),
    );
  }
}
