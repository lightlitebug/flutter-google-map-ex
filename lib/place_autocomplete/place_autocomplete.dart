import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

import 'package:example/services/google_map_service.dart';
import 'package:example/models/place.dart';

class PlaceAutocomplete extends StatefulWidget {
  @override
  _PlaceAutocompleteState createState() => _PlaceAutocompleteState();
}

class _PlaceAutocompleteState extends State<PlaceAutocomplete> {
  final TextEditingController _searchController = TextEditingController();
  var uuid = Uuid();
  var sessionToken;
  var googleMapServices;
  PlaceDetail placeDetail;
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set();

  @override
  void initState() {
    super.initState();
    _markers.add(Marker(
      markerId: MarkerId('myInitialPostion'),
      position: LatLng(37.382782, 127.1189054),
      infoWindow: InfoWindow(title: 'My Position', snippet: 'Where am I?'),
    ));
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
