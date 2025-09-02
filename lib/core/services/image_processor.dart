import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageProcessor {
  static const int maxWidth = 600;
  static const int maxHeight = 600;
  static const int quality = 80;
  static const int maxFileSize = 200 * 1024; // 200KB max

  /// Processes and optimizes image data for storage
  static Future<Uint8List?> processImage(Uint8List originalData) async {
    try {
      // Decode the image
      final image = img.decodeImage(originalData);
      if (image == null) return null;

      // Resize if necessary
      img.Image processedImage = image;
      if (image.width > maxWidth || image.height > maxHeight) {
        processedImage = img.copyResize(
          image,
          width: image.width > image.height ? maxWidth : null,
          height: image.height > image.width ? maxHeight : null,
          maintainAspect: true,
        );
      }

      // Compress to JPEG with quality setting
      Uint8List compressedData = Uint8List.fromList(
        img.encodeJpg(processedImage, quality: quality)
      );

      // If still too large, reduce quality further
      if (compressedData.length > maxFileSize) {
        int currentQuality = quality;
        while (compressedData.length > maxFileSize && currentQuality > 30) {
          currentQuality -= 10;
          compressedData = Uint8List.fromList(
            img.encodeJpg(processedImage, quality: currentQuality)
          );
        }
      }

      return compressedData;
    } catch (e) {
      print('Error processing image: $e');
      return null;
    }
  }

  /// Gets image dimensions without fully decoding
  static Future<Map<String, int>?> getImageDimensions(Uint8List data) async {
    try {
      final image = img.decodeImage(data);
      if (image == null) return null;
      
      return {
        'width': image.width,
        'height': image.height,
      };
    } catch (e) {
      print('Error getting image dimensions: $e');
      return null;
    }
  }

  /// Estimates the file size after processing
  static Future<int> estimateProcessedSize(Uint8List originalData) async {
    try {
      final processed = await processImage(originalData);
      return processed?.length ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
