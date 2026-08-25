import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationHelper {
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return null;
    } 

    return await Geolocator.getCurrentPosition();
  }

  static Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final geocoding = Geocoding();
      final placemarks = await geocoding.placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final name = place.subLocality != null && place.subLocality!.isNotEmpty ? place.subLocality : place.locality;
        final city = place.locality != null && place.locality!.isNotEmpty ? place.locality : place.administrativeArea;
        
        if (name != null && name.isNotEmpty && city != null && city.isNotEmpty) {
          return '$name, $city';
        } else if (city != null && city.isNotEmpty) {
          return city;
        } else if (name != null && name.isNotEmpty) {
          return name;
        }
      }
      return 'Current Location';
    } catch (e) {
      return 'Current Location';
    }
  }
}
