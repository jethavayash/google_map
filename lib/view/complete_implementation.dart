import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps/view/page.dart';

import 'dart:async';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapAll extends GoogleMapExampleAppPage {
  const GoogleMapAll({Key? key})
      : super(const Icon(Icons.account_circle_rounded), 'GoogleMapAll',
            key: key);

  @override
  Widget build(BuildContext context) {
    return _GoogleMapAllWidget();
  }
}

class _GoogleMapAllWidget extends StatefulWidget {
  _GoogleMapAllWidget();

  @override
  State<StatefulWidget> createState() => _GoogleMapAllWidgetState();
}

class _GoogleMapAllWidgetState extends State<_GoogleMapAllWidget> {
  _GoogleMapAllWidgetState();

  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(-33.852, 151.211),
    zoom: 11.0,
  );
  static const LatLng center = LatLng(-33.86711, 151.1947171);

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId? selectedMarker;
  int _markerIdCounter = 1;
  LatLng? markerPosition;
  CameraPosition _position = _kInitialPosition;
  bool _isMapCreated = false;
  final bool _isMoving = false;
  final bool _mapToolbarEnabled = true;
  final CameraTargetBounds _cameraTargetBounds = CameraTargetBounds.unbounded;
  final MinMaxZoomPreference _minMaxZoomPreference =
      MinMaxZoomPreference.unbounded;
  MapType _mapType = MapType.normal;
  final bool _rotateGesturesEnabled = true;
  final bool _scrollGesturesEnabled = true;
  final bool _tiltGesturesEnabled = true;
  final bool _zoomGesturesEnabled = true;
  bool _indoorViewEnabled = true;
  final bool _myLocationEnabled = true;
  bool _myTrafficEnabled = false;
  final bool _myLocationButtonEnabled = true;
  late GoogleMapController _controller;
  bool _nightMode = false;
  GoogleMapController? controller;
  LatLng? _lastTap;
  late BitmapDescriptor bitmapDescriptor;

  void _add() {
    final int markerCount = markers.length;

    if (markerCount == 12) {
      return;
    }

    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        center.latitude + sin(_markerIdCounter * pi / 6.0) / 20.0,
        center.longitude + cos(_markerIdCounter * pi / 6.0) / 20.0,
      ),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () => _onMarkerTapped(markerId),
      onDragEnd: (LatLng position) => _onMarkerDragEnd(markerId, position),
      onDrag: (LatLng position) => _onMarkerDrag(markerId, position),
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  Future<void> _onMarkerDrag(MarkerId markerId, LatLng newPosition) async {
    setState(() {
      markerPosition = newPosition;
    });
  }

  Future<void> _onMarkerDragEnd(MarkerId markerId, LatLng newPosition) async {
    final Marker? tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        markerPosition = null;
      });
      await showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
                content: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 66),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Old position: ${tappedMarker.position}'),
                        Text('New position: $newPosition'),
                      ],
                    )));
          });
    }
  }

  void _onMarkerTapped(MarkerId markerId) {
    final Marker? tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        final MarkerId? previousMarkerId = selectedMarker;
        if (previousMarkerId != null && markers.containsKey(previousMarkerId)) {
          final Marker resetOld = markers[previousMarkerId]!
              .copyWith(iconParam: BitmapDescriptor.defaultMarker);
          markers[previousMarkerId] = resetOld;
        }
        selectedMarker = markerId;
        final Marker newMarker = tappedMarker.copyWith(
          iconParam: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        );
        markers[markerId] = newMarker;

        markerPosition = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final GoogleMap googleMap = GoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: _kInitialPosition,
      mapToolbarEnabled: _mapToolbarEnabled,
      cameraTargetBounds: _cameraTargetBounds,
      minMaxZoomPreference: _minMaxZoomPreference,
      mapType: _mapType,
      onTap: (LatLng pos) {
        setState(() {
          _lastTap = pos;
        });
      },
      markers: Set<Marker>.of(markers.values),
      rotateGesturesEnabled: _rotateGesturesEnabled,
      scrollGesturesEnabled: _scrollGesturesEnabled,
      tiltGesturesEnabled: _tiltGesturesEnabled,
      zoomGesturesEnabled: _zoomGesturesEnabled,
      zoomControlsEnabled: true,
      indoorViewEnabled: _indoorViewEnabled,
      myLocationEnabled: _myLocationEnabled,
      myLocationButtonEnabled: _myLocationButtonEnabled,
      trafficEnabled: _myTrafficEnabled,
      onCameraMove: _updateCameraPosition,
    );

    final List<Widget> columnChildren = <Widget>[
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.sizeOf(context).height / 1.3,
            child: googleMap,
          ),
        ),
      ),
    ];

    if (_isMapCreated) {
      columnChildren.add(
        Expanded(
          child: ListView(
            children: <Widget>[
              Text('camera bearing: ${_position.bearing}'),
              Text(
                  'camera target: ${_position.target.latitude.toStringAsFixed(4)},'
                  '${_position.target.longitude.toStringAsFixed(4)}'),
              Text('camera zoom: ${_position.zoom}'),
              Text('camera tilt: ${_position.tilt}'),
              Text(_isMoving ? '(Camera moving)' : '(Camera idle)'),
              _mapTypeCycler(),
              _indoorViewToggler(),
              _myTrafficToggler(),
              _nightModeToggler(),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: columnChildren,
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  // void getPossition() async {
  //   var status = await Permission.location.request();
  //   if (status == PermissionStatus.granted) {
  //     Position datas = await _determinePosition();
  //
  //     GetAddressFromLatLong(datas);
  //   }
  // }
  //
  // //determind method
  // Future<Position> _determinePosition() async {
  //
  //
  //   // Test if location services are enabled.
  //   var serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //    // return Future.error('Location services are disabled.');
  //   }
  //
  //   var permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return Future.error('Location permissions are denied');
  //     }
  //   }
  //
  //   if (permission == LocationPermission.deniedForever) {
  //     // Permissions are denied forever, handle appropriately.
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }
  //   return await Geolocator.getCurrentPosition();
  // }
  //
  // Future<void> GetAddressFromLatLong(Position position) async {
  //   List<Placemark> placemarks =
  //   await placemarkFromCoordinates(position.latitude, position.longitude);
  //   print(placemarks);
  //   Placemark place = placemarks[0];
  //   var Address =
  //       '${place.street},${place.subLocality}, ${place.thoroughfare},${place.locality}, ${place.postalCode}, ${place.country}';
  //   print(Address);
  //   var lat = position.latitude;
  //   var lon = position.longitude;
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (_) => MapSample(latitude: lat, longitude: lon)));
  // }
  //

  void _updateCameraPosition(CameraPosition position) {
    setState(() {
      _position = position;
    });
  }

  void onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
      _isMapCreated = true;
    });
  }

  Widget _mapTypeCycler() {
    final MapType nextType =
        MapType.values[(_mapType.index + 1) % MapType.values.length];
    return TextButton(
      child: Text('change map type to $nextType'),
      onPressed: () {
        setState(() {
          _mapType = nextType;
        });
      },
    );
  }

  Widget _indoorViewToggler() {
    return TextButton(
      child: Icon(Icons.camera_indoor_outlined,
          color: _indoorViewEnabled ? Colors.deepPurpleAccent : Colors.orange),
      // child: Text('${_indoorViewEnabled ? 'disable' : 'enable'} indoor'),
      onPressed: () {
        setState(() {
          _indoorViewEnabled = !_indoorViewEnabled;
        });
      },
    );
  }

  Widget _myTrafficToggler() {
    return TextButton(
      child: Icon(
        Icons.traffic_outlined,
        color: _myTrafficEnabled ? Colors.indigo : Colors.yellow,
      ),
      // child: Text('${_myTrafficEnabled ? 'disable' : 'enable'} my traffic'),
      onPressed: () {
        setState(() {
          _myTrafficEnabled = !_myTrafficEnabled;
        });
      },
    );
  }

  Future<String> _getFileData(String path) async {
    return rootBundle.loadString(path);
  }

  void _setMapStyle(String mapStyle) {
    setState(() {
      _nightMode = true;
      _controller.setMapStyle(mapStyle);
    });
  }

  // Should only be called if _isMapCreated is true.
  Widget _nightModeToggler() {
    assert(_isMapCreated);
    return TextButton(
      child: Icon(
        Icons.nightlight_outlined,
        color: _nightMode ? Colors.indigo : Colors.black38,
      ),
      // child: Text('${_nightMode ? 'disable' : 'enable'} night mode'),
      onPressed: () {
        if (_nightMode) {
          setState(() {
            _nightMode = false;
            _controller.setMapStyle(null);
          });
        } else {
          _getFileData('assets/night_mode.json').then(_setMapStyle);
        }
      },
    );
  }
}
