 import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LocationData? _currentLocation;
  final Location _location = Location();
  Marker? _marker;
  final List<LatLng> _polylinePoints = [];

  static const LatLng _initialLocation = LatLng(30.87605680, 29.74260400);

  Future<void> _getLocation() async {
    try {
      final LocationData locationData = await _location.getLocation();
      _handleLocationUpdate(locationData);
      _location.onLocationChanged.listen((newLocation) {
        _handleLocationUpdate(newLocation);
        _addPolylinePoint(newLocation);
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _handleLocationUpdate(LocationData newLocation) {
    setState(() {
      _currentLocation = newLocation;
      _marker = Marker(
        markerId: const MarkerId('currentLocation'),
        position: LatLng(
          _currentLocation!.latitude!,
          _currentLocation!.longitude!,
        ),
      );
    });
  }

  void _addPolylinePoint(LocationData newLocation) {
    setState(() {
      _polylinePoints.add(LatLng(
        newLocation.latitude!,
        newLocation.longitude!,
      ));
    });
  }

  Future<void> _requestLocationPermission() async {
    if (await _location.hasPermission() == PermissionStatus.granted) {
      await _getLocation();
    } else {
      if (await _location.requestPermission() == PermissionStatus.granted) {
        await _getLocation();
      } else {
        print('Location permission denied');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
      ),
      body: _currentLocation == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentLocation!.latitude!,
                  _currentLocation!.longitude!,
                ),
                zoom: 16,
              ),
              markers: _marker != null ? {_marker!} : {},
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  color: Colors.blue,
                  width: 5,
                  points: _polylinePoints,
                ),
              },
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
    );
  }
}







 
