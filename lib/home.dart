import 'dart:io';
import 'dart:typed_data';
import 'dart:convert' as convert;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class Camara extends StatefulWidget {
  @override
  State<Camara> createState() => _CamaraState();
}

class _CamaraState extends State<Camara> {

  File? imageFile;
  List<File?> imgList = [null, null, null];
  var imgbytess;
  List<dynamic> listBytes = [null, null, null];

  int  _Current= 0;

  void _getFromCamera() async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxHeight: 1080,
      maxWidth: 1080,
    );
    Uint8List bytes = await pickedFile!.readAsBytes();
    setState(() {
      imageFile = File(pickedFile.path);
      imgList[_Current] = File(pickedFile.path);
      imgbytess = bytes;
      listBytes[_Current] = imgbytess;
    });
  }

  void _getFromGalery() async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 1080,
      maxWidth: 1080,
    );
    Uint8List bytes = await pickedFile!.readAsBytes();
    setState(() {
      imageFile = File(pickedFile.path);
      imgList[_Current] = imageFile;
      imgbytess = bytes;
      listBytes[_Current] = imgbytess;
    });
  }
  List<List> resp = [[],[],[]];

  String responseDescp = '';

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
        resp[_Current] = tags;
        //responseDescp= descp[0]['text'];
      });

    } else {
      print('Request failed with status: ${response.statusCode}.');
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          CarouselSlider(
            options: CarouselOptions(
                height: 400,
                aspectRatio: 16/9,
                viewportFraction: 0.8,
                initialPage: 0,
                enableInfiniteScroll: true,
                reverse: true,
                autoPlay: false,
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                enlargeFactor: 0.3,
                onPageChanged: (index, reason){
                  setState(() {
                    _Current=index;
                  });
                },
                scrollDirection: Axis.horizontal,
              ),
              items: [1,2,3].map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: const BoxDecoration(
                            color: Colors.white
                        ),
                        child:
                      imgList[_Current] != null ?
                      Container(
                        child: Image.file(imgList[_Current]!),
                      )  :
                      Container(
                        child: Icon(
                          Icons.camera_enhance_rounded,
                          color: Colors.green,
                          size: MediaQuery.of(context).size.width * .6,
                        ),
                      ),
                    );
                  },
                );
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                    _getFromGalery();
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
                      padding: MaterialStateProperty.all(const EdgeInsets.all(3)),
                      textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 10))
                  ),
                  child: const Text('Subir desde Galeria'),
                ),
              ),
              imgList[_Current] != null ?
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: ElevatedButton(
                  onPressed: (){
                    _analizeImage(listBytes[_Current]);
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
          resp[_Current].isEmpty ?
          Container():
          Text(
            resp[_Current].toString() ,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          )

        ],
      ),
    );
  }
}
