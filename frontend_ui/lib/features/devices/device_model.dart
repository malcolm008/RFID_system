enum DeviceType {rfid, fingerprint, hybrid}
enum DeviceStatus { online, offline}

class Device {
  final String id;
  final String name;
  final DeviceType type;
  final String location;
  final DateTime lastSeen;
  final DeviceStatus status;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.lastSeen,
    required this.status,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'].toString(),
      name: json['name'],
      type: DeviceType.values.firstWhere(
          (e) => e.name == json['type'],
        orElse: () => DeviceType.rfid,
      ),
      location: json['location'],
      lastSeen: DateTime.parse(json['lastSeen']),
      status: DeviceStatus.values.firstWhere(
          (e) => e.name  == json['status'],
        orElse: () => DeviceStatus.offline,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "type": type.name,
      "location": location,
      "lastSeen": lastSeen.toIso8601String(),
      "status": status.name,
    };
  }
}