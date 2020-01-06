class PickedLocation {
  String id;
  String comment;
  String address;
  double lat;
  double lng;

  PickedLocation({
    this.id,
    this.comment,
    this.address,
    this.lat,
    this.lng,
  });

  @override
  String toString() {
    return '''
      id: $id
      comment: $comment
      address: $address
      coordinate: $lat, $lng
    ''';
  }
}
