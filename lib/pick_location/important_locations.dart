import 'package:example/models/picked_location.dart';
import 'package:example/pick_location/pick_location.dart';
import 'package:example/providers/picked_locations_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImportantLocations extends StatefulWidget {
  @override
  _ImportantLocationsState createState() => _ImportantLocationsState();
}

class _ImportantLocationsState extends State<ImportantLocations> {
  List<PickedLocation> locations = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getLocations();
  }

  _getLocations() async {
    setState(() => isLoading = true);
    try {
      await Provider.of<PickedLocationsProvider>(context, listen: false)
          .getLocations();
      setState(() => isLoading = false);
    } catch (err) {
      setState(() => isLoading = false);
      print(err);
    }
  }

  _deleteLocation(PickedLocation location) async {
    setState(() => isLoading = true);
    try {
      await Provider.of<PickedLocationsProvider>(context, listen: false)
          .deleteLocation(location.id);
      setState(() => isLoading = false);
    } catch (err) {
      setState(() => isLoading = false);
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locations =
        Provider.of<PickedLocationsProvider>(context).pickedLocations;

    return Scaffold(
      appBar: AppBar(
        title: Text('Important Locations'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (ctx) => PickLocation(),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : locations.length == 0
              ? Center(child: Text('Add important locations'))
              : ListView.builder(
                  itemCount: locations.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: ListTile(
                        title: Text(
                          locations[index].address,
                        ),
                        subtitle: Text(locations[index].comment),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteLocation(locations[index]),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
