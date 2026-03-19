import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';


class MediaPickerService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickFromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // 🔥 compresión automática
    );

    if (picked == null) return null;

    return File(picked.path);
  }

  Future<File?> pickFromCamera() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (picked == null) return null;

    return File(picked.path);
  }
}

Future<File?> showImageSourceSelector(
    BuildContext context,
    Future<File?> Function() onCamera,
    Future<File?> Function() onGallery,
    ) async {
  return await showModalBottomSheet<File>(
    context: context,
    builder: (_) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Tomar foto"),
              onTap: () async {
                final file = await onCamera();
                Navigator.pop(context, file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Elegir de galería"),
              onTap: () async {
                final file = await onGallery();
                Navigator.pop(context, file);
              },
            ),
          ],
        ),
      );
    },
  );
}