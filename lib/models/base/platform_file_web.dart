import 'dart:typed_data';

/// Web-safe stand-in for `dart:io`'s `File`, which does not exist on this
/// platform. [KImage.fromFile] is not supported on the web, so any attempt
/// to read from an instance of this class throws.
class File {
  File(this.path);

  final String path;

  Future<Uint8List> readAsBytes() {
    throw UnsupportedError('File is not supported on the web platform.');
  }
}
