import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:social_media_app/view/widgets/alert_dialogue.dart';

class GetLocation {
  static Future getCurrentLocation(BuildContext context) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Dailgoue.alertdialgue(context);
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Request location permission
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever
        return 'Location permissions are permanently denied, we cannot request permissions.';
      }

      // Fetch current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocoding to get address
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];
      String formattedAddress = '${place.locality}, ${place.country}';
      return formattedAddress;
    } catch (e) {
      return "Error: $e";
    }
  }
}
