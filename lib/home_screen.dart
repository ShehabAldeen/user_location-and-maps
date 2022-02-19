import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Location location = new Location();
  LocationData? _locationData;
  late Set<Marker> markers;
  var defLat = 30.0358;
  var defLon = 31.19908;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserLocation();
    markers = {
    };
  }

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(30.0358, 31.19908),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location'),
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: markers,
      ),
    );
  }

  void getUserLocation() async {
    var _serviceEnabled = await isServiceEnable();
    if (!_serviceEnabled) return;
    var _permissionGranted = await isPermissionGranted();
    if (!_permissionGranted) return;
    _locationData = await location.getLocation();
    location.onLocationChanged.listen((LocationData currentLocation) {
      _locationData = currentLocation;
      var marker =
      Marker(markerId: MarkerId('user location'),
          position: LatLng(_locationData?.latitude ?? defLat,
              _locationData?.longitude ?? defLon));
      markers.add(marker);
      animateCamera(_locationData?.latitude ?? defLat,
          _locationData?.longitude ?? defLon);
      setState(() {

      });
      print(_locationData?.altitude);
      print(_locationData?.longitude);
    });
  }

  Future<bool> isServiceEnable() async {
    bool _serviceEnabled;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }
    return _serviceEnabled;
  }

  Future<bool> isPermissionGranted() async {
    PermissionStatus _permissionGranted;
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
    }
    return _permissionGranted == PermissionStatus.granted;
  }

  void animateCamera(double lat, double lng) async {
    var cameraPosition = CameraPosition(target: LatLng(lat, lng), zoom: 14.5);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition));
  }

}
