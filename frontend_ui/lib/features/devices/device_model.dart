enum DeviceType {rfid, fingerprint, hybrid}
enum DeviceStatus { online, offline}

class Device {
  final String id;
  final String name;
  final DeviceType type;
  final String location;
  final String assignedClass;
  final DateTime lastSeen;
  final DeviceStatus status;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.assignedClass,
    required this.lastSeen,
    required this.status,
  });
}