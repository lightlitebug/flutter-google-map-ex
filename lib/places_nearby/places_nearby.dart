import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:http/http.dart' as http;

import 'package:example/constants/constants.dart';

class PlacesNearby extends StatefulWidget {
  @override
  State<PlacesNearby> createState() => PlacesNearbyState();
}

class PlacesNearbyState extends State<PlacesNearby> {
  Completer<GoogleMapController> _controller = Completer();
  MapType _googleMapType = MapType.normal;
  int _mapType = 0;
  Set<Marker> _markers = Set();
  GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    _markers.add(
      Marker(
        markerId: MarkerId('myInitialPostion'),
        position: LatLng(37.382782, 127.1189054),
        infoWindow: InfoWindow(title: 'My Position', snippet: 'Where am I?'),
      ),
    );
  }

  CameraPosition _initialCameraPostion = CameraPosition(
    target: LatLng(37.382782, 127.1189054),
    zoom: 14,
  );

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _changeMapType() {
    setState(() {
      _mapType++;
      _mapType = _mapType % 4;

      switch (_mapType) {
        case 0:
          _googleMapType = MapType.normal;
          break;
        case 1:
          _googleMapType = MapType.satellite;
          break;
        case 2:
          _googleMapType = MapType.terrain;
          break;
        case 3:
          _googleMapType = MapType.hybrid;
          break;
        default:
          _googleMapType = MapType.normal;
          break;
      }
    });
  }

  void _searchPlaces(
    String locationName,
    double latitude,
    double longitude,
  ) async {
    setState(() {
      _markers.clear();
    });

    final String url =
        '$baseUrl?key=$API_KEY&location=$latitude,$longitude&radius=1000&language=ko&keyword=$locationName';

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        GoogleMapController controller = await _controller.future;
        controller.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(latitude, longitude),
          ),
        );

        setState(() {
          final foundPlaces = data['results'];

          for (int i = 0; i < foundPlaces.length; i++) {
            _markers.add(
              Marker(
                markerId: MarkerId(foundPlaces[i]['id']),
                position: LatLng(
                  foundPlaces[i]['geometry']['location']['lat'],
                  foundPlaces[i]['geometry']['location']['lng'],
                ),
                infoWindow: InfoWindow(
                  title: foundPlaces[i]['name'],
                  snippet: foundPlaces[i]['vicinity'],
                ),
              ),
            );
          }
        });
      }
    } else {
      print('Fail to fetch place data');
    }
  }

  void _submit() {
    if (!_fbKey.currentState.validate()) {
      return;
    }

    _fbKey.currentState.save();
    final inputValues = _fbKey.currentState.value;
    final id = inputValues['placeId'];
    print(id);

    final foundPlace = places.firstWhere(
      (place) => place['id'] == id,
      orElse: () => null,
    );

    print(foundPlace['placeName']);

    _searchPlaces(foundPlace['placeName'], 37.498295, 127.026437);

    Navigator.of(context).pop();
  }

  void _gotoGangnam() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    top: 40,
                    right: 20,
                    left: 20,
                    bottom: 20,
                  ),
                  child: FormBuilder(
                    key: _fbKey,
                    child: Column(
                      children: <Widget>[
                        FormBuilderDropdown(
                          attribute: 'placeId',
                          hint: Text('어떤 장소를 원하세요?'),
                          decoration: InputDecoration(
                            filled: true,
                            labelText: '장소',
                            border: OutlineInputBorder(),
                          ),
                          validators: [
                            FormBuilderValidators.required(
                              errorText: '장소 선택은 필수입니다!',
                            )
                          ],
                          items: places.map<DropdownMenuItem<String>>(
                            (place) {
                              return DropdownMenuItem<String>(
                                value: place['id'],
                                child: Text(place['placeName']),
                              );
                            },
                          ).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                MaterialButton(
                  child: Text('Submit'),
                  onPressed: _submit,
                  color: Colors.indigo,
                  textColor: Colors.white,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: _googleMapType,
            initialCameraPosition: _initialCameraPostion,
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            markers: _markers,
          ),
          Container(
            margin: EdgeInsets.only(top: 60, right: 10),
            alignment: Alignment.topRight,
            child: Column(
              children: <Widget>[
                FloatingActionButton.extended(
                  heroTag: 'btn1',
                  label: Text('$_googleMapType'),
                  icon: Icon(Icons.map),
                  elevation: 8,
                  backgroundColor: Colors.red[400],
                  onPressed: _changeMapType,
                ),
                SizedBox(height: 10),
                FloatingActionButton.extended(
                  heroTag: 'btn2',
                  label: Text('강남에서 볼까?'),
                  icon: Icon(Icons.zoom_out_map),
                  elevation: 8,
                  backgroundColor: Colors.blue[400],
                  onPressed: _gotoGangnam,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
