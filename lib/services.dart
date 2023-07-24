import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as parser;
import 'package:path/path.dart' as p;
import 'package:scan_visiting_card/model.dart' as model;
import 'package:cunning_document_scanner/cunning_document_scanner.dart' as scanner;
import 'package:image_picker/image_picker.dart' as picker;
import 'package:image_cropper/image_cropper.dart' as cropper;
import 'package:flutter_image_compress/flutter_image_compress.dart' as image_editor;

class ImageService{
  Future<File?> getImage(bool isCamera) async {
    File image;
    if(isCamera){
      List<String>? images = await scanner.CunningDocumentScanner.getPictures();
      if (images == null) return null;
      image = File(images.last);
    } else{
      picker.XFile? pickedImage = await picker.ImagePicker().pickImage(
        source: picker.ImageSource.gallery,
        imageQuality: 50,
        requestFullMetadata: false,
      );
      cropper.CroppedFile? croppedFile = await cropper.ImageCropper().cropImage(
        sourcePath: (pickedImage as picker.XFile).path,
        aspectRatioPresets: [
          cropper.CropAspectRatioPreset.square,
          cropper.CropAspectRatioPreset.ratio3x2,
          cropper.CropAspectRatioPreset.original,
          cropper.CropAspectRatioPreset.ratio5x4,
          cropper.CropAspectRatioPreset.ratio16x9,
        ],
        compressQuality: 50,
        cropStyle: cropper.CropStyle.rectangle,
        uiSettings: [
          cropper.AndroidUiSettings(
            activeControlsWidgetColor: Colors.green,
            hideBottomControls: false,
            initAspectRatio: cropper.CropAspectRatioPreset.original,
            lockAspectRatio: false,
            toolbarColor: Colors.green,
            toolbarWidgetColor: Colors.white,
          ),
        ],
      );
      if(croppedFile == null) return null;
      image = File(croppedFile.path);
    }
    Uint8List? data = await image_editor.FlutterImageCompress.compressWithFile(
      image.path,
      autoCorrectionAngle: true,
      keepExif: false,
      quality: 50,
    );
    await image.writeAsBytes(data as Uint8List);
    return image;
  }

  Future<Uint8List> rotateImage(Uint8List data, int angle) async {
    Uint8List? rotatedImage = await image_editor.FlutterImageCompress.compressWithList(
      data,
      autoCorrectionAngle: false,
      format: image_editor.CompressFormat.png,
      quality: 50,
      rotate: angle,
    );
    return rotatedImage;
  }
}

class HTTPService {
  String url;

  HTTPService({required this.url});

  Future<http.Response> postScannedImage(File image, String path) async {
    String fileExtension = p.extension(image.path);
    fileExtension = fileExtension.split('.')[1];
    http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(url + path));
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        image.path,
        contentType: parser.MediaType('application', fileExtension),
      ),
    );
    http.StreamedResponse res = await request.send();
    http.Response response = await http.Response.fromStream(res);
    return response;
  }

  Future<http.Response> postData(http.Response getResponse, File image, String path) async {
    String fileExtension = p.extension(image.path);
    fileExtension = fileExtension.split('.')[1];
    Map map = {
      "data" : '"${getResponse.body.toString()}"',
      "filename" : '"output.$fileExtension"',
      "file" : '''"b'${base64.encode(image.readAsBytesSync())}'"''',
    };
    var response = await http.post(
      Uri.parse(url+path),
      headers: {"Content-Type": "application/json"},
      body: json.encode(map),
    );
    return response;
  }
}

class User{
  Map<String,dynamic> detailsList = {};
  http.Response response;

  User({required this.response});

  Future<Map<String,dynamic>> getUser() async {
    detailsList.clear();
      final data = await jsonDecode((response).body.toString())['info'];
      for(Map<String,dynamic> i in data.cast()){
        model.Model user = model.Model(
          name: i['name'],
          address: i['address'],
          phoneNumber: i['phone_number'],
          fax: i['fax'],
          email: i['email'],
          designation: i['designation'],
          companyName: i['company_name'],
          website: i['website'],
        );
        detailsList.addEntries(user.toJson().entries);
      }
    return detailsList;
  }
}