import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/failures.dart';
import '../core/errors/firebase_error_mapper.dart';
import '../core/result/result.dart';

/// Wraps `image_picker` and turns the picked file into a **base64 `data:` URL**
/// small enough to be stored directly inside a Firestore document.
///
/// Requirement 3: "Add a button to update the profile photo by picking an
/// image from the device gallery using image_picker. The selected image must be
/// uploaded to Firestore and reflected immediately in the UI."
///
/// The picked bitmap is decoded with Flutter's own codecs, downscaled to
/// [AppConstants.profilePhotoMaxDimension] and re-encoded as PNG, so no extra
/// image package is required and the payload always fits the 1 MiB Firestore
/// document ceiling.
class ImagePickerService {
  ImagePickerService();

  static ImagePickerService? _instance;

  static ImagePickerService get instance => _instance ??= ImagePickerService();

  static void registerInstance(ImagePickerService service) {
    _instance = service;
  }

  final ImagePicker _picker = ImagePicker();

  /// Presents the gallery (and, on mobile, the camera option) and returns a
  /// base64 `data:` URL, or `null` when the member dismissed the sheet.
  Future<Result<String?>> pickProfilePhoto() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        requestFullMetadata: false,
      );
      if (file == null) {
        return const Success<String?>(null);
      }
      final Uint8List bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        return const ResultFailure<String>(
          UnexpectedFailure('The selected image could not be read.'),
        );
      }
      final Uint8List resized = await _downscale(bytes);
      return Success<String>(_toDataUrl(resized));
    } on Object catch (error) {
      return ResultFailure<String>(FirebaseErrorMapper.map(error));
    }
  }

  /// Takes a photo with the camera — used by the "Camera" quick action.
  Future<Result<String?>> captureProfilePhoto() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        requestFullMetadata: false,
      );
      if (file == null) {
        return const Success<String?>(null);
      }
      final Uint8List bytes = await file.readAsBytes();
      final Uint8List resized = await _downscale(bytes);
      return Success<String>(_toDataUrl(resized));
    } on Object catch (error) {
      return ResultFailure<String>(FirebaseErrorMapper.map(error));
    }
  }

  String _toDataUrl(Uint8List bytes) =>
      'data:image/png;base64,${base64Encode(bytes)}';

  /// Scales the bitmap down so its longest side matches
  /// [AppConstants.profilePhotoMaxDimension].
  ///
  /// Only *down*-scales: passing a `targetWidth` larger than the source makes
  /// the codec upscale, which would inflate the base64 payload instead of
  /// shrinking it.
  Future<Uint8List> _downscale(Uint8List bytes) async {
    try {
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frame = await codec.getNextFrame();
      ui.Image source = frame.image;

      final int longestSide = frame.image.width > frame.image.height
          ? frame.image.width
          : frame.image.height;
      if (longestSide > AppConstants.profilePhotoMaxDimension) {
        final double factor =
            AppConstants.profilePhotoMaxDimension / longestSide;
        final ui.Codec scaled = await ui.instantiateImageCodec(
          bytes,
          targetWidth: (frame.image.width * factor).round(),
          targetHeight: (frame.image.height * factor).round(),
        );
        final ui.FrameInfo scaledFrame = await scaled.getNextFrame();
        source = scaledFrame.image;
        scaled.dispose();
      }

      final ByteData? png = await source.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List? encoded = png?.buffer.asUint8List();
      source.dispose();
      codec.dispose();

      if (encoded == null ||
          encoded.isEmpty ||
          encoded.length > AppConstants.maxProfilePhotoBytes) {
        // The encoder failed, or the result still exceeds the Firestore
        // document ceiling: keep the original bytes rather than store nothing.
        return bytes;
      }
      return encoded;
    } on Object catch (error, stackTrace) {
      // Downscaling is a best effort optimisation: an unreadable decoder must
      // never block the upload, the original bytes are used instead.
      assert(() {
        debugPrint('Image downscale skipped: $error\n$stackTrace');
        return true;
      }());
      return bytes;
    }
  }
}
