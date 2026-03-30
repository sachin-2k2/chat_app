import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  static const String cloudName = 'dgvq3xuqe';
  static const String uploadPreset = 'chat_app';

  //Pick image from gallery
  Future<File?> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  //upload image to firebase storage
  Future<String?> uploadImage({
    required File file,
    required String senderId,
    required String receiverId,
  }) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonData = jsonDecode(responseString);
      print('Cloudinary response: $jsonData');

      if (response.statusCode == 200) {
        final imageUrl = jsonData['secure_url'];
        return imageUrl;
      } else {
        print('Upload Failed:${jsonData['error']}');
        return null;
      }
    } catch (e) {
      print('Upload error:$e');
      return null;
    }
  }
}
