import 'package:example/autocomplete_location/autocomplete_location.dart';
import 'package:example/widgets/custom_button.dart';
import 'package:example/pick_location/important_locations.dart';
import 'package:example/place_autocomplete/place_autocomplete.dart';
import 'package:example/providers/picked_locations_provider.dart';
import 'package:flutter/material.dart';
import 'package:place_picker/place_picker.dart';
import 'package:provider/provider.dart';

import 'package:example/places_nearby/places_nearby.dart';
import 'package:example/constants/constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PickedLocationsProvider(),
      child: MaterialApp(
        title: 'Google Maps Demo',
        home: Home(),
      ),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maps'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomButton(
              title: 'Places Nearby',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => PlacesNearby()),
                );
              },
            ),
            SizedBox(height: 20),
            CustomButton(
              title: 'Place Picker',
              onPressed: () async {
                LocationResult result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PlacePicker(API_KEY),
                  ),
                );

                // Handle the result in your way
                print(result);
              },
            ),
            SizedBox(height: 20),
            CustomButton(
              title: 'Place Autocomplete',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return PlaceAutocomplete();
                  }),
                );
              },
            ),
            SizedBox(height: 20),
            CustomButton(
              title: 'Place Autocomplete + Location',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return AutocompleteLocation();
                  }),
                );
              },
            ),
            SizedBox(height: 20),
            CustomButton(
              title: 'Pick a location',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return ImportantLocations();
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
