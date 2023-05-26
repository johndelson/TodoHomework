import 'package:image_picker/image_picker.dart';

class ImageUtils {
  static final _picker = ImagePicker();

  static Future<XFile?> pickImage() async {
    return await _picker.pickImage(source: ImageSource.gallery);
  }
}
