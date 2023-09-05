import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps/view/page.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class TrackPage extends GoogleMapExampleAppPage {
  const TrackPage({Key? key})
      : super(const Icon(Icons.label_important_outlined), 'Track page', key: key);

  @override
  Widget build(BuildContext context) {
    return const _TrackingWidget();
  }
}


class _TrackingWidget extends StatefulWidget {
  const _TrackingWidget({super.key});

  @override
  State<StatefulWidget> createState() => _TrackingWidgetState();
}

class _TrackingWidgetState extends State<_TrackingWidget> {
  _TrackingWidgetState();

  var location = Location();
  GoogleMapController? controller;
  LocationData? userCurrentLocation;
  Marker? _markerIcon;

  late BitmapDescriptor bitmapDescriptor;
  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  checkPermission() async {
    bitmapDescriptor = await _createMarkerImageFromAsset();
    var isEnabled = await location.serviceEnabled();
    if (!isEnabled) {
      var isEnabledRequest = await location.requestService();
      if (!isEnabledRequest) {
        return;
      }
    }

    var result = await location.hasPermission();
    if (result == PermissionStatus.granted) {
      userCurrentLocation = await location.getLocation();
      if (!(await location.isBackgroundModeEnabled())) {
        location.enableBackgroundMode();
      }
      location.onLocationChanged.listen((event) {
        userCurrentLocation = event;
        print(event);
        if (controller != null) {
          _markerIcon = Marker(
              markerId: MarkerId("123"),
              position: LatLng(userCurrentLocation?.latitude ?? 0.0,
                  userCurrentLocation?.longitude ?? 0.0),
              icon: bitmapDescriptor);
          controller!.animateCamera(CameraUpdate.newLatLng(LatLng(
              userCurrentLocation?.latitude ?? 0.0,
              userCurrentLocation?.longitude ?? 0.0)));
        }
      });
      location.changeNotificationOptions(
          title: "Live Tracking",
          description: "Live Tracking Foreground",
          subtitle: "Live Tracking Foreground");
    } else {
      location.requestPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GoogleMap(
          markers: _markerIcon != null ? {_markerIcon!} : {},
          initialCameraPosition: CameraPosition(
              target: LatLng(userCurrentLocation?.latitude ?? 0.0,
                  userCurrentLocation?.longitude ?? 0.0),
              zoom: 30),
          onMapCreated: (GoogleMapController _controller) {
            controller = _controller;
          },
        ));
  }

  Future<BitmapDescriptor> _createMarkerImageFromAsset() async {
    final ImageConfiguration imageConfiguration =
    createLocalImageConfiguration(context, size: const Size.square(48));
    return BitmapDescriptor.fromAssetImage(
        imageConfiguration, 'assets/red_square.png');
  }
}