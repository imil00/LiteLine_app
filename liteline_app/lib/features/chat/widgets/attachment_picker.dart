import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class AttachmentPicker {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Memilih gambar dari galeri.
  static Future<XFile?> pickImageFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    return image;
  }

  /// Memilih video dari galeri.
  static Future<XFile?> pickVideoFromGallery() async {
    final XFile? video = await _imagePicker.pickVideo(source: ImageSource.gallery);
    return video;
  }

  /// Memilih file dari penyimpanan.
  static Future<FilePickerResult?> pickFile(String type) async {
    FileType fileType;
    String? dialogTitle;
    List<String>? allowedExtensions;

    if (type == 'gallery') {
      fileType = FileType.media;
      dialogTitle = 'Select Image or Video';
      allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'mov', 'avi'];
    } else if (type == 'file') {
      fileType = FileType.any;
      dialogTitle = 'Select File';
      // You might want to specify allowed extensions for documents, PDFs, etc.
      // allowedExtensions = ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'];
    } else {
      return null;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowMultiple: false,
        dialogTitle: dialogTitle,
        allowedExtensions: allowedExtensions,
      );
      return result;
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

  /// Mengambil gambar atau video langsung dari kamera.
  static Future<XFile?> takePhotoOrVideo(ImageSource source, {bool isVideo = false}) async {
    if (isVideo) {
      final XFile? video = await _imagePicker.pickVideo(source: source);
      return video;
    } else {
      final XFile? image = await _imagePicker.pickImage(source: source);
      return image;
    }
  }
}