import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone_firebase/pages/sign_in_page.dart';
import 'package:instagram_clone_firebase/services/log_service.dart';

import '../models/member_model.dart';
import '../models/post_model.dart';
import '../services/auth_service.dart';
import '../services/db_service.dart';
import '../services/file_service.dart';
import '../services/util_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = false;
  int axisCount = 2;
  List<Post> items = [];
  File? _image;
  bool isList = false;
  String fullName = "", email = "", img_url = "";
  int count_posts = 0, count_followers = 0, count_following = 0;
  final ImagePicker picker = ImagePicker();

  _imageFromGallery() async {
    XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _image = File(image!.path);
    });
    _apiChangePhoto();
  }

  _imageFromCamera() async {
    XFile? image =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    setState(() {
      _image = File(image!.path);
    });
    _apiChangePhoto();
  }

  _dialogLogout() async {
    var result = await Utils.dialogCommon(
        context, "Instagram", "Do you want to logout?", false);
    if (result) {
      setState(() {
        isLoading = true;
      });
      _signOutUser();
    }
  }


  _dialogRemovePost(Post post) async {
    var result = await Utils.dialogCommon(context, "Instagram", "Do you want to detele this post?", false);
    if (result) {
      setState(() {
        isLoading = true;
      });
      DBService.removePost(post).then((value) => {
        _apiLoadPosts(),
      });
    }
  }

  void _showMemberInfo(Member member) {
    setState(() {
      isLoading = false;
      fullName = member.fullname;
      email = member.email;
      img_url = member.img_url;
      count_following = member.following_count;
      count_followers = member.followers_count;
    });
  }

  _resLoadPosts(List<Post> posts) {
    setState(() {
      items = posts;
      count_posts = posts.length;
    });
  }

  _apiLoadPosts() {
    DBService.loadPosts().then((value) => {
      _resLoadPosts(value),
    });
  }

  _signOutUser() {
    AuthService.signOutUser(context);
    Navigator.pushReplacementNamed(context, SignInPage.id);
  }

  void _apiLoadMember() {
    setState(() {
      isLoading = true;
    });
    DBService.loadMember().then((value) => {
      _showMemberInfo(value),
    });
  }

  _apiUpdateMember(String downloadUrl) async {
    Member member = await DBService.loadMember();
    member.img_url = downloadUrl;
    await DBService.updateMember(member);
    _apiLoadMember();
  }

  _apiChangePhoto() {
    if (_image == null) return;
    setState(() {
      isLoading = true;
      LogService.i("image");
    });
    FileService.uploadUserImage(_image!).then((downloadUrl) => {
      _apiUpdateMember(downloadUrl),
    });
  }

  @override
  void initState() {
    super.initState();
    _apiLoadMember();
    _apiLoadPosts();
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('Pick Photo'),
                      onTap: () {
                        _imageFromGallery();
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: Icon(Icons.photo_camera),
                    title: Text('Take Photo'),
                    onTap: () {
                      _imageFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
              color: Colors.black, fontFamily: "Billabong", fontSize: 25),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _dialogLogout();
            },
            icon: Icon(Icons.exit_to_app),
            color: Color.fromRGBO(193, 53, 132, 1),
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    _showPicker(context);
                  },
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(70),
                                border: Border.all(
                                    width: 1.5,
                                    color: Color.fromRGBO(193, 53, 132, 1))),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(35),
                                child: img_url.isEmpty
                                    ? const Image(
                                        image:
                                            AssetImage("assets/images/img.png"),
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        img_url,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      )),
                          ),
                          const SizedBox(
                            height: 80,
                            width: 80,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.add_circle_outlined,
                                  color: Colors.purple,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),

                      //#myinfos
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        fullName.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        email,
                        style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            fontWeight: FontWeight.normal),
                      ),

                      //#my accounts
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        height: 80,
                        child: Row(
                          children: [
                            Expanded(
                                child: Center(
                              child: Column(
                                children: [
                                  Text(
                                    count_posts.toString(),
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  const Text(
                                    "Posts",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            )),
                            Expanded(
                                child: Center(
                              child: Column(
                                children: [
                                  Text(
                                    count_following.toString(),
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  const Text(
                                    "FOLLOWING",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            )),
                            Expanded(
                                child: Center(
                              child: Column(
                                children: [
                                  Text(
                                    count_followers.toString(),
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  const Text(
                                    "FOLLOWERS",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Expanded(
                          child: Center(
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              axisCount = 1;
                            });
                          },
                          icon: Icon(Icons.list_alt),
                        ),
                      )),
                      Expanded(
                          child: Center(
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              axisCount = 2;
                            });
                          },
                          icon: Icon(Icons.grid_view),
                        ),
                      ))
                    ],
                  ),
                ),

                //#my posts
                Expanded(
                    child: GridView.builder(
                        itemCount: items.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: axisCount),
                        itemBuilder: (context, index) {
                          return _itemPost(items[index]);
                        }))
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _itemPost(Post post) {
    return GestureDetector(
      onLongPress: () {
        _dialogRemovePost(post);
      },
      child: Container(
        margin: EdgeInsets.all(5),
        child: Column(
          children: [
            Expanded(
                child: CachedNetworkImage(
              width: double.infinity,
              imageUrl: post.img_post,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
              fit: BoxFit.cover,
            )),
            SizedBox(
              height: 3,
            ),
            Text(
              post.caption,
              style: TextStyle(
                color: Colors.black87.withOpacity(0.7),
              ),
              maxLines: 2,
            )
          ],
        ),
      ),
    );
  }
}
