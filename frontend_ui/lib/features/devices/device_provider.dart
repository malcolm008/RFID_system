import 'package:flutter/material.dart';
import 'device_api.dart';
import 'device_model.dart';
import '../../core/services/notification_provider.dart';
import 'package:provider/provider.dart';

class DeviceProvider extends ChangeNotifier{
  final List<Device> _devices = [];
  bool _loading = false;

  final NotificationProvider notificationProvider;

  DeviceProvider(this.notificationProvider);

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

      notificationProvider.addDeviceNotification(
        action: "added",
        deviceName: newDevice.name,
      );

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
        final oldDevice = _devices[index];

        if (oldDevice.status == "online") {
          notificationProvider.addDeviceNotification(
            action: "online",
            deviceName: updated.name,
          );
        }

        if (updated.status == "offline") {
          notificationProvider.addDeviceNotification(
            action: "offline",
            deviceName: updated.name,
          );
        }
        _devices[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating device: $e");
      rethrow;
    }
  }

  Future<void> deleteDevice(String id) async {
    try {
      final device = _devices.firstWhere((d) => d.id == id);
      await DeviceApi.deleteDevice(id);
      _devices.removeWhere((d) => d.id == id);

      notificationProvider.addDeviceNotification(
        action: "deleted",
        deviceName: device.name,
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting device $id: $e');
      rethrow;
    }
  }

  Future<void> bulkDeleteDevices(List<String> ids) async {
    try {
      final deletedDevices = _devices.where((d) => ids.contains(d.id)).toList();
      await DeviceApi.bulkDeleteDevices(ids);
      _devices.removeWhere((d) => ids.contains(d.id));

      for(var device in deletedDevices) {
        notificationProvider.addDeviceNotification(
          action: "deleted",
          deviceName: device.name,
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error bulk deleting devices: $e');
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