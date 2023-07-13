import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../auth/secrets.dart';

List<String> polyList = [];
bool internet = true;

// Future<List<String>> getPolylines(LatLng pickUp, LatLng drop) async {
//   polyList.clear();
//   String pickLat = '';
//   String pickLng = '';
//   String dropLat = '';
//   String dropLng = '';
//
//   pickLat = pickUp.latitude.toString();
//   pickLng = pickUp.longitude.toString();
//   dropLat = drop.latitude.toString();
//   dropLng = drop.longitude.toString();
//
//   try {
//     var response = await http.get(Uri.parse(
//         'https://maps.googleapis.com/maps/api/directions/json?origin=$pickLat%2C$pickLng&destination=$dropLat%2C$dropLng&avoid=ferries|indoor&transit_mode=bus&mode=driving&key='));
//     if (response.statusCode == 200) {
//       var steps =
//           jsonDecode(response.body)['routes'][0]['overview_polyline']['points'];
//       decodeEncodedPolyline(steps);
//     } else {
//       debugPrint(response.body);
//     }
//   } catch (e) {
//     if (e is SocketException) {
//       internet = false;
//     }
//   }
//   return polyList;
// }
var steps = "";

Future<String> getPolylines(LatLng pickUp, LatLng drop) async {
  polyList.clear();
  String pickLat = '';
  String pickLng = '';
  String dropLat = '';
  String dropLng = '';

  pickLat = pickUp.latitude.toString();
  pickLng = pickUp.longitude.toString();
  dropLat = drop.latitude.toString();
  dropLng = drop.longitude.toString();

  try {
    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=$pickLat%2C$pickLng&destination=$dropLat%2C$dropLng&avoid=ferries|indoor&transit_mode=bus&mode=driving&key=$mapsAPIKey'));
    if (response.statusCode == 200) {
      steps = jsonDecode(response.body)['routes'][0]['overview_polyline']['points'];
      // decodeEncodedPolyline(steps);
    } else {
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
  return steps;
}

Set<Polyline> polyline = {};

List<PointLatLng> decodeEncodedPolyline(String encoded) {
  List<PointLatLng> poly = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;
  polyline.clear();

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;
    LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
    String s = p.toString();
    polyList.add(s);
  }
  //
  // polyline.add(
  //   Polyline(
  //       polylineId: const PolylineId('1'),
  //       color: Colors.orange,
  //       visible: true,
  //       width: 4,
  //       points: polyList),
  // );

  return poly;
}

class PointLatLng {
  /// Creates a geographical location specified in degrees [latitude] and
  /// [longitude].
  ///
  const PointLatLng(double latitude, double longitude)
      // ignore: unnecessary_null_comparison
      : assert(latitude != null),
        // ignore: unnecessary_null_comparison
        assert(longitude != null),
        // ignore: unnecessary_this, prefer_initializing_formals
        this.latitude = latitude,
        // ignore: unnecessary_this, prefer_initializing_formals
        this.longitude = longitude;

  /// The latitude in degrees.
  final double latitude;

  /// The longitude in degrees
  final double longitude;

  @override
  String toString() {
    return "lat: $latitude / longitude: $longitude";
  }
}