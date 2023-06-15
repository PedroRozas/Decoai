import 'dart:io';
import 'dart:typed_data';
import 'dart:convert' as convert;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';

class Design extends StatefulWidget {
  const Design({super.key});
  @override
  State<Design> createState() => _DesignState();
}

class _DesignState extends State<Design> {

  String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
  Reference storageRef = FirebaseStorage.instance.ref();

  String resp = '' ;
  var jsonResp = null;
  File? imageFile;
  var imgbytess;
  var imageUrl=null;
  String selectedType = 'Elige una opción';
  String selectedStyle = 'Elige una opción';
  List<String> dropdownTypes = ['Elige una opción', 'living room', 'bathroom', 'kitchen', 'bedroom'];
  List<String> dropdownStyles = ['Elige una opción', 'industrial', 'Kinkfolk', 'minimalist','modern','viking','romantic','art deco','retro','Retro'];
  
//Function to capture a photo from camera
  Future<void> _getFromCamera() async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxHeight: 1080,
      maxWidth: 1080,
    );
    Uint8List bytes = await pickedFile!.readAsBytes();
    setState(() {
      imageFile = File(pickedFile.path);
      imgbytess = bytes;
     
    });
  }
//function to get a photo from gallery
  void _getFromGalery() async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 1080,
      maxWidth: 1080,
    );
    Uint8List bytes = await pickedFile!.readAsBytes();
    setState(() async {
      imageFile = File(pickedFile.path);
      imgbytess = bytes;

    });
  }
//upload image to firebase
  void analizar() async {
    Reference referenceDirImages= storageRef.child('images');
    Reference imagetoUpload = referenceDirImages.child(uniqueFileName);
    SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg',);
    try {
      await imagetoUpload.putFile(imageFile!, metadata);
      String resp1 = await  imagetoUpload.getDownloadURL();
      setState(() {
        String cleanedLink = resp1.replaceAll('https://', '');
        resp = resp1;
      });
    }
    catch (e) {};
    print(resp);
}
  void _analizeImage(img) async {
    const url = "https://recomendaciones.cognitiveservices.azure.com/vision/v3.2/describe?maxCandidates=1&language=es&model-version=latest";
    final Uri uri = Uri
        .parse(url);  // parse string
    var response = await http.post(uri, headers: {'Content-Type': 'application/octet-stream',
      'Ocp-Apim-Subscription-Key': '25993f24b4f94d6c8c9da01e228c48ae'},body: img);
    if (response.statusCode == 200) {
      var jsonResponse =
      convert.jsonDecode(response.body) as Map<String, dynamic>;
      var tags = jsonResponse['description']['tags'];
      //var descp = jsonResponse['description']['captions'];
      print (jsonResponse);
      setState(() {
        resp = tags;
        //responseDescp= descp[0]['text'];
      });

    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }



  //Function to get a new style from an image
  void newStyle(imgLink) async {
    const url = "https://stablediffusionapi.com/api/v5/interior";
    final Uri uri = Uri
        .parse(url);  // parse string
    var response = await http.post(uri,body:{
      'key':'9eFS96XvxH2Vwoa6MFYB34yfJbF8Ym0FfbdRZpaK6usdQhd6J6ysJwSoFpXs',
      'init_image':"$imgLink",
      'prompt':'$selectedType $selectedStyle',
      'steps':'50',
      'guidance_scale':'10'}
    );
    if (response.statusCode == 200) {
      var jsonResponse =
      convert.jsonDecode(response.body) as Map<String, dynamic>;
      var tags = jsonResponse['output'];
      //var descp = jsonResponse['description']['captions'];
      setState(() {
        jsonResp = jsonResponse;
        imageUrl = jsonResponse['output'][0];
        //responseDescp= descp[0]['text'];
      });

    } else {
      print('Request failed with status: ${response.statusCode}.');
    }

  }

//main screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          imageFile != null ?
          Container(
            child: Image.file(imageFile!),
          )  :
          Container(
            child: Icon(
              Icons.camera_enhance_rounded,
              color: Colors.green,
              size: MediaQuery.of(context).size.width * .6,
            ),
          ),
          Row(
            children: [
              DropdownButton<String>(
                value: selectedType,
                items: dropdownTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                  );
                  }).toList(),
                  onChanged: (String? newValue) {
                     setState(() {
                    selectedType = newValue!;
                    });
                    },
              ),
              DropdownButton<String>(
                value: selectedStyle,
                items: dropdownStyles.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStyle = newValue!;
                  });
                },
              ),
            ],
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: ElevatedButton(
                  onPressed: (){
                    _getFromCamera();
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
                      padding: MaterialStateProperty.all(const EdgeInsets.all(3)),
                      textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 10))
                  ),
                  child: const Text('Tomar foto!'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: ElevatedButton(
                  onPressed: (){
                    analizar();
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
                      padding: MaterialStateProperty.all(const EdgeInsets.all(3)),
                      textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 10))
                  ),
                  child: const Text('Subir desde Galeria'),
                ),
              ),
              imageFile != null ?
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: ElevatedButton(
                  onPressed: (){
                  newStyle(resp.toString());
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
                      padding: MaterialStateProperty.all(const EdgeInsets.all(3)),
                      textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 10))
                  ),
                  child: const Text('Analizar'),
                ),
              ) : Container(),
            ],
          ),
          jsonResp != null ?
          Image.network(imageUrl.toString()):
          Container(),

        ]
    )
    );
  }
}
