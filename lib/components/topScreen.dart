import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class TopScreen extends StatefulWidget {
  const TopScreen({Key? key}) : super(key: key);

  @override
  State<TopScreen> createState() => _TopScreenState();
}

class _TopScreenState extends State<TopScreen> {

  File? imageFile;
  var imgbytess;

  void _getFromCamera() async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxHeight: 1080,
      maxWidth: 1080,
    );
    Uint8List bytes = await pickedFile!.readAsBytes();
    setState(() {
      imageFile = File(pickedFile.path);
      imgbytess= bytes;
    });
  }


  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
