// import 'package:location/location.dart';

// class LocationServices {
//   Location location = Location();
//   late LocationData _locDat;

//   Future<void> initialize() async {
//     bool _serviceEnabled;
//     PermissionStatus _permissionStatus;
//     _serviceEnabled = await location.serviceEnabled();
//     if (!_serviceEnabled) {
//       _serviceEnabled = await location.requestService();
//       if (!_serviceEnabled) {
//         return;
//       }
//     }

//     _permissionStatus = await location.hasPermission();
//     if (_permissionStatus == PermissionStatus.denied) {
//       _permissionStatus = await location.requestPermission();
//       if (_permissionStatus != PermissionStatus.granted) {
//         return;
//       }
//     }
//   }

//   Future<double?> getLatitude() async {
//     _locDat = await location.getLocation();
//     return _locDat.latitude;
//   }

//   Future<double?> getLongitude() async {
//     _locDat = await location.getLocation();
//     return _locDat.longitude;
//   }
// }
