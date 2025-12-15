import 'dart:async';
import 'package:flutter/material.dart';
import 'device_model.dart';

class DeviceProvider extends ChangeNotifier {
  final List<Device> _devices = [
    Device(
      id: 'DEV-001',
      name: 'Room A Scanner',
      type: DeviceType.hybrid,
      location: 'Room A',
      assignedClass: 'CS Year 1',
      lastSeen: DateTime.now(),
      status: DeviceStatus.online,
    ),
    Device(
      id: 'DEV-002',
      name: 'Room B RFID',
      type: DeviceType.rfid,
      location: 'Room B',
      assignedClass: 'CS Year 2',
      lastSeen: DateTime.now().subtract(const Duration(minutes: 12)),
      status: DeviceStatus.offline,
    ),
  ];

  List<Device> get devices => _devices;

  DeviceProviderk() {
    _simulateHeartbeat();
  }

  void _simulateHeartbeat() {
    Timer.periodic(const Duration(seconds: 10), (_) {
      for (var i = 0; i< _devices.length; i++) {
        if (_devices[i].status == DeviceStatus.online) {
          _devices[i] = Device(
            id: _devices[i].id,
            name: _devices[i].name,
            type: _devices[i].type,
            location: _devices[i].location,
            assignedClass: _devices[i].assignedClass,
            lastSeen: DateTime.now(),
            status: DeviceStatus.online,
          );
        }
      }
      notifyListeners();
    });
  }
}