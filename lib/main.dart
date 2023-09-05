// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_maps/view/complete_implementation.dart';
import 'package:google_maps/view/padding.dart';
import 'package:google_maps/view/track.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps/view/export.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

final List<GoogleMapExampleAppPage> _allPages = <GoogleMapExampleAppPage>[
  const GoogleMapAll(),
  const TrackPage(),
  const MapUiPage(),
  const MapCoordinatesPage(),
  const MapClickPage(),
  const AnimateCameraPage(),
  const MoveCameraPage(),
  const PlaceMarkerPage(),
  const MarkerIconsPage(),
  const ScrollingMapPage(),//
  const PlacePolylinePage(),//
  const PlacePolygonPage(),
  const PlaceCirclePage(),//
  const PaddingPage(),
  const SnapshotPage(),
  const LiteModePage(),
  const TileOverlayPage(),
];

void main() {
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
  }
  runApp(const MaterialApp(home: MapsDemo()));
}

/// MapsDemo is the Main Application.
class MapsDemo extends StatelessWidget {
  /// Default Constructor
  const MapsDemo({super.key});

  void _pushPage(BuildContext context, GoogleMapExampleAppPage page) {
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => Scaffold(
              appBar: AppBar(title: Text(page.title)),
              body: page,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GoogleMaps examples')),
      body: ListView.builder(
        itemCount: _allPages.length,
        itemBuilder: (_, int index) => ListTile(
          leading: _allPages[index].leading,
          title: Text(_allPages[index].title),
          onTap: () => _pushPage(context, _allPages[index]),
        ),
      ),
    );
  }
}
