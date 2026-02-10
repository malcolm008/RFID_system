import 'package:flutter/material.dart';
import 'device_api.dart';
import 'device_model.dart';

class DeviceProvider extends ChangeNotifier{
  final List<Device> _devices = [];
  bool _loading = false;

  List<Device> get devices => _devices;
  bool get isLoading => _loading;

  Future<void> loadDevices() async {
    try {
      _loading = true;
      notifyListeners();

      final data = await DeviceApi.fetchDevices();
      _devices
        ..clear()
        ..addAll(data);
    } catch (e) {
      debugPrint("Error loading devices: $e");
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addDevice(Device device) async {
    try{
      final newDevice = await DeviceApi.addDevice(device);
      _devices.add(newDevice);
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding device: $e");
      rethrow;
    }
  }

  Future<void> updateDevice(Device device) async {
    try {
      final updated = await DeviceApi.updateDevice(device);
      final index = _devices.indexWhere((d) => d.id == updated.id);
      if(index != -1) {
        _devices[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updatind device: $e");
      rethrow;
    }
  }

  Device? getById(String id) {
    try {
      return _devices.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}