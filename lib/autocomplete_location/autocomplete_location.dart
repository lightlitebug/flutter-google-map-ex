import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

import 'package:example/services/google_map_service.dart';
import 'package:example/models/place.dart';

class AutocompleteLocation extends StatefulWidget {
  @override
  _AutocompleteLocationState createState() => _AutocompleteLocationState();
}

class _AutocompleteLocationState extends State<AutocompleteLocation> {
  final TextEditingController _searchController = TextEditingController();
  var uuid = Uuid();
  var sessionToken;
  var googleMapServices;
  PlaceDetail placeDetail;
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set();

  Position position;
  double distance = 0.0;
  String myAddr = '';

  @override
  void initState() {
    super.initState();
    _checkGPSAvailability();
  }

  void _checkGPSAvailability() async {
    GeolocationStatus geolocationStatus =
        await Geolocator().checkGeolocationPermissionStatus();
    print(geolocationStatus);

    if (geolocationStatus != GeolocationStatus.granted) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('GPS 사용 불가'),
            content: Text('GPS 사용 불가로 앱을 사용할 수 없습니다'),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(ctx);
                },
              ),
            ],
          );
        },
      ).then((_) => Navigator.pop(context));
    } else {
      await _getGPSLocation();
      myAddr = await GoogleMapServices.getAddrFromLocation(
          position.latitude, position.longitude);
      _setMyLocation();
    }
  }

  Future<void> _getGPSLocation() async {
    position = await Geolocator().getCurrentPosition();
    print('latitude: ${position.latitude}, longitude: ${position.longitude}');
  }

  void _setMyLocation() {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId('myInitialPostion'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: InfoWindow(title: '내 위치', snippet: myAddr),
      ));
    });
  }

  void _moveCamera() async {
    if (_markers.length > 0) {
      setState(() {
        _markers.clear();
      });
    }

    GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(placeDetail.lat, placeDetail.lng),
      ),
    );

    await _getGPSLocation();
    myAddr = await GoogleMapServices.getAddrFromLocation(
        position.latitude, position.longitude);

    distance = await Geolocator().distanceBetween(position.latitude,
        position.longitude, placeDetail.lat, placeDetail.lng);

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(placeDetail.placeId),
          position: LatLng(placeDetail.lat, placeDetail.lng),
          infoWindow: InfoWindow(
            title: placeDetail.name,
            snippet: placeDetail.formattedAddress,
          ),
        ),
      );
    });
  }

  Widget _showPlaceInfo() {
    if (placeDetail == null) {
      return Container();
    }
    return Container(
      child: Column(
        children: <Widget>[
          Card(
            child: ListTile(
              title: Text('내 위치: $myAddr - ${placeDetail.name}'),
              subtitle: Text('${distance.toStringAsFixed(2)} m'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.branding_watermark),
              title: Text('${placeDetail.name}'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.location_city),
              title: Text('${placeDetail.formattedAddress}'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.phone),
              title: Text('${placeDetail.formattedPhoneNumber}'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.favorite),
              title: Text('${placeDetail.rating}'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.place),
              title: Text('${placeDetail.vicinity}'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.web),
              title: Text('${placeDetail.website}'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Places Autocomplete'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 32.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 45.0,
                child: Image.asset('assets/images/powered_by_google.png'),
              ),
              TypeAheadField(
                debounceDuration: Duration(milliseconds: 500),
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Search places...'),
                ),
                suggestionsCallback: (pattern) async {
                  if (sessionToken == null) {
                    sessionToken = uuid.v4();
                  }

                  googleMapServices =
                      GoogleMapServices(sessionToken: sessionToken);

                  return await googleMapServices.getSuggestions(pattern);
                },
                itemBuilder: (context, suggetion) {
                  return ListTile(
                    title: Text(suggetion.description),
                    subtitle: Text('${suggetion.placeId}'),
                  );
                },
                onSuggestionSelected: (suggetion) async {
                  placeDetail = await googleMapServices.getPlaceDetail(
                    suggetion.placeId,
                    sessionToken,
                  );
                  sessionToken = null;
                  _moveCamera();
                },
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 350,
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      37.382782,
                      127.118905,
                    ),
                    zoom: 14,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  myLocationEnabled: true,
                  markers: _markers,
                ),
              ),
              SizedBox(height: 20),
              _showPlaceInfo(),
            ],
          ),
        ),
      ),
    );
  }
}
