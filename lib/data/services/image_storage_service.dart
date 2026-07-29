import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageStorageService {
  Directory? _imagesDirectory;

  Future<void> ensureInitialized() async {
    if (_imagesDirectory != null) {
      return;
    }
    final supportDir = await getApplicationSupportDirectory();
    _imagesDirectory = Directory(p.join(supportDir.path, 'card_images'));
    if (!await _imagesDirectory!.exists()) {
      await _imagesDirectory!.create(recursive: true);
    }
  }

  Future<String> saveImageFromPath(String sourcePath) async {
    await ensureInitialized();
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw StateError('Selected image file does not exist.');
    }

    final extension = p.extension(sourcePath);
    final fileName =
        '${DateTime.now().microsecondsSinceEpoch}${extension.isEmpty ? '.jpg' : extension}';
    final destination = File(p.join(_imagesDirectory!.path, fileName));
    await sourceFile.copy(destination.path);
    return destination.path;
  }

  Future<void> deleteImageIfExists(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return;
    }
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
