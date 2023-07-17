import 'dart:io';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_picker/image_picker.dart' as picker;
import 'package:flutter/material.dart';
import 'package:scan_visiting_card/components.dart';
import 'package:scan_visiting_card/services.dart';
import 'package:http/http.dart' as http;
// import 'package:image_cropper/image_cropper.dart' as image_cropper;
import 'package:cunning_document_scanner/cunning_document_scanner.dart' as scanner;

class UserDetails extends StatefulWidget {
  const UserDetails({super.key});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  CustomComponents customComponents = CustomComponents();
  HTTPService httpExtractService = HTTPService(url: 'http://173.249.8.98:5005');

  File? _image;
  Uint8List? convertedImage, imageBytes;
  bool progress = false;
  bool? isCamera;

  @override
  void initState() {
    _image = null;
    progress = false;
    isCamera = false;
    super.initState();
  }

  Future<void> getImage(bool isCamera) async {
    // picker.XFile? image = (isCamera)
    //     ? await picker.ImagePicker().pickImage(
    //         source: picker.ImageSource.camera,
    //         imageQuality: 50,
    //       )
    //     : await picker.ImagePicker().pickImage(
    //         source: picker.ImageSource.gallery,
    //         imageQuality: 50,
    //       );
    // if(image == null) return;
    // _image = File(image.path);
    // cropPicture();
    final imagesPath = await scanner.CunningDocumentScanner.getPictures();
    if(imagesPath == null) return;
    _image = File(imagesPath[imagesPath.length-1]);
    imagesPath.clear();
    setState(() {});
  }

  // Future<void> cropPicture() async {
  //   if(_image != null){
  //     File image = _image as File;
  //     image_cropper.CroppedFile? croppedFile;
  //     croppedFile = await image_cropper.ImageCropper().cropImage(
  //       sourcePath: image.path,
  //       compressFormat: image_cropper.ImageCompressFormat.jpg,
  //       compressQuality: 100,
  //       uiSettings: [
  //         image_cropper.AndroidUiSettings(
  //             toolbarTitle: 'Cropper',
  //             toolbarColor: Colors.deepOrange,
  //             toolbarWidgetColor: Colors.white,
  //             initAspectRatio: image_cropper.CropAspectRatioPreset.original,
  //             lockAspectRatio: false),
  //         image_cropper.IOSUiSettings(
  //           title: 'Cropper',
  //         ),
  //         image_cropper.WebUiSettings(
  //           context: context,
  //           presentStyle: image_cropper.CropperPresentStyle.dialog,
  //           boundary: const image_cropper.CroppieBoundary(
  //             width: 520,
  //             height: 520,
  //           ),
  //           viewPort: const image_cropper.CroppieViewPort(
  //               width: 480, height: 480, type: 'circle'),
  //           enableExif: true,
  //           enableZoom: true,
  //           showZoomer: true,
  //         ),
  //       ],
  //     );
  //     if(croppedFile == null) return;
  //     _image = File(croppedFile.path);
  //     progress = true;
  //     postData();
  //     setState(() {});
  //   }
  // }

  Future<void> postData() async {
    if (_image != null) {
      File image = _image as File;
      http.Response finalResponse =
          await httpExtractService.postScannedImage(image, '/parse');
      if(!mounted) return;
      if (finalResponse.statusCode == 200) {
        await Navigator.of(context).pushNamed(
          '/details',
          arguments: {
            'response': finalResponse,
          },
        );
      } else {
        progress = false;
        isCamera = false;
        _image = null;
        Fluttertoast.showToast(
          msg: 'WRONG IMAGE',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        setState(() {});
      }
    }
    setState(() {
      progress = false;
      isCamera = false;
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    // Uint8List bytes = arguments['bytes'];
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: (progress)
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_image != null)
                        SizedBox(
                          height: 300.0,
                          width: 300.0,
                          child: Image.file(
                            _image as File,
                            fit: BoxFit.contain,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            getImage(true);
                          },
                          child: customComponents.customButton("CLICK"),
                        ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   children: [
                      //     GestureDetector(
                      //       onTap: () async {
                      //         getImage(true);
                      //       },
                      //       child: customComponents.customButton("CLICK"),
                      //     ),
                      //     GestureDetector(
                      //       onTap: () async {
                      //         getImage(false);
                      //       },
                      //       child: customComponents.customButton("PICK"),
                      //     ),
                      //   ],
                      // ),
                      if(_image != null) GestureDetector(
                        onTap: (){
                          progress = true;
                          setState(() {});
                          postData();
                        },
                        child: customComponents.customButton('SUBMIT'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
