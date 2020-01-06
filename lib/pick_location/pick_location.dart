import 'package:example/pick_location/big_map.dart';
import 'package:example/pick_location/important_locations.dart';
import 'package:example/providers/picked_locations_provider.dart';
import 'package:example/services/google_map_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:example/models/picked_location.dart';
import 'package:provider/provider.dart';

class PickLocation extends StatefulWidget {
  @override
  _PickLocationState createState() => _PickLocationState();
}

class _PickLocationState extends State<PickLocation> {
  GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  PickedLocation pickedLocation;
  String mapImageUrl;
  bool mapLoading = false;
  Map<String, dynamic> pickedLoc;
  TextEditingController _addressController = TextEditingController();

  void _submit() {
    if (!_fbKey.currentState.validate() || pickedLoc['address'] == null) {
      return;
    }

    _fbKey.currentState.save();
    final inputValues = _fbKey.currentState.value;
    print(inputValues);

    final PickedLocation newLocation = PickedLocation(
      comment: inputValues['comment'],
      address: inputValues['address'],
      lat: pickedLoc['latitude'],
      lng: pickedLoc['longitude'],
    );

    Provider.of<PickedLocationsProvider>(context, listen: false)
        .addLocation(newLocation);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ImportantLocations(),
      ),
    );
  }

  _pickLocation() async {
    pickedLoc = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => BigMap(),
        fullscreenDialog: true,
      ),
    );

    print(pickedLoc);

    if (pickedLoc == null) {
      return;
    }

    setState(() => mapLoading = true);

    final staticImageUrl = GoogleMapServices.getStaticMap(
        pickedLoc['latitude'], pickedLoc['longitude']);

    setState(() {
      _addressController.text = pickedLoc['address'];
      mapImageUrl = staticImageUrl;
      mapLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick Location'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            FormBuilder(
              key: _fbKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20.0),
                  Text(
                    'Pick important place',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: FormBuilderTextField(
                      attribute: 'comment',
                      decoration: InputDecoration(
                        labelText: 'Comment',
                        filled: true,
                        border: OutlineInputBorder(),
                      ),
                      validators: [
                        FormBuilderValidators.required(
                            errorText: 'comment는 필수입니다'),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: FormBuilderTextField(
                      controller: _addressController,
                      attribute: 'address',
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        filled: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Colors.grey[100],
              ),
              child: mapImageUrl == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.add,
                              color: Colors.grey,
                            ),
                            iconSize: 96,
                            onPressed: _pickLocation,
                          ),
                          Text(
                            '장소를 선택하려면 + 아이콘을 탭하세요',
                          ),
                        ],
                      ),
                    )
                  : mapLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Image.network(mapImageUrl,
                          width: double.infinity, fit: BoxFit.cover),
            ),
            SizedBox(height: 20.0),
            MaterialButton(
              textColor: Colors.white,
              height: 45.0,
              minWidth: 180,
              color: Theme.of(context).primaryColor,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Icon(Icons.check),
                  SizedBox(width: 20.0),
                  Text(
                    'Pick Location',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ],
              ),
              onPressed: _submit,
            )
          ],
        ),
      ),
    );
  }
}
