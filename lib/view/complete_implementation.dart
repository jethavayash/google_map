import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps/view/page.dart';
import 'package:google_maps/view/readme_sample.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
class GoogleMapAll extends GoogleMapExampleAppPage {
  const GoogleMapAll({Key? key})
      : super(const Icon(Icons.account_circle_rounded), 'GoogleMapAll', key: key);

  @override
  Widget build(BuildContext context) {
    return const _GoogleMapAllWidget();
  }
}


class _GoogleMapAllWidget extends StatefulWidget {
  const _GoogleMapAllWidget();

  @override
  State<StatefulWidget> createState() => _GoogleMapAllWidgetState();
}
class _GoogleMapAllWidgetState extends State<_GoogleMapAllWidget> {
  _GoogleMapAllWidgetState();

  GoogleMapController? controller;

  Marker? _markerIcon;

  late BitmapDescriptor bitmapDescriptor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 200,
            ),
            ElevatedButton(
                onPressed: getPossition,
                child: const Text("get current location"))
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  void getPossition() async {
    var status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      Position datas = await _determinePosition();

      GetAddressFromLatLong(datas);
    }
  }

  //determind method
  Future<Position> _determinePosition() async {


    // Test if location services are enabled.
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
     // return Future.error('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> GetAddressFromLatLong(Position position) async {
    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    Placemark place = placemarks[0];
    var Address =
        '${place.street},${place.subLocality}, ${place.thoroughfare},${place.locality}, ${place.postalCode}, ${place.country}';
    print(Address);
    var lat = position.latitude;
    var lon = position.longitude;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => MapSample(latitude: lat, longitude: lon)));
  }
}

