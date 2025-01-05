class Accident {
  final int? id;
  final int userId;
  final double latitude;
  final double longitude;
  final String timestamp;

  Accident(
      {this.id,
      required this.userId,
      required this.latitude,
      required this.longitude,
      required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
    };
  }

  factory Accident.fromMap(Map<String, dynamic> map) {
    return Accident(
      id: map['id'],
      userId: map['userId'],
      // latitude: map['latitude'] comverted to double
      latitude: double.parse(map['latitude']),
      longitude: double.parse(map['longitude']),
      timestamp: map['timestamp'],
    );
  }
}
