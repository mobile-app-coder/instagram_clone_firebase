import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/post_model.dart';
import '../services/db_service.dart';
import '../services/file_service.dart';

class UploadPage extends StatefulWidget {
  final PageController? pageController;

  const UploadPage({super.key, this.pageController});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool isLoading = false;
  var captionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _image;

  _moveToFeed() {
    setState(() {
      isLoading = false;
    });
    captionController.text = "";
    _image = null;
    widget.pageController!.animateToPage(0,
        duration: Duration(microseconds: 200), curve: Curves.easeIn);
  }

  _imgFromGallery() async {
    XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _image = File(image!.path);
    });
  }

  _imgFromCamera() async {
    XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);
    setState(() {
      _image = File(image!.path);
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
              child: Container(
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text("Pick Photo"),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text("Pick Photo"),
                  onTap: () {
                    _imgFromGallery();
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ));
        });
  }

  _uploadNewPost() {
    String caption = captionController.text.toString().trim();
    if (caption.isEmpty) return;
    if (_image == null) return;
    _apiPostImage();
  }

  void _apiPostImage() {
    setState(() {
      isLoading = true;
    });
    FileService.uploadPostImage(_image!).then(
      (downloadUrl) => {
        _resPostImage(downloadUrl),
      },
    );
  }

  void _resPostImage(String downloadUrl) {
    String caption = captionController.text.toString().trim();
    Post post = Post(caption, downloadUrl);
    _apiStorePost(post);
  }

  void _apiStorePost(Post post) async {
    // Post to posts
    Post posted = await DBService.storePost(post);
    // Post to feeds
    DBService.storeFeed(posted).then(
      (value) => {
        _moveToFeed(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Upload",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _uploadNewPost();
              });
            },
            icon: Icon(Icons.drive_folder_upload),
            color: Color.fromRGBO(193, 53, 132, 1),
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      _showPicker(context);
                    },
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width,
                      color: Colors.grey.withOpacity(0.4),
                      child: _image == null
                          ? const Center(
                              child: Icon(
                                Icons.add_a_photo,
                                size: 50,
                                color: Colors.grey,
                              ),
                            )
                          : Stack(
                              children: [
                                Image.file(
                                  _image!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  width: double.infinity,
                                  color: Colors.black12,
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _image = null;
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.highlight_remove,
                                            color: Colors.white,
                                          )),
                                    ],
                                  ),
                                )
                              ],
                            ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                    child: TextField(
                      controller: captionController,
                      style: TextStyle(color: Colors.black),
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
                      minLines: 1,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Caption",
                          hintStyle:
                              TextStyle(fontSize: 17, color: Colors.black38)),
                    ),
                  )
                ],
              ),
            ),
          ),
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
