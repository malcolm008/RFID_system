import 'dart:convert';
import 'package:http/http.dart' as http;
import 'device_model.dart';

class DeviceApi {
  static const String baseUrl = "http://127.0.0.1:8000/attendance_api/devices";

  static Future<List<Device>> fetchDevices() async {
    final response = await http.get(Uri.parse("$baseUrl/list/"));

    print("Device List Status: ${response.statusCode}");
    print("Device List Body: ${response.body}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      if (body is Map && body['status'] == 'success') {
        final List data = body['data'];
        return data.map((e) => Device.fromJson(e)).toList();
      } else {
        throw Exception(body['message'] ?? 'Invalid response');
      }
    } else {
      throw Exception('Failed to load devices');
    }
  }

  static Future<Device> addDevice(Device device) async {
    final response = await http.post(
      Uri.parse("$baseUrl/create"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(device.toJson()),
    );

    print("Add Device Status: ${response.statusCode}");
    print("Add Device Body: ${response.body}");

    final body = jsonDecode(response.body);

    if (response.statusCode == 201 && body['status'] == 'success') {
      return Device.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Failed to add device');
    }
  }

  static Future<Device> updateDevice(Device device) async {
    final response = await http.post(
      Uri.parse("$baseUrl/update/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(device.toJson()),
    );

    print("Update Device Status: ${response.statusCode}");
    print("Update Device Body: ${response.body}");

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['status'] == 'success') {
      return Device.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Failed to update device');
    }
  }

  static Future<void> deleteDevice(String id) async {
    final response = await http.post(
      Uri.parse("$baseUrl/delete/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": int.parse(id)}),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['status'] == 'success') {
      print("Devices deleted: $id");
    } else {
      throw Exception(body['message'] ?? 'Failed to delete device');
    }
  }

  static Future<void> bulkDeleteDevices(List<String> ids) async {
    final response = await http.post(
      Uri.parse("$baseUrl/bulk-delete/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"ids": ids.map((e) => int.parse(e)).toList()}),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['status'] == 'success') {
      print("Devices deleted: ${ids.join(', ')}");
    } else {
      throw Exception(body['message'] ?? 'Failed to bulk delete devices');
    }
  }
}